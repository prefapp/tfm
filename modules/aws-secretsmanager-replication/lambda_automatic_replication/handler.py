# lambda/handler.py
import os
import json
import time
import hashlib
import logging
from botocore.exceptions import ClientError
from src.replication import extract_secret_name
import boto3

LOG = logging.getLogger()
LOG.setLevel(logging.INFO)

DESTINATIONS = json.loads(os.environ.get("DESTINATIONS_JSON", "{}"))
ENABLE_TAGS = os.environ.get("ENABLE_TAG_REPLICATION", "true").lower() == "true"
RETRY_MAX = 3
RETRY_BASE = 0.5


def extract_secret_id(detail):
    rp = detail.get("requestParameters", {})

    # 1. Caso normal: PutSecretValue, UpdateSecret, RotateSecret
    sid = rp.get("secretId") or rp.get("SecretId")
    if sid:
        return sid

    # 2. Caso CreateSecret: solo trae "name"
    name = rp.get("name")
    if name:
        return name

    # 3. Caso raro: CloudTrail a veces mete el ARN en resources
    resources = detail.get("resources", [])
    for r in resources:
        if r.get("type") == "AWS::SecretsManager::Secret":
            return r.get("ARN") or r.get("resourceName")

    return None


def checksum(s):
    return hashlib.sha256((s or "").encode("utf-8")).hexdigest()


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
    resp = sts.assume_role(RoleArn=role_arn, RoleSessionName="secrets-replication")
    creds = resp["Credentials"]
    return {
        "aws_access_key_id": creds["AccessKeyId"],
        "aws_secret_access_key": creds["SecretAccessKey"],
        "aws_session_token": creds["SessionToken"],
    }


def get_secret_value(client, secret_id, version_id=None):
    params = {"SecretId": secret_id}
    if version_id:
        params["VersionId"] = version_id
    return retry(client.get_secret_value, **params)


def ensure_destination_secret(dest_client, name, secret_string, kms_key=None):
    try:
        return retry(dest_client.create_secret, Name=name, SecretString=secret_string, KmsKeyId=kms_key)
    except ClientError as e:
        if e.response["Error"]["Code"] in ("ResourceExistsException", "InvalidRequestException"):
            return retry(dest_client.put_secret_value, SecretId=name, SecretString=secret_string)
        raise


def replicate_tags(dest_client, secret_id, tags):
    if not tags:
        return
    try:
        retry(dest_client.tag_resource, SecretId=secret_id, Tags=tags)
    except ClientError as e:
        LOG.warning("Tag replication failed: %s", e)


def lambda_handler(event, context):
    LOG.info("Received event")
    detail = event.get("detail", {})
    event_name = detail.get("eventName")
    if event_name not in ("CreateSecret", "PutSecretValue", "UpdateSecret", "RotateSecret", "RestoreSecret"):
        LOG.info("Ignoring event %s", event_name)
        return

    secret_id = extract_secret_id(detail)
    if not secret_id:
        LOG.error("Could not extract secret id from event")
        return

    src_client = boto3.client("secretsmanager")
    try:
        src_val = get_secret_value(src_client, secret_id)
    except ClientError as e:
        LOG.exception("Failed to read source secret %s: %s", secret_id, e)
        raise

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
                resp = ensure_destination_secret(dest_client, dest_name, secret_string, kms_key)
            except ClientError as e:
                LOG.exception("Failed to create/put secret in %s/%s: %s", dest_account, region, e)
                raise

            if ENABLE_TAGS and tags:
                replicate_tags(dest_client, dest_name, tags)

    LOG.info("Replication completed for %s", secret_id)
