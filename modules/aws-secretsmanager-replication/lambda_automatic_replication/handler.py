# lambda_automatic_replication/handler.py
from src.replication import replicate_secret
from src.config import load_config

def extract_secret_id(detail):
    """
    Extracts the secret ID from a CloudTrail event detail.
    Args:
        detail (dict): CloudTrail event detail.
    Returns:
        str or None: The secret ID or ARN, or None if not found.
    """
    rp = detail.get("requestParameters", {})

    # 1. Normal case: PutSecretValue, UpdateSecret, RotateSecret
    sid = rp.get("secretId") or rp.get("SecretId")
    if sid:
        return sid

    # 2. CreateSecret case: only has "name"
    name = rp.get("name")
    if name:
        return name

    # 3. Rare case: CloudTrail sometimes puts the ARN in resources
    resources = detail.get("resources", [])
    for r in resources:
        if r.get("type") == "AWS::SecretsManager::Secret":
            return r.get("ARN") or r.get("resourceName")

    return None

def lambda_handler(event, context):
    """
    AWS Lambda entry point. Handles the event for secret replication.
    Args:
        event (dict): Lambda event data.
        context: Lambda context object.
    Returns:
        None
    """
    detail = event.get("detail", {})
    event_name = detail.get("eventName")
    if event_name not in ("CreateSecret", "PutSecretValue", "UpdateSecret", "RotateSecret", "RestoreSecret"):
        return

    secret_id = extract_secret_id(detail)
    if not secret_id:
        return

    config = load_config()
    replicate_secret(secret_id, config)
