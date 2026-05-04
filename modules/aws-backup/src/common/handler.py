# lambda_automatic_replication/handler.py
from replication import replicate_cross_account_backup
from config import load_config

def extract_resources(event):
    """
    Extracts the resources from an EventBridge event.
    Args:
        event (dict): EventBridge event containing a "resources" field.
    Returns:
        list or None: The list of resource IDs or ARNs, or None if not found.
    """
    rp = event.get("resources", [])

    return rp if rp else None

def lambda_handler(event, context):
    """
    AWS Lambda entry point. Handles AWS Backup events and triggers cross-account backup replication.
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
