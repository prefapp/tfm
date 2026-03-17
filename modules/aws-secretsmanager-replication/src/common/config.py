import json
import os
from dataclasses import dataclass
from typing import Dict


@dataclass
class RegionConfig:
    kms_key_arn: str


@dataclass
class Destination:
    role_arn: str
    regions: Dict[str, RegionConfig]  # region_name → RegionConfig


@dataclass
class Config:
    destinations: Dict[str, Destination]
    source_region: str
    enable_tag_replication: bool
    source_account: str
    add_region_prefix_to_name: bool


def load_config() -> Config:
    """
    Loads configuration for secret replication from environment variables and JSON.
    Returns:
        Config: Configuration object with destinations, source region, and tag replication flag.
    """

    raw = os.environ.get("DESTINATIONS_JSON", "{}")
    parsed = json.loads(raw)

    destinations = {}

    for account_id, entry in parsed.items():
        regions = {
            region_name: RegionConfig(
                kms_key_arn=region_cfg.get("kms_key_arn")
            )
            for region_name, region_cfg in entry["regions"].items()
        }

        destinations[account_id] = Destination(
            role_arn=entry["role_arn"],
            regions=regions,
        )

    source_region = os.environ.get("AWS_REGION", "eu-west-1")
    enable_tag_replication = os.environ.get("ENABLE_TAG_REPLICATION", "true").lower() == "true"

    add_region_prefix_to_name = os.environ.get("ADD_REGION_PREFIX_TO_NAME", "false").lower() == "true"

    # Get source account ID automatically
    try:
        import boto3
        source_account = boto3.client("sts").get_caller_identity()["Account"]
    except Exception:
        source_account = ""

    return Config(
        destinations=destinations,
        source_region=source_region,
        enable_tag_replication=enable_tag_replication,
        source_account=source_account,
        add_region_prefix_to_name=add_region_prefix_to_name,
    )
