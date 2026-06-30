# handler.py - Unified parameter replication Lambda
# Handles both EventBridge-driven and manual invocation modes

from common.replication import replicate_parameter
from common.config import load_config
from common.utils import log, assume_role, is_expired_token_error
import boto3
import json


_TRUTHY_FLAG_VALUES = {"1", "true", "yes", "on"}
_FALSY_FLAG_VALUES = {"0", "false", "no", "off"}


def _normalize_parameter_name(value):
    """Returns a strict, trimmed parameter name string, otherwise None."""
    if not isinstance(value, str):
        return None

    normalized = value.strip()
    if not normalized:
        return None

    # Reject names with whitespace characters to fail early with a clear 400.
    if any(ch.isspace() for ch in normalized):
        return None

    # SSM parameter names are limited to 2048 chars.
    if len(normalized) > 2048:
        return None

    return normalized


def _parse_full_sync_flag(value):
    """Parses full-sync flag values. Returns (bool_value, is_valid)."""
    if isinstance(value, bool):
        return value, True

    if isinstance(value, str):
        normalized = value.strip().lower()
        if normalized in _TRUTHY_FLAG_VALUES:
            return True, True
        if normalized in _FALSY_FLAG_VALUES:
            return False, True
        return False, False

    return False, False


def _extract_parameter_from_eventbridge(event):
    """
    Extracts parameter name from native SSM Parameter Store Change event.
    Returns (parameter_name, is_eventbridge) or (None, False) if not an EB event.
    """
    if not isinstance(event, dict):
        return None, False

    detail = event.get("detail", {})
    if not isinstance(detail, dict):
        return None, False

    detail_type = event.get("detail-type", "")

    if detail_type != "Parameter Store Change":
        return None, False

    operation = detail.get("operation")
    if operation not in ("Create", "Update"):
        return None, False

    parameter_name = _normalize_parameter_name(detail.get("name"))
    return parameter_name, parameter_name is not None


