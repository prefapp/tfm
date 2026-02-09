import logging
from src.config import load_config
from src.replication import replicate_secret, replicate_all

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
    if secret_id:
        LOG.info("Manual replication of %s", secret_id)
        replicate_secret(secret_id, config)
        return
    LOG.info("No secret_id provided, running full sync (replicate all secrets)")
    replicate_all(config)
