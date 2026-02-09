import logging
from src.config import load_config
from src.replication import replicate_secret

LOG = logging.getLogger()
LOG.setLevel(logging.INFO)

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
    if secret_id:
        LOG.info("Manual replication of %s", secret_id)
        config = load_config()
        replicate_secret(secret_id, config)
        return
    LOG.warning("No secret_id provided and full sync is not supported in this handler.")