def lambda_handler(event, context):
    """
    Unified Lambda entry point for parameter replication.

    Modes:
    1. EventBridge automatic: triggered by SSM Parameter Store Change events
    2. Manual single parameter: invoke with {"parameter_name": "my-param"}
    3. Full sync: invoke with {"initial_run": true} or {"enable_full_sync": true}

    Args:
        event (dict): Lambda event data
        context: Lambda context object

    Returns:
        dict or None
    """
    if not isinstance(event, dict):
        log(
            "warning",
            "Invalid event payload type",
            provided_type=type(event).__name__,
        )
        return {
            "statusCode": 400,
            "body": json.dumps({
                "message": "Invalid invocation: event payload must be a JSON object."
            })
        }

    config = load_config()

    # Mode 1: EventBridge automatic replication
    param_name_eb, is_eventbridge = _extract_parameter_from_eventbridge(event)
    if is_eventbridge:
        log("info", "EventBridge automatic replication triggered", parameter_name=param_name_eb)
        replicate_parameter(param_name_eb, config, skip_missing=True)
        return None

    # Mode 2 & 3: Manual invocation (can be single param or full sync)
    parameter_name = None
    if "parameter_name" in event:
        raw_parameter_name = event.get("parameter_name")
        parameter_name = _normalize_parameter_name(raw_parameter_name)
        if parameter_name is None:
            log(
                "warning",
                "Invalid parameter_name in invocation payload",
                provided_type=type(raw_parameter_name).__name__,
            )
            return {
                "statusCode": 400,
                "body": json.dumps({
                    "message": "Invalid invocation: 'parameter_name' must be a non-empty string without whitespace and no longer than 2048 characters when provided."
                })
            }

    # Check for full sync request.
    # Use explicit key presence checks so explicit false is not treated as "missing".
    # Full sync must be explicitly requested in the event; config.enable_full_sync is only a guardrail.
    if "enable_full_sync" in event:
        event_enable_full_sync = event.get("enable_full_sync")
    elif "initial_run" in event:
        event_enable_full_sync = event.get("initial_run")
    else:
        event_enable_full_sync = False

    enable_full_sync, is_valid_full_sync_flag = _parse_full_sync_flag(event_enable_full_sync)
    if not is_valid_full_sync_flag:
        log(
            "warning",
            "Invalid full sync flag type in invocation payload",
            provided_type=type(event_enable_full_sync).__name__,
            provided_value=str(event_enable_full_sync),
        )
        return {
            "statusCode": 400,
            "body": json.dumps({
                "message": "Invalid invocation: 'enable_full_sync'/'initial_run' must be a boolean or one of: true/false, yes/no, on/off, 1/0."
            })
        }

    # Guardrail: refuse to run full sync if not enabled in config
    if enable_full_sync and not config.enable_full_sync:
        log(
            "error",
            "Full sync requested but ENABLE_FULL_SYNC is not enabled. Refusing to run.",
        )
        return {
            "statusCode": 403,
            "body": json.dumps({
                "message": "Full sync is not enabled for this Lambda. Set enable_full_sync = true in Terraform to allow this operation."
            })
        }

    # Mode 2a: Full account sync
    if enable_full_sync:
        log("info", "Starting full sync of all parameters")

        source_ssm = boto3.client("ssm", region_name=config.source_region)
        config.source_ssm = source_ssm

        paginator = source_ssm.get_paginator("describe_parameters")
        page_iterator = paginator.paginate()

        # Cache destination clients per (role_arn, region)
        cached_ssm_clients = {}

        def get_cached_ssm_client(role_arn, region_name):
            cache_key = (role_arn, region_name)
            if cache_key not in cached_ssm_clients:
                cached_ssm_clients[cache_key] = assume_role(
                    role_arn,
                    region_name,
                    duration_seconds=config.assume_role_duration_seconds,
                )
            return cached_ssm_clients[cache_key]

        replicated_count = 0
        error_count = 0

        for page in page_iterator:
            for param_meta in page.get("Parameters", []):
                try:
                    param_name = param_meta["Name"]
                    log("info", "Replicating parameter in full sync", parameter_name=param_name)
                    replicate_parameter(
                        param_name,
                        config,
                        get_ssm_client=get_cached_ssm_client,
                        skip_missing=True,
                    )
                    replicated_count += 1
                except Exception as e:
                    retry_param_name = param_meta.get("Name") if isinstance(param_meta, dict) else None
                    if isinstance(retry_param_name, str):
                        retry_param_name = retry_param_name.strip()
                    if not retry_param_name:
                        retry_param_name = None

                    failed_param_name = retry_param_name or (
                        "<missing-name>" if isinstance(param_meta, dict) else "<invalid-parameter-metadata>"
                    )

                    if is_expired_token_error(e) and retry_param_name is not None:
                        log(
                            "warning",
                            "Expired destination credentials detected during full sync; refreshing cached clients and retrying once",
                            parameter_name=failed_param_name,
                            error=str(e),
                        )
                        cached_ssm_clients.clear()
                        try:
                            replicate_parameter(
                                failed_param_name,
                                config,
                                get_ssm_client=get_cached_ssm_client,
                                skip_missing=True,
                            )
                            replicated_count += 1
                            continue
                        except Exception as retry_exc:
                            log(
                                "error",
                                "Retry after credential refresh failed in full sync",
                                parameter_name=failed_param_name,
                                error=str(retry_exc),
                            )
                    elif is_expired_token_error(e):
                        log(
                            "warning",
                            "Expired destination credentials detected during full sync, but retry is skipped because parameter name context is missing or invalid",
                            parameter_name=failed_param_name,
                            error=str(e),
                        )

                    log("error", "Failed to replicate parameter in full sync", parameter_name=failed_param_name, error=str(e))
                    error_count += 1

        log("info", "Full sync completed", replicated_count=replicated_count, error_count=error_count)
        return {
            "statusCode": 200,
            "body": json.dumps({
                "message": "Full sync completed",
                "replicated_count": replicated_count,
                "error_count": error_count
            })
        }

    # Mode 2b: Manual single parameter replication
    elif parameter_name:
        log("info", "Starting manual replication", parameter_name=parameter_name)
        try:
            replicate_parameter(parameter_name, config, skip_missing=False)
            return {
                "statusCode": 200,
                "body": json.dumps({
                    "message": f"Successfully replicated parameter: {parameter_name}"
                })
            }
        except Exception as e:
            log("error", "Failed to replicate parameter", parameter_name=parameter_name, error=str(e), exc_info=True)
            return {
                "statusCode": 500,
                "body": json.dumps({
                    "message": f"Failed to replicate parameter: {parameter_name}. Check Lambda logs for details."
                })
            }

    # No valid invocation mode
    else:
        log("warning", "No valid invocation mode (no EventBridge event, no parameter_name, and no explicit full sync request)")
        return {
            "statusCode": 400,
            "body": json.dumps({
                "message": "Invalid invocation: must be triggered by EventBridge, provide 'parameter_name', or explicitly request full sync with 'enable_full_sync': true or 'initial_run': true."
            })
        }
