import boto3
import logging
import os

# Configure root logger level once, honoring LOG_LEVEL env var if set
_log_level = os.environ.get("LOG_LEVEL", "INFO").upper()
logging.getLogger().setLevel(getattr(logging, _log_level, logging.INFO))


def log(level: str, message: str, **kwargs):
    """
    Structured logging helper for consistent log output.
    Args:
        level (str): Log level (info, warning, error, debug).
        message (str): Log message.
        **kwargs: Additional context for the log.
    Returns:
        None
    """

    logger = logging.getLogger()

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
    Assume a cross-account IAM role and return a Secrets Manager client using the temporary credentials.
    Args:
        role_arn (str): ARN of the role to assume.
        region (str): AWS region for the client.
        session_name (str): Session name for the assumed role.
    Returns:
        boto3.client: Boto3 Secrets Manager client with assumed credentials.
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
