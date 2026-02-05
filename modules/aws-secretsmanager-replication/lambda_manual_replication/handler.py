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
    for attempt in range(1, RETRY_MAX + 1):
        try:
            return fn(*args, **kwargs)
        except ClientError as e:
            code = e.response.get("Error", {}).get("Code", "")
            if attempt == RETRY_MAX or code in ("AccessDeniedException", "InvalidRequestException"):
                raise
            time.sleep(RETRY_BASE * (2 ** (attempt - 1)))


def assume_role(role_arn):
    sts = boto3.client("sts")
    resp = sts.assume_role(RoleArn=role_arn, RoleSessionName="secrets-sync")
    creds = resp["Credentials"]
    return {
        "aws_access_key_id": creds["AccessKeyId"],
        "aws_secret_access_key": creds["SecretAccessKey"],
        "aws_session_token": creds["SessionToken"],
    }


def extract_secret_name(arn):
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
    if not tags:
        return
    try:
        retry(dest_client.tag_resource, SecretId=secret_id, Tags=tags)
    except ClientError as e:
        LOG.warning("Tag replication failed for %s: %s", secret_id, e)


def lambda_handler(event, context):
    LOG.info("Received sync request: %s", event)

    origin = event["origin"]
    destination = event["destination"]

    origin_account = origin["account"]
    origin_region = origin["region"]

    dest_account = destination["account"]
    dest_region = destination["region"]

    kms_key = event.get("kms_key_arn")

    # Roles simétricos en ambas cuentas
    origin_role = f"arn:aws:iam::{origin_account}:role/SecretsReplicationRole"
    dest_role = f"arn:aws:iam::{dest_account}:role/SecretsReplicationRole"

    origin_creds = assume_role(origin_role)
    dest_creds = assume_role(dest_role)

    src = boto3.client("secretsmanager", region_name=origin_region, **origin_creds)
    dest = boto3.client("secretsmanager", region_name=dest_region, **dest_creds)

    paginator = src.get_paginator("list_secrets")

    for page in paginator.paginate():
        for secret in page["SecretList"]:
            arn = secret["ARN"]
            name = extract_secret_name(arn)

            LOG.info("Syncing secret %s", name)

            try:
                val = retry(src.get_secret_value, SecretId=arn)
            except ClientError as e:
                LOG.error("Could not read %s: %s", arn, e)
                continue

            secret_string = val.get("SecretString")
            secret_binary = val.get("SecretBinary")

            # Tags
            try:
                desc = retry(src.describe_secret, SecretId=arn)
                tags = desc.get("Tags", [])
            except ClientError:
                tags = []

            # Create or update in destination
            try:
                ensure_destination_secret(
                    dest,
                    name,
                    secret_string=secret_string,
                    secret_binary=secret_binary,
                    kms_key=kms_key
                )
            except ClientError as e:
                LOG.error("Failed to sync %s: %s", name, e)
                continue

            if tags:
                replicate_tags(dest, name, tags)

            LOG.info("Synced %s successfully", name)

    LOG.info("Sync completed.")
