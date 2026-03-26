import boto3
import logging
import os
import json

# Configure root logger level once, honoring LOG_LEVEL env var if set
_log_level = os.environ.get("LOG_LEVEL", "INFO").upper()
logging.getLogger().setLevel(getattr(logging, _log_level, logging.INFO))


def log(level: str, message: str, exc_info=None, **kwargs):
    """
    Structured logging helper for consistent log output.
    Args:
        level (str): Log level (info, warning, error, debug).
        message (str): Log message.
        exc_info (bool|None): Whether to include exception info (only for error logs).
        **kwargs: Additional context for the log.
    Returns:
        None
    """

    logger = logging.getLogger()

    # Normalize log level to lower case and accept standard levels
    level_normalized = level.lower()
    if level_normalized not in ["info", "warning", "error", "debug"]:
        level_normalized = "debug"

    # Serialize kwargs as JSON and append to message for CloudWatch visibility
    if kwargs:
        try:
            message = f"{message} | context: {json.dumps(kwargs, default=str, sort_keys=True)}"
        except Exception:
            message = f"{message} | context: {kwargs}"

    if level_normalized == "info":
        logger.info(message)
    elif level_normalized == "warning":
        logger.warning(message)
    elif level_normalized == "error":
        logger.error(message, exc_info=exc_info if exc_info is not None else False)
    else:
        logger.debug(message)

