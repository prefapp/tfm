from utils import assume_role, log
import boto3
import time


def _is_missing_current_version_error(exc) -> bool:
    """
    Returns True when Secrets Manager reports that the secret exists but has no
    AWSCURRENT version available yet.
    """
    response = getattr(exc, "response", {}) or {}
    error = response.get("Error", {})
    message = error.get("Message", "")
    return error.get("Code") == "ResourceNotFoundException" and "AWSCURRENT" in message


def _get_secret_value_with_retry(source_sm, secret_id: str, *, skip_missing_current: bool):
    """
    Reads the current value of a source secret.

    For automatic replication triggered from CloudTrail, CreateSecret events may
    arrive before the secret has an AWSCURRENT version. In that case retry a few
    times and optionally skip gracefully.
    """
    max_attempts = 3
    retry_delay_seconds = 2

    for attempt in range(1, max_attempts + 1):
        try:
            return source_sm.get_secret_value(SecretId=secret_id)
        except source_sm.exceptions.ResourceNotFoundException as exc:
            if not _is_missing_current_version_error(exc):
                raise

            if attempt == max_attempts:
                if skip_missing_current:
                    log(
                        "warning",
                        "Source secret has no AWSCURRENT version yet, skipping replication",
                        secret_id=secret_id,
                        attempts=max_attempts,
                    )
                    return None
                raise

            log(
                "warning",
                "Source secret has no AWSCURRENT version yet, retrying",
                secret_id=secret_id,
                attempt=attempt,
                max_attempts=max_attempts,
            )
            time.sleep(retry_delay_seconds)


