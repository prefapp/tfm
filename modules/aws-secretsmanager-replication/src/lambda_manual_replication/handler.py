import logging
import os
from common.config import load_config
from common.replication import replicate_secret, replicate_all

LOG = logging.getLogger()

def lambda_handler(event, context):
    """
    AWS Lambda entry point. Replicates a single secret if 'secret_id' is provided in the event.
    Args:
        event (dict): Lambda event data. May contain 'secret_id'.
        context: Lambda context object.
    Returns:
        None
    """
    LOG.info("Received event")
    secret_id = event.get("secret_id")
    config = load_config()
    enable_full_sync = os.environ.get("ENABLE_FULL_SYNC", "false").lower() == "true"
    if secret_id:
        LOG.info("Manual replication of %s", secret_id)
        replicate_secret(secret_id, config)
        return
    if not enable_full_sync:
        LOG.error("Full sync (replicate_all) requested but ENABLE_FULL_SYNC is not enabled. Refusing to run to avoid AccessDenied.")
        raise Exception("Full sync is not enabled for this Lambda. Set enable_full_sync = true in Terraform to allow this operation.")
    LOG.info("No secret_id provided, running full sync (replicate all secrets)")
    replicate_all(config)
