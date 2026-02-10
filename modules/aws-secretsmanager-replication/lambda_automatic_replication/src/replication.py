from src.utils import assume_role, log
import boto3


def replicate_secret(secret_id: str, config, get_sm_client=None):
    """
    Replicates a secret to all configured destinations and regions.
    Args:
        secret_id (str): ID or ARN of the secret to replicate.
        config: Configuration object with destinations and options.
    Returns:
        None
    """
    log("info", "Starting replication", secret_id=secret_id)

    # Read source secret (full ARN is OK)
    source_sm = boto3.client("secretsmanager", region_name=config.source_region)

    secret_response = source_sm.get_secret_value(SecretId=secret_id)
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

    for account_id, dest in config.destinations.items():
        log("info", "Processing destination account", account_id=account_id)

        for region_name, region_cfg in dest.regions.items():
            # Only replicate if secret_id matches the configured source_secret_arn (full ARN or secret name)
            match = False
            if secret_id == region_cfg.source_secret_arn:
                match = True
            elif ":secret:" in region_cfg.source_secret_arn and ":secret:" in secret_id:
                # Both are ARNs: compare the resource part after ":secret:"
                match = region_cfg.source_secret_arn.split(":secret:", 1)[1] == secret_id.split(":secret:", 1)[1]
            elif ":secret:" in region_cfg.source_secret_arn and ":secret:" not in secret_id:
                # Configured value is an ARN and secret_id is a name (e.g., from CreateSecret CloudTrail event).
                # Extract the secret-name portion from the ARN (before the trailing random suffix, if present).
                arn_resource = region_cfg.source_secret_arn.split(":secret:", 1)[1]
                secret_name_from_arn = arn_resource.rsplit("-", 1)[0]
                if secret_id == secret_name_from_arn:
                    match = True
            if not match:
                continue

            log("info", "Replicating to region", account_id=account_id, region=region_name)

            dest_name = region_cfg.destination_secret_name

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

                sm_dest.create_secret(
                    Name=dest_name,
                    KmsKeyId=region_cfg.kms_key_arn,
                    Tags=source_tags if config.enable_tag_replication else [],
                    **{secret_value_key: secret_value}
                )
            else:
                sm_dest.put_secret_value(
                    SecretId=dest_name,
                    **{secret_value_key: secret_value}
                )

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
            log("info", "Replication completed", account_id=account_id, region=region_name)

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

    for page in paginator.paginate():
        for secret in page.get("SecretList", []):
            secret_id = secret["ARN"]
            try:
                replicate_secret(secret_id, config, get_sm_client=get_sm_client)
            except Exception as e:
                log("error", f"Failed to replicate secret {secret_id}: {e}", exc_info=True)
