# handler.py - Unified Secrets Manager replication Lambda
# Handles EventBridge-driven (CloudTrail) replication, manual single-secret
# invocation, and full-account sync, distinguished by event shape.

import json

from common.config import load_config
from common.replication import replicate_secret, replicate_all
from common.utils import log


_TRUTHY_FLAG_VALUES = {"1", "true", "yes", "on"}
_FALSY_FLAG_VALUES = {"0", "false", "no", "off"}


def _normalize_secret_id(value):
    """Returns a strict, trimmed secret id string, otherwise None."""
    if not isinstance(value, str):
        return None

    normalized = value.strip()
    if not normalized:
        return None

    # Reject values with internal whitespace to fail early with a clear 400.
    if any(ch.isspace() for ch in normalized):
        return None

    return normalized


def _parse_full_sync_flag(value):
    """Parses full-sync flag values. Returns (bool_value, is_valid)."""
    if isinstance(value, bool):
        return value, True

    if isinstance(value, int):
        if value == 1:
            return True, True
        if value == 0:
            return False, True
        return False, False

    if isinstance(value, str):
        normalized = value.strip().lower()
        if normalized in _TRUTHY_FLAG_VALUES:
            return True, True
        if normalized in _FALSY_FLAG_VALUES:
            return False, True
        return False, False

    return False, False


def _extract_secret_id_from_detail(detail):
    """
    Extracts the secret ID from a CloudTrail event detail.

    Returns the secret ID/ARN/name, or None if not found.
    """
    rp = detail.get("requestParameters", {}) or {}

    # 1. Normal case: events that provide a secretId/SecretId request parameter (e.g., PutSecretValue)
    sid = rp.get("secretId") or rp.get("SecretId")
    if sid:
        return sid

    # 2. CreateSecret case: only has "name"
    name = rp.get("name")
    if name:
        return name

    # 3. Fallback: handle both List[str] ARNs and List[dict] resource entries
    resources = detail.get("resources", []) or []
    for r in resources:
        if isinstance(r, dict):
            if r.get("type") == "AWS::SecretsManager::Secret":
                return r.get("ARN") or r.get("resourceName")
        elif isinstance(r, str) and r.startswith("arn:aws:secretsmanager:"):
            return r

    return None


def _extract_secret_from_eventbridge(event):
    """
    Extracts the secret id from a Secrets Manager CloudTrail EventBridge event.

    Returns (secret_id, is_eventbridge). is_eventbridge is True when the event
    looks like a CloudTrail-delivered Secrets Manager API call, regardless of
    whether a replicable secret id could be extracted.

    Event name filtering is intentionally delegated to the EventBridge rule
    (via eventbridge_extra_event_names). Any CloudTrail event that reaches
    this Lambda was already approved by the rule; restricting by event name
    here would silently drop events added through that variable.
    """
    if not isinstance(event, dict):
        return None, False

    if event.get("detail-type") != "AWS API Call via CloudTrail":
        return None, False

    detail = event.get("detail", {})
    if not isinstance(detail, dict):
        return None, True

    return _extract_secret_id_from_detail(detail), True


def lambda_handler(event, context):
    """
    Unified Lambda entry point for secret replication.

    Modes:
    1. EventBridge automatic: triggered by Secrets Manager CloudTrail events
    2. Manual single secret: invoke with {"secret_id": "my-secret"}
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
            }),
        }

    # Mode 1: EventBridge automatic replication
    secret_id_eb, is_eventbridge = _extract_secret_from_eventbridge(event)
    if is_eventbridge:
        if secret_id_eb is None:
            log("info", "Ignoring non-replicable Secrets Manager CloudTrail event")
            return None

        config = load_config()
        log("info", "EventBridge automatic replication triggered", secret_id=secret_id_eb)
        replicate_secret(secret_id_eb, config, skip_missing_current=True)
        return None

    # Mode 2 & 3: Manual invocation (single secret or full sync)
    # All input validation runs before load_config() to avoid the extra
    # JSON parsing and STS call on invocations that will return 400.
    secret_id = None
    if "secret_id" in event:
        raw_secret_id = event.get("secret_id")
        secret_id = _normalize_secret_id(raw_secret_id)
        if secret_id is None:
            log(
                "warning",
                "Invalid secret_id in invocation payload",
                provided_type=type(raw_secret_id).__name__,
            )
            return {
                "statusCode": 400,
                "body": json.dumps({
                    "message": "Invalid invocation: 'secret_id' must be a non-empty string without whitespace when provided."
                }),
            }

    # Check for full sync request. Use explicit key presence checks so an
    # explicit false is not treated as "missing". Full sync must be explicitly
    # requested in the event; config.enable_full_sync is only a guardrail.
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
            "Invalid full sync flag type or value in invocation payload",
            provided_type=type(event_enable_full_sync).__name__,
            provided_value=str(event_enable_full_sync),
        )
        return {
            "statusCode": 400,
            "body": json.dumps({
                "message": "Invalid invocation: 'enable_full_sync'/'initial_run' must be a boolean or one of: true/false, yes/no, on/off, 1/0."
            }),
        }

    # Reject unknown/empty invocations before paying the load_config() cost.
    if not secret_id and not enable_full_sync:
        log(
            "warning",
            "No valid invocation mode (no EventBridge event, no secret_id, and no explicit full sync request)",
        )
        return {
            "statusCode": 400,
            "body": json.dumps({
                "message": "Invalid invocation: must be triggered by EventBridge, provide 'secret_id', or explicitly request full sync with 'enable_full_sync': true or 'initial_run': true."
            }),
        }

    config = load_config()

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
            }),
        }

    # Mode 3: Full account sync
    if enable_full_sync:
        log("info", "Starting full sync of all secrets")
        try:
            failed_secrets = replicate_all(config)
        except Exception as e:
            log("error", "Full sync aborted due to unexpected error", error=str(e), exc_info=True)
            return {
                "statusCode": 500,
                "body": json.dumps({
                    "message": "Full sync aborted due to an unexpected error. Check Lambda logs for details."
                }),
            }
        if failed_secrets:
            log(
                "error",
                "Full sync completed with failures",
                failed_count=len(failed_secrets),
            )
            return {
                "statusCode": 500,
                "body": json.dumps({
                    "message": f"Full sync completed with {len(failed_secrets)} failure(s). Check Lambda logs for details."
                }),
            }
        return {
            "statusCode": 200,
            "body": json.dumps({"message": "Full sync completed"}),
        }

    # Mode 2: Manual single secret replication
    if secret_id:
        log("info", "Starting manual replication", secret_id=secret_id)
        try:
            replicate_secret(secret_id, config)
            return {
                "statusCode": 200,
                "body": json.dumps({
                    "message": f"Successfully replicated secret: {secret_id}"
                }),
            }
        except Exception as e:
            error_code = (((getattr(e, "response", None) or {}).get("Error") or {}).get("Code"))
            if error_code == "ResourceNotFoundException":
                log(
                    "warning",
                    "Source secret not found for manual replication",
                    secret_id=secret_id,
                )
                return {
                    "statusCode": 404,
                    "body": json.dumps({
                        "message": f"Source secret not found: {secret_id}"
                    }),
                }

            log("error", "Failed to replicate secret", secret_id=secret_id, error=str(e), exc_info=True)
            return {
                "statusCode": 500,
                "body": json.dumps({
                    "message": f"Failed to replicate secret: {secret_id}. Check Lambda logs for details."
                }),
            }