def replicate_secret(secret_id: str, config, get_sm_client=None, skip_missing_current=False):
    """
    Replicates a secret to all configured destinations and regions.
    Args:
        secret_id (str): ID or ARN of the secret to replicate.
        config: Configuration object with destinations and options.
    Returns:
        None
    """
    log("info", "Starting replication", secret_id=secret_id)

    # Allow passing a pre-created source_sm client for efficiency (e.g., full sync)
    source_sm = getattr(config, "source_sm", None)
    if source_sm is None:
        source_sm = boto3.client("secretsmanager", region_name=config.source_region)

    secret_response = _get_secret_value_with_retry(
        source_sm,
        secret_id,
        skip_missing_current=skip_missing_current,
    )
    if secret_response is None:
        return

    if "SecretString" in secret_response:
        secret_value = secret_response["SecretString"]
        secret_value_key = "SecretString"
    elif "SecretBinary" in secret_response:
        secret_value = secret_response["SecretBinary"]
        secret_value_key = "SecretBinary"
    else:
        raise Exception(f"Secret {secret_id} has neither SecretString nor SecretBinary")

    secret_metadata = source_sm.describe_secret(SecretId=secret_id)
    source_tags = secret_metadata.get("Tags", [])


    add_region_prefix = getattr(config, "add_region_prefix_to_name", False)
    source_region = str(config.source_region)

    for account_id, dest in config.destinations.items():
        log("info", "Processing destination account", account_id=account_id)

        for region_name, region_cfg in dest.regions.items():
            log("info", "Replicating to region", account_id=account_id, region=region_name)

            # Destination secret name: source-region-prefixed or original, max 512 chars
            if add_region_prefix:
                raw_dest_name = f"{source_region}-{secret_metadata['Name']}"
            else:
                raw_dest_name = secret_metadata['Name']
            dest_name = raw_dest_name[:512]

            # KMS key: usar la de la región si está, si no None (AWS managed)
            kms_key_arn = getattr(region_cfg, "kms_key_arn", None)
            # Solo usar si es un ARN válido (no None, no string vacío)
            if not kms_key_arn or not isinstance(kms_key_arn, str) or not kms_key_arn.strip():
                kms_key_arn = None

            # Build replication tags
            replication_tags = [
                {"Key": "origin-account", "Value": str(config.source_account)},
                {"Key": "origin-region", "Value": source_region},
                {"Key": "latest-version", "Value": str(secret_response.get("VersionId", ""))}
            ]
            # Merge original tags if enabled, avoiding duplicates
            if config.enable_tag_replication and source_tags:
                existing_keys = {t["Key"] for t in replication_tags}
                all_tags = replication_tags + [t for t in source_tags if t["Key"] not in existing_keys]
            else:
                all_tags = replication_tags

            if get_sm_client is not None:
                sm_dest = get_sm_client(dest.role_arn, region_name)
            else:
                sm_dest = assume_role(dest.role_arn, region_name)

            try:
                sm_dest.describe_secret(SecretId=dest_name)
                secret_exists = True
            except sm_dest.exceptions.ResourceNotFoundException:
                secret_exists = False

            if not secret_exists:
                log("info", "Creating secret in destination", account_id=account_id, region=region_name)

                create_args = {
                    "Name": dest_name,
                    "Tags": all_tags,
                    secret_value_key: secret_value
                }
                if kms_key_arn is not None:
                    create_args["KmsKeyId"] = kms_key_arn
                # Si no hay KmsKeyId, AWS managed
                try:
                    sm_dest.create_secret(**create_args)
                except Exception as e:
                    # Check if it's a "secret already exists" error
                    # AWS may return either ResourceExistsException or InvalidParameterException
                    error_code = getattr(e, 'response', {}).get('Error', {}).get('Code', '') if hasattr(e, 'response') else ''
                    error_message = str(e)

                    if not ('ResourceExistsException' in error_code or 'InvalidParameterException' in error_code or 'already exists' in error_message):
                        raise

                    log(
                        "warning",
                        "Destination secret already exists during creation, continuing with update",
                        account_id=account_id,
                        region=region_name,
                        secret_name=dest_name,
                    )
                    update_args = {
                        "SecretId": dest_name,
                        secret_value_key: secret_value,
                    }
                    if kms_key_arn is not None:
                        update_args["KmsKeyId"] = kms_key_arn
                    sm_dest.update_secret(**update_args)

                    if config.enable_tag_replication:
                        dest_metadata = sm_dest.describe_secret(SecretId=dest_name)
                        dest_tags = dest_metadata.get("Tags", [])
                        source_tag_keys = {t["Key"] for t in source_tags}
                        dest_tag_keys = {t["Key"] for t in dest_tags}
                        tags_to_remove = list(dest_tag_keys - source_tag_keys)
                        if tags_to_remove:
                            sm_dest.untag_resource(
                                SecretId=dest_name,
                                TagKeys=tags_to_remove
                            )
                        if source_tags:
                            sm_dest.tag_resource(
                                SecretId=dest_name,
                                Tags=source_tags
                            )
            else:
                update_args = {
                    "SecretId": dest_name,
                    secret_value_key: secret_value,
                }
                if kms_key_arn is not None:
                    update_args["KmsKeyId"] = kms_key_arn
                sm_dest.update_secret(**update_args)

                if config.enable_tag_replication:
                    dest_metadata = sm_dest.describe_secret(SecretId=dest_name)
                    dest_tags = dest_metadata.get("Tags", [])
                    source_tag_keys = {t["Key"] for t in source_tags}
                    dest_tag_keys = {t["Key"] for t in dest_tags}
                    tags_to_remove = list(dest_tag_keys - source_tag_keys)
                    if tags_to_remove:
                        sm_dest.untag_resource(
                            SecretId=dest_name,
                            TagKeys=tags_to_remove
                        )
                    if source_tags:
                        sm_dest.tag_resource(
                            SecretId=dest_name,
                            Tags=source_tags
                        )

            log("info", "Replication completed for account", account_id=account_id)

    log("info", "Replication finished for all destinations", secret_id=secret_id)


def replicate_all(config):
    """
    Replicates all secrets in the source account to all configured destinations and regions.
    Args:
        config: Configuration object with destinations and options.
    Returns:
        None
    """
    log("info", "Starting full sync (replicate all secrets)")
    source_sm = boto3.client("secretsmanager", region_name=config.source_region)
    paginator = source_sm.get_paginator("list_secrets")
    # Cache for assumed-role clients: {(role_arn, region): sm_client}
    sm_client_cache = {}
    def get_sm_client(role_arn, region_name):
        key = (role_arn, region_name)
        if key not in sm_client_cache:
            sm_client_cache[key] = assume_role(role_arn, region_name)
        return sm_client_cache[key]

    # Pass the source_sm client via config for reuse
    class ConfigWithClient:
        def __init__(self, base, source_sm):
            self.__dict__.update(base.__dict__)
            self.source_sm = source_sm

    config_with_client = ConfigWithClient(config, source_sm)

    for page in paginator.paginate():
        for secret in page.get("SecretList", []):
            secret_id = secret["ARN"]
            try:
                replicate_secret(secret_id, config_with_client, get_sm_client=get_sm_client)
            except Exception as e:
                log("error", f"Failed to replicate secret {secret_id}: {e}", exc_info=e)

    log("info", "Full sync completed")
