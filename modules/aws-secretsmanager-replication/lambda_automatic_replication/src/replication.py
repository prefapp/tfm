from src.utils import assume_role, log
import boto3


def extract_secret_name(secret_id):
    """
    Extracts the real secret name from a Secrets Manager ARN, removing the random 6-character suffix if present.
    Args:
        secret_id (str): The ARN or name of the secret.
    Returns:
        str: The extracted secret name without the random suffix.
    """
    # ARN → extract the part after "secret:"
    if secret_id.startswith("arn:"):
        # Example ARN:
        # arn:aws:secretsmanager:eu-west-1:123456789012:secret:dev/valor_de_pi-QQzt8J
        split_arn = secret_id.split(":secret:", 1)
        if len(split_arn) == 2:
            name_with_suffix = split_arn[1]
            # Remove only the random 6-character alphanumeric suffix at the end, if present
            if "-" in name_with_suffix:
                base, last_segment = name_with_suffix.rsplit("-", 1)
                if len(last_segment) == 6 and last_segment.isalnum():
                    return base
            return name_with_suffix
        # If :secret: is not found, fall through and return the full ARN
        return secret_id
    return secret_id


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

    # Secret name (valid in destination)
    dest_name = extract_secret_name(secret_id)

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
            log("info", "Replicating to region", account_id=account_id, region=region_name)

            # Use cached client if provided, else fallback to assume_role
            if get_sm_client is not None:
                sm_dest = get_sm_client(dest.role_arn, region_name)
            else:
                sm_dest = assume_role(dest.role_arn, region_name)

            # Ensure secret exists or create it
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
                # Update secret value
                sm_dest.put_secret_value(
                    SecretId=dest_name,
                    **{secret_value_key: secret_value}
                )

                # Sync tags if enabled: ensure destination tags match source exactly
                if config.enable_tag_replication:
                    # Get current tags from destination
                    dest_metadata = sm_dest.describe_secret(SecretId=dest_name)
                    dest_tags = dest_metadata.get("Tags", [])
                    source_tag_keys = {t["Key"] for t in source_tags}
                    dest_tag_keys = {t["Key"] for t in dest_tags}
                    # Remove tags that are present on destination but not in source
                    tags_to_remove = list(dest_tag_keys - source_tag_keys)
                    if tags_to_remove:
                        sm_dest.untag_resource(
                            SecretId=dest_name,
                            TagKeys=tags_to_remove
                        )
                    # Apply all source tags (will add/update as needed)
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
                log("error", f"Failed to replicate secret {secret_id}: {e}")
