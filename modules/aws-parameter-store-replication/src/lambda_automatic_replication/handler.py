# lambda_automatic_replication/handler.py
from replication import replicate_parameter
from config import load_config

def extract_parameter_name(detail):
    """
    Extracts the parameter name from a native SSM Parameter Store Change event detail.
    Args:
        detail (dict): EventBridge event detail from aws.ssm source.
    Returns:
        str or None: The parameter name, or None if not found.
    """
    return detail.get("name")

def lambda_handler(event, context):
    """
    AWS Lambda entry point. Handles the event for parameter replication.
    Args:
        event (dict): Lambda event data (native SSM Parameter Store Change event).
        context: Lambda context object.
    Returns:
        None
    """
    detail = event.get("detail", {})
    operation = detail.get("operation")
    if operation not in ("Create", "Update"):
        return

    parameter_name = extract_parameter_name(detail)
    if not parameter_name:
        return

    config = load_config()
    replicate_parameter(parameter_name, config, skip_missing=True)
