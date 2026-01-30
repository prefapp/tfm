from src.utils import assume_role, log
import boto3



def replicate_secret(secret_id: str, config):
    log("info", "Starting replication", secret_id=secret_id)

    # Read source secret
    source_sm = boto3.client("secretsmanager", region_name=config.source_region)

    secret_value = source_sm.get_secret_value(SecretId=secret_id)["SecretString"]
    secret_metadata = source_sm.describe_secret(SecretId=secret_id)

    source_tags = secret_metadata.get("Tags", [])

    for account_id, dest in config.destinations.items():
        log("info", "Processing destination account", account_id=account_id)

        for region_name, region_cfg in dest.regions.items():
            log("info", "Replicating to region", account_id=account_id, region=region_name)

            # Assume role → returns a Secrets Manager client for that region
            sm_dest = assume_role(dest.role_arn, region_name)

            # Ensure secret exists or create it
            try:
                sm_dest.describe_secret(SecretId=secret_id)
                secret_exists = True
            except sm_dest.exceptions.ResourceNotFoundException:
                secret_exists = False

            if not secret_exists:
                log("info", "Creating secret in destination", account_id=account_id, region=region_name)

                sm_dest.create_secret(
                    Name=secret_id,
                    SecretString=secret_value,
                    KmsKeyId=region_cfg.kms_key_id,
                    Tags=source_tags if config.enable_tag_replication else [],
                )
            else:
                # Update secret value
                sm_dest.put_secret_value(
                    SecretId=secret_id,
                    SecretString=secret_value,
                )

                # Sync tags if enabled
                if config.enable_tag_replication:
                    sm_dest.untag_resource(
                        SecretId=secret_id,
                        TagKeys=[t["Key"] for t in source_tags]
                    )
                    sm_dest.tag_resource(
                        SecretId=secret_id,
                        Tags=source_tags
                    )

            log("info", "Replication completed", account_id=account_id, region=region_name)

    log("info", "Replication finished for all destinations", secret_id=secret_id)
