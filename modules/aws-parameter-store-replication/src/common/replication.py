from common.utils import assume_role, log
import boto3
import time
from botocore.exceptions import ClientError


def _build_destination_parameter_name(parameter_name: str, source_region: str, add_region_prefix: bool) -> str:
    """
    Builds a destination parameter name that is valid for both simple names and paths.

    - If add_region_prefix is False: keep original name.
    - If True and name is a path (/...): prepend region as first path segment
        (e.g. /secrets/app -> /eu-west-1/secrets/app).
    - If True and name is not a path: prepend region with '-' separator
        (e.g. app-secret -> eu-west-1-app-secret).
    """
    if not add_region_prefix:
        return parameter_name

    if parameter_name.startswith("/"):
        normalized_path = parameter_name.lstrip("/")
        return f"/{source_region}/{normalized_path}"

    return f"{source_region}-{parameter_name}"


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

    # Fetch source tags only when source-tag replication is enabled.
    source_tags = {}
    source_tags_fetched = not config.enable_tag_replication
    if config.enable_tag_replication:
        try:
            tags_response = source_ssm.list_tags_for_resource(
                ResourceType="Parameter",
                ResourceId=parameter_name
            )
            source_tags = {tag["Key"]: tag["Value"] for tag in tags_response.get("TagList", [])}
            source_tags_fetched = True
        except Exception as e:
            source_tags_fetched = False
            log("warning", "Failed to get tags for parameter", parameter_name=parameter_name, error=str(e))

    add_region_prefix = getattr(config, "add_region_prefix_to_name", False)
    source_region = str(config.source_region)

    for account_id, dest in config.destinations.items():
        log("info", "Processing destination account", account_id=account_id)

        for region_name, region_cfg in dest.regions.items():
            log("info", "Replicating to region", account_id=account_id, region=region_name)

            # Destination parameter name: source-region-prefixed or original
            dest_param_name = _build_destination_parameter_name(
                parameter_name,
                source_region,
                add_region_prefix,
            )

            # KMS key: use region-specific key when provided, otherwise None (AWS managed key)
            kms_key_id = getattr(region_cfg, "kms_key_arn", None)
            if not kms_key_id or not isinstance(kms_key_id, str) or not kms_key_id.strip():
                kms_key_id = None

            # Build replication tags
            replication_tags = {
                "origin-account": str(config.source_account),
                "origin-region": source_region,
                "latest-version": str(param_version)
            }

            # Merge source tags if enabled, replication metadata takes precedence
            if config.enable_tag_replication and source_tags:
                combined_tags = {**source_tags, **replication_tags}
            else:
                combined_tags = replication_tags

            if get_ssm_client is not None:
                ssm_dest = get_ssm_client(dest.role_arn, region_name)
            else:
                ssm_dest = assume_role(
                    dest.role_arn,
                    region_name,
                    duration_seconds=getattr(config, "assume_role_duration_seconds", None),
                )

            destination_read_denied = False
            try:
                # Use GetParameters so existence probing is aligned with the action
                # AWS effectively requires for update-time tag APIs.
                probe_response = ssm_dest.get_parameters(
                    Names=[dest_param_name],
                    WithDecryption=False,
                )
                invalid_names = set(probe_response.get("InvalidParameters", []))
                param_exists = dest_param_name not in invalid_names
            except ClientError as e:
                # Some destination roles are intentionally scoped for write-only APIs.
                # If read is denied, proceed in overwrite mode (valid for both create and update)
                # and keep desired-tag application as best effort after PutParameter.
                code = ((e.response or {}).get("Error") or {}).get("Code")
                if code == "AccessDeniedException":
                    destination_read_denied = True
                    log(
                        "warning",
                        "Access denied on destination existence probe (GetParameters); proceeding with overwrite mode",
                        account_id=account_id,
                        region=region_name,
                        parameter_name=dest_param_name,
                    )
                    param_exists = True
                else:
                    raise

            put_args = {
                "Name": dest_param_name,
                "Value": param_value,
                "Type": param_type,
            }

            # AWS does not allow Tags and Overwrite=True together.
            # On create: include Tags, omit Overwrite (defaults to False).
            # On update: set Overwrite=True, sync tags separately via AddTagsToResource.
            if not param_exists:
                put_args["Tags"] = [{"Key": k, "Value": v} for k, v in combined_tags.items()]
            else:
                put_args["Overwrite"] = True

            # Add KMS key for SecureString parameters when a CMK is configured.
            # KeyId is valid in both create and update (Overwrite=True) calls.
            # On create it is combined with Tags, which AWS allows.
            # On update it ensures the CMK is not silently ignored when re-encrypting.
            if param_type == "SecureString" and kms_key_id is not None:
                put_args["KeyId"] = kms_key_id

            try:
                if param_exists:
                    log("info", "Updating parameter in destination", account_id=account_id, region=region_name)
                else:
                    log("info", "Creating parameter in destination", account_id=account_id, region=region_name)

                ssm_dest.put_parameter(**put_args)

                # Sync tags for updates:
                # - Always add/update desired tags (replication metadata + optional source tags)
                # - Remove stale destination tags only when source-tag replication is enabled
                #   and source tags were fetched successfully
                if param_exists:
                    if destination_read_denied:
                        log(
                            "warning",
                            "Skipping stale-tag pruning because destination parameter read is denied; applying desired tags best-effort",
                            account_id=account_id,
                            region=region_name,
                            destination_parameter_name=dest_param_name,
                        )
                    else:
                        # Pruning path (best effort): do not block desired-tag application.
                        try:
                            # Only fetch destination tags if we need them for stale-tag pruning.
                            # When tag replication is disabled, skip this API call and only update metadata tags.
                            if config.enable_tag_replication and source_tags_fetched:
                                # Get current destination tags for pruning stale ones
                                dest_tags_response = ssm_dest.list_tags_for_resource(
                                    ResourceType="Parameter",
                                    ResourceId=dest_param_name
                                )
                                dest_tags = {tag["Key"]: tag["Value"] for tag in dest_tags_response.get("TagList", [])}

                                # Prune stale tags (only when source tag replication is enabled)
                                stale_tags = set(dest_tags.keys()) - set(combined_tags.keys())
                                if stale_tags:
                                    log("info", "Removing stale tags from parameter", account_id=account_id, region=region_name, stale_tags=list(stale_tags))
                                    ssm_dest.remove_tags_from_resource(
                                        ResourceType="Parameter",
                                        ResourceId=dest_param_name,
                                        TagKeys=list(stale_tags),
                                    )
                            elif config.enable_tag_replication and not source_tags_fetched:
                                log(
                                    "warning",
                                    "Skipping stale-tag pruning because source tags could not be fetched",
                                    account_id=account_id,
                                    region=region_name,
                                    destination_parameter_name=dest_param_name,
                                    source_parameter_name=parameter_name,
                                )
                        except Exception as e:
                            log("warning", "Failed to prune stale tags for parameter", account_id=account_id, region=region_name, error=str(e))

                        # Desired-tag application path (best effort, independent from pruning).
                        try:
                            if combined_tags:
                                ssm_dest.add_tags_to_resource(
                                    ResourceType="Parameter",
                                    ResourceId=dest_param_name,
                                    Tags=[{"Key": k, "Value": v} for k, v in combined_tags.items()],
                                )
                        except Exception as e:
                            log("warning", "Failed to apply desired tags for parameter", account_id=account_id, region=region_name, error=str(e))
                            # Continue replication even if tag sync fails

                log("info", "Successfully replicated parameter", account_id=account_id, region=region_name)

            except Exception as e:
                log("error", "Failed to replicate parameter", account_id=account_id, region=region_name, error=str(e), exc_info=True)
                raise

    log("info", "Replication completed", parameter_name=parameter_name)
