# lambda_automatic_replication/handler.py
import os
from replication import replicate_cross_account_backup
from config import load_config
from utils import log

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
    log("info", "Starting lambda...")
    log("debug", "Triggered event object", event=event)

    detail = event.get("detail", {})

    event_name = event.get("source")
    if event_name not in ("aws.backup"):
        log("warning", "Unsupported event source", event_name=event_name)
        return

    resource_id = extract_resources(event)
    if not resource_id:
        log("warning", "No resource ID found in event", event=event)
        # return

    source_backup_vault_arn = detail.get("sourceBackupVaultArn")
    recovery_point_arn = detail.get("destinationRecoveryPointArn")
    if not source_backup_vault_arn or not recovery_point_arn:
        log("error", "Missing sourceBackupVaultArn or destinationRecoveryPointArn", detail=detail)
        return

    source_backup_vault_name = source_backup_vault_arn.rsplit(":", 1)[-1]

    config = load_config()
    replicate_cross_account_backup([recovery_point_arn], source_backup_vault_name, config)

    log("info", "Finished lambda")
