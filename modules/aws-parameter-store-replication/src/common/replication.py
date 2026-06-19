from utils import assume_role, log
import boto3
import time


def _get_parameter_value_with_retry(source_ssm, parameter_name: str, *, skip_missing: bool):
    """
    Reads the current value of a source parameter.

    For automatic replication triggered from EventBridge, Create events may
    arrive before the parameter is fully available. In that case retry a few times
    and optionally skip gracefully.
    """
    max_attempts = 3
    retry_delay_seconds = 2

    for attempt in range(1, max_attempts + 1):
        try:
            return source_ssm.get_parameter(Name=parameter_name, WithDecryption=True)
        except source_ssm.exceptions.ParameterNotFound as exc:
            if attempt == max_attempts:
                if skip_missing:
                    log(
                        "warning",
                        "Source parameter not found yet, skipping replication",
                        parameter_name=parameter_name,
                        attempts=max_attempts,
                    )
                    return None
                raise

            log(
                "warning",
                "Source parameter not found yet, retrying",
                parameter_name=parameter_name,
                attempt=attempt,
                max_attempts=max_attempts,
            )
            time.sleep(retry_delay_seconds)


def replicate_parameter(parameter_name: str, config, get_ssm_client=None, skip_missing=False):
    """
    Replicates a parameter to all configured destinations and regions.
    Args:
        parameter_name (str): Name of the parameter to replicate.
        config: Configuration object with destinations and options.
        get_ssm_client: Optional function to get SSM client (for custom clients).
        skip_missing: If True, skip if source parameter is not found.
    Returns:
        None
    """
    log("info", "Starting replication", parameter_name=parameter_name)

    # Allow passing a pre-created source_ssm client for efficiency (e.g., full sync)
    source_ssm = getattr(config, "source_ssm", None)
    if source_ssm is None:
        source_ssm = boto3.client("ssm", region_name=config.source_region)

    param_response = _get_parameter_value_with_retry(
        source_ssm,
        parameter_name,
        skip_missing=skip_missing,
    )
    if param_response is None:
        return

    param_metadata = param_response["Parameter"]
    param_value = param_metadata["Value"]
    param_type = param_metadata["Type"]  # String, StringList, or SecureString
    param_version = param_metadata.get("Version", 1)

    # Get tags for the parameter
    try:
        tags_response = source_ssm.list_tags_for_resource(
            ResourceType="Parameter",
            ResourceId=parameter_name
        )
        source_tags = {tag["Key"]: tag["Value"] for tag in tags_response.get("TagList", [])}
    except Exception as e:
        log("warning", "Failed to get tags for parameter", parameter_name=parameter_name, error=str(e))
        source_tags = {}

    add_region_prefix = getattr(config, "add_region_prefix_to_name", False)
    source_region = str(config.source_region)

    for account_id, dest in config.destinations.items():
        log("info", "Processing destination account", account_id=account_id)

        for region_name, region_cfg in dest.regions.items():
            log("info", "Replicating to region", account_id=account_id, region=region_name)

            # Destination parameter name: source-region-prefixed or original
            if add_region_prefix:
                dest_param_name = f"{source_region}-{parameter_name}"
            else:
                dest_param_name = parameter_name

            # KMS key: usar la de la región si está, si no None (AWS managed)
            kms_key_id = getattr(region_cfg, "kms_key_arn", None)
            if not kms_key_id or not isinstance(kms_key_id, str) or not kms_key_id.strip():
                kms_key_id = None

            # Build replication tags
            replication_tags = {
                "origin-account": str(config.source_account),
                "origin-region": source_region,
                "latest-version": str(param_version)
            }

            # Merge original tags if enabled, original tags take precedence
            if config.enable_tag_replication and source_tags:
                combined_tags = {**replication_tags, **source_tags}
            else:
                combined_tags = replication_tags

            if get_ssm_client is not None:
                ssm_dest = get_ssm_client(dest.role_arn, region_name)
            else:
                ssm_dest = assume_role(dest.role_arn, region_name)

            try:
                ssm_dest.get_parameter(Name=dest_param_name)
                param_exists = True
            except ssm_dest.exceptions.ParameterNotFound:
                param_exists = False

            put_args = {
                "Name": dest_param_name,
                "Value": param_value,
                "Type": param_type,
                "Overwrite": True,
            }

            # put_parameter does not support setting Tags reliably when updating
            # existing parameters with Overwrite=true. Include tags only on create,
            # and sync tags separately for updates.
            if not param_exists:
                put_args["Tags"] = [{"Key": k, "Value": v} for k, v in combined_tags.items()]

            # Add KMS key if specified and parameter type is SecureString
            if param_type == "SecureString" and kms_key_id is not None:
                put_args["KeyId"] = kms_key_id

            try:
                if param_exists:
                    log("info", "Updating parameter in destination", account_id=account_id, region=region_name)
                else:
                    log("info", "Creating parameter in destination", account_id=account_id, region=region_name)

                ssm_dest.put_parameter(**put_args)

                # Keep tags in sync for updates using the dedicated tagging API.
                if param_exists and combined_tags:
                    ssm_dest.add_tags_to_resource(
                        ResourceType="Parameter",
                        ResourceId=dest_param_name,
                        Tags=[{"Key": k, "Value": v} for k, v in combined_tags.items()],
                    )

                log("info", "Successfully replicated parameter", account_id=account_id, region=region_name)

            except Exception as e:
                log("error", "Failed to replicate parameter", account_id=account_id, region=region_name, error=str(e), exc_info=True)
                raise

    log("info", "Replication completed", parameter_name=parameter_name)
