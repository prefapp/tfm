import boto3
import logging
import time
import re
from botocore.exceptions import ClientError

LOG = logging.getLogger()
LOG.setLevel(logging.INFO)

RETRY_MAX = 3
RETRY_BASE = 0.5
HEX_SUFFIX = re.compile(r"^[0-9a-fA-F]{6}$")


def retry(fn, *args, **kwargs):
    """
    Executes a function with retry logic for transient AWS errors.
    Args:
        fn: Function to execute.
        *args: Positional arguments for the function.
        **kwargs: Keyword arguments for the function.
    Returns:
        The result of the function call.
    Raises:
        ClientError: If the maximum number of retries is exceeded or for non-retryable errors.
    """
    for attempt in range(1, RETRY_MAX + 1):
        try:
            return fn(*args, **kwargs)
        except ClientError as e:
            code = e.response.get("Error", {}).get("Code", "")
            if attempt == RETRY_MAX or code in ("AccessDeniedException", "InvalidRequestException"):
                raise
            time.sleep(RETRY_BASE * (2 ** (attempt - 1)))


def assume_role(role_arn):
    """
    Assumes an AWS IAM role and returns temporary credentials.
    Args:
        role_arn (str): ARN of the role to assume.
    Returns:
        dict: Temporary credentials for the assumed role.
    """
    sts = boto3.client("sts")
    resp = sts.assume_role(RoleArn=role_arn, RoleSessionName="secrets-sync")
    creds = resp["Credentials"]
    return {
        "aws_access_key_id": creds["AccessKeyId"],
        "aws_secret_access_key": creds["SecretAccessKey"],
        "aws_session_token": creds["SessionToken"],
    }


def extract_secret_name(arn):
    """
    Extracts the real secret name from a Secrets Manager ARN, removing the random 6-character suffix if present.
    Args:
        arn (str): The ARN of the secret.
    Returns:
        str: The extracted secret name without the random suffix.
    """
    # Extracts the real secret name from the ARN
    # ARN format: arn:aws:secretsmanager:region:account-id:secret:secret-name-6chars
    # The name may contain dashes, so only remove the random suffix
    name_with_suffix = arn.split(":secret:")[1]
    # The random suffix is always 6 hex characters after the last dash
    if "-" in name_with_suffix:
        base, suffix = name_with_suffix.rsplit("-", 1)
        if HEX_SUFFIX.match(suffix):
            return base
    return name_with_suffix


def ensure_destination_secret(dest_client, name, secret_string=None, secret_binary=None, kms_key=None):
    """
    Ensures the destination secret exists and is updated with the provided value.
    Args:
        dest_client: Boto3 client for destination Secrets Manager.
        name (str): Name of the secret.
        secret_string (str, optional): Secret value as string.
        secret_binary (bytes, optional): Secret value as binary.
        kms_key (str, optional): KMS key ARN for encryption.
    Returns:
        dict: Response from create_secret or put_secret_value.
    Raises:
        ClientError: If AWS API calls fail.
    """
    try:
        if secret_string is not None:
            return retry(dest_client.create_secret,
                         Name=name,
                         SecretString=secret_string,
                         KmsKeyId=kms_key)
        else:
            return retry(dest_client.create_secret,
                         Name=name,
                         SecretBinary=secret_binary,
                         KmsKeyId=kms_key)
    except ClientError as e:
        if e.response["Error"]["Code"] in ("ResourceExistsException", "InvalidRequestException"):
            if secret_string is not None:
                return retry(dest_client.put_secret_value,
                             SecretId=name,
                             SecretString=secret_string)
            else:
                return retry(dest_client.put_secret_value,
                             SecretId=name,
                             SecretBinary=secret_binary)
        raise


def replicate_tags(dest_client, secret_id, tags):
    """
    Replicates tags to the destination secret.
    Args:
        dest_client: Boto3 client for destination Secrets Manager.
        secret_id (str): ID or name of the secret.
        tags (list): List of tags to apply.
    Returns:
        None
    """
    if not tags:
        return
    try:
        retry(dest_client.tag_resource, SecretId=secret_id, Tags=tags)
    except ClientError as e:
        LOG.warning("Tag replication failed for %s: %s", secret_id, e)


def replicate_one(secret_id):
    """
    Replicates a single secret to all configured destinations.
    Args:
        secret_id (str): ID or name of the secret to replicate.
    Returns:
        None
    """
    src_client = boto3.client("secretsmanager")

    try:
        src_val = get_secret_value(src_client, secret_id)
    except ClientError as e:
        LOG.exception("Failed to read source secret %s: %s", secret_id, e)
        return

    secret_string = src_val.get("SecretString") or src_val.get("SecretBinary")

    tags = []
    if ENABLE_TAGS:
        try:
            desc = retry(src_client.describe_secret, SecretId=secret_id)
            tags = desc.get("Tags", [])
        except ClientError:
            LOG.warning("Could not read tags for %s", secret_id)

    for dest_account, cfg in DESTINATIONS.items():
        role_arn = cfg.get("role_arn")
        if not role_arn:
            LOG.warning("No role_arn for destination %s, skipping", dest_account)
            continue

        for region, rcfg in cfg.get("regions", {}).items():
            kms_key = rcfg.get("kms_key_arn")
            creds = assume_role(role_arn)
            dest_client = boto3.client("secretsmanager", region_name=region, **creds)
            dest_name = extract_secret_name(secret_id)

            try:
                ensure_destination_secret(dest_client, dest_name, secret_string, kms_key)
            except ClientError as e:
                LOG.exception("Failed to create/put secret in %s/%s: %s", dest_account, region, e)
                continue

            if ENABLE_TAGS and tags:
                replicate_tags(dest_client, dest_name, tags)

    LOG.info("Replication completed for %s", secret_id)



def replicate_all():
    """
    Replicates all secrets from the source account to all destinations.
    Returns:
        None
    """
    LOG.info("Starting full sync of all secrets")
    src_client = boto3.client("secretsmanager")
    paginator = src_client.get_paginator("list_secrets")

    for page in paginator.paginate():
        for secret in page.get("SecretList", []):
            name = secret["Name"]
            LOG.info("Replicating secret %s", name)
            try:
                replicate_one(name)
            except Exception as e:
                LOG.error("Failed to replicate %s: %s", name, e)

    LOG.info("Full sync completed")


def lambda_handler(event, context):
    """
    AWS Lambda entry point. Replicates a single secret if 'secret_id' is provided in the event, otherwise performs a full sync.
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
        replicate_one(secret_id)
        return

    LOG.info("No secret_id provided, performing full sync")
    replicate_all()
