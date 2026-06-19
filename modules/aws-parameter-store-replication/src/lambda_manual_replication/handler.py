# lambda_manual_replication/handler.py
from replication import replicate_parameter
from config import load_config
from utils import log
import boto3
import json


def lambda_handler(event, context):
    """
    AWS Lambda entry point for manual parameter replication.
    Can be triggered via:
    - API invocation with parameter_name in payload
    - Full sync if ENABLE_FULL_SYNC=true

    Args:
        event (dict): Lambda event data. Expected format:
            {
                "parameter_name": "my-parameter"  # Optional, for manual replication
            }
        context: Lambda context object.
    Returns:
        dict: Result of the replication.
    """
    config = load_config()

    parameter_name = event.get("parameter_name")

    event_enable_full_sync = event.get("enable_full_sync", None)
    if event_enable_full_sync is None:
        enable_full_sync = config.enable_full_sync
    elif isinstance(event_enable_full_sync, bool):
        enable_full_sync = event_enable_full_sync
    elif isinstance(event_enable_full_sync, str):
        enable_full_sync = event_enable_full_sync.strip().lower() in ("1", "true", "yes", "on")
    else:
        enable_full_sync = bool(event_enable_full_sync)

    if enable_full_sync:
        # Full account sync: list all parameters and replicate each one
        log("info", "Starting full sync of all parameters")

        source_ssm = boto3.client("ssm", region_name=config.source_region)
        # Reuse the same source client for per-parameter replication to avoid
        # creating a new boto3 SSM client on every iteration.
        config.source_ssm = source_ssm

        paginator = source_ssm.get_paginator("describe_parameters")
        page_iterator = paginator.paginate()

        replicated_count = 0
        error_count = 0

        for page in page_iterator:
            for param_meta in page.get("Parameters", []):
                try:
                    param_name = param_meta["Name"]
                    log("info", "Replicating parameter in full sync", parameter_name=param_name)
                    replicate_parameter(param_name, config, skip_missing=True)
                    replicated_count += 1
                except Exception as e:
                    log("error", "Failed to replicate parameter in full sync", parameter_name=param_name, error=str(e))
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

    elif parameter_name:
        # Manual replication of a specific parameter
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
                    "message": f"Failed to replicate parameter: {parameter_name}",
                    "error": str(e)
                })
            }

    else:
        log("warning", "No parameter_name provided and full sync disabled")
        return {
            "statusCode": 400,
            "body": json.dumps({
                "message": "Either 'parameter_name' or 'enable_full_sync' must be provided"
            })
        }
