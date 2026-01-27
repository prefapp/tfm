from src.replication import replicate_secret
from src.config import load_config
from src.utils import log


def lambda_handler(event, context):
    log("info", "Lambda triggered", raw_event=event)

    try:
        secret_id = event["detail"]["requestParameters"]["secretId"]
    except Exception as e:
        log("error", "Invalid event format", error=str(e))
        return {"status": "error", "error": "Invalid event format"}

    config = load_config()

    try:
        replicate_secret(secret_id, config)
        return {"status": "ok", "secret_id": secret_id}
    except Exception as e:
        log("error", "Unhandled error during replication", secret_id=secret_id, error=str(e))
        return {"status": "error", "secret_id": secret_id}
