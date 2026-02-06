import boto3
import logging


def log(level: str, message: str, **kwargs):
    """
    Structured logging helper.
    Usage:
        log("info", "Replicating secret", secret_id=secret_id)
    """
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)

    extra = {"extra": kwargs} if kwargs else {}

    if level == "info":
        logger.info(message, **extra)
    elif level == "warning":
        logger.warning(message, **extra)
    elif level == "error":
        logger.error(message, exc_info=True, **extra)
    else:
        logger.debug(message, **extra)


def assume_role(role_arn: str, region: str, session_name: str = "replication-session"):
    """
    Assume a cross-account IAM role and return a Secrets Manager client
    using the temporary credentials.
    """
    sts = boto3.client("sts")

    response = sts.assume_role(
        RoleArn=role_arn,
        RoleSessionName=session_name,
    )

    creds = response["Credentials"]

    session = boto3.Session(
        aws_access_key_id=creds["AccessKeyId"],
        aws_secret_access_key=creds["SecretAccessKey"],
        aws_session_token=creds["SessionToken"],
        region_name=region,
    )

    return session.client("secretsmanager")
