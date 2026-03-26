# lambda_automatic_replication/handler.py
from replication import replicate_cross_account_backup
from config import load_config

def extract_resources(detail):
    """
    Extracts the resourcers from a CloudTrail event detail.
    Args:
        detail (dict): CloudTrail event detail.
    Returns:
        list or None: The resource ID or ARN, or None if not found.
    """
    rp = detail.get("resources", [])

    return rp if rp else None

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
    backupVaultName = detail.get("backupVaultName")
    event_name = event.get("source")
    if event_name not in ("aws.backup"):
        return
    resource_id = extract_resources(event)
    if not resource_id:
        return
    config = load_config()
    replicate_cross_account_backup(resource_id, backupVaultName, config)
