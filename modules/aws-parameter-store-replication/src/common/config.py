import json
import os
from dataclasses import dataclass
from typing import Any, Dict


@dataclass
class RegionConfig:
    kms_key_arn: str | None


@dataclass
class Destination:
    role_arn: str
    regions: Dict[str, RegionConfig]  # region_name → RegionConfig


@dataclass
class Config:
    destinations: Dict[str, Destination]
    source_region: str
    enable_tag_replication: bool
    enable_full_sync: bool
    assume_role_duration_seconds: int
    source_account: str
    add_region_prefix_to_name: bool
    source_ssm: Any | None = None


def load_config() -> Config:
    """
    Loads configuration for parameter replication from environment variables and JSON.
    Returns:
        Config: Configuration object with destinations, source region, and tag replication flag.
    """

    raw = os.environ.get("DESTINATIONS_JSON", "{}")
    parsed = json.loads(raw)

    destinations = {}

    for account_id, entry in parsed.items():
        regions = {}
        for region_name, region_cfg in entry["regions"].items():
            # Treat non-dict region configs as empty to avoid AttributeError.
            # Invalid types (null, string, etc.) are defaulted to {}, so kms_key_arn will be None.
            if not isinstance(region_cfg, dict):
                region_cfg = {}
            regions[region_name] = RegionConfig(
                kms_key_arn=region_cfg.get("kms_key_arn")
            )

        destinations[account_id] = Destination(
            role_arn=entry["role_arn"],
            regions=regions,
        )

    source_region = os.environ.get("AWS_REGION", "eu-west-1")
    enable_tag_replication = os.environ.get("ENABLE_TAG_REPLICATION", "true").lower() == "true"
    enable_full_sync = os.environ.get("ENABLE_FULL_SYNC", "false").lower() == "true"
    try:
        assume_role_duration_seconds = int(os.environ.get("ASSUME_ROLE_DURATION_SECONDS", "3600"))
    except (TypeError, ValueError):
        assume_role_duration_seconds = 3600
    if assume_role_duration_seconds < 900 or assume_role_duration_seconds > 43200:
        assume_role_duration_seconds = 3600

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
        enable_full_sync=enable_full_sync,
        assume_role_duration_seconds=assume_role_duration_seconds,
        source_account=source_account,
        add_region_prefix_to_name=add_region_prefix_to_name,
    )
