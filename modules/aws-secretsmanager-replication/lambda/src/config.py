import json
import os
from dataclasses import dataclass
from typing import Dict


@dataclass
class RegionConfig:
    kms_key_id: str


@dataclass
class Destination:
    role_arn: str
    regions: Dict[str, RegionConfig]  # region_name → RegionConfig



@dataclass
class Config:
    destinations: Dict[str, Destination]
    source_region: str
    enable_tag_replication: bool



def load_config() -> Config:

    # Guarda: no permitir AWS_REGION como variable de entorno externa
    if "AWS_REGION" in os.environ and os.environ.get("AWS_REGION") != os.environ.get("AWS_LAMBDA_FUNCTION_REGION"):
        raise RuntimeError(
            "No se permite establecer AWS_REGION manualmente en las variables de entorno. AWS lo gestiona automáticamente."
        )

    raw = os.environ.get("DESTINATIONS_JSON", "{}")
    parsed = json.loads(raw)

    destinations = {}

    for account_id, entry in parsed.items():
        regions = {
            region_name: RegionConfig(
                kms_key_id=region_cfg["kms_key_id"]
            )
            for region_name, region_cfg in entry["regions"].items()
        }

        destinations[account_id] = Destination(
            role_arn=entry["role_arn"],
            regions=regions,
        )

    source_region = os.environ.get("AWS_REGION", "eu-west-1")
    enable_tag_replication = os.environ.get("ENABLE_TAG_REPLICATION", "true").lower() == "true"

    return Config(
        destinations=destinations,
        source_region=source_region,
        enable_tag_replication=enable_tag_replication,
    )
