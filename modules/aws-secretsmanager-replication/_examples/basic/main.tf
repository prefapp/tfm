terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

locals {
  # Aquí definimos la estructura multi-cuenta/multi-región/multi-KMS
  destinations = {
    "111111111111" = {
      role_arn = "arn:aws:iam::111111111111:role/secrets-dr-replication-role"
      regions = {
        "us-east-1" = {
          kms_key_id = "arn:aws:kms:us-east-1:111111111111:key/abc123"
        }
        "eu-central-1" = {
          kms_key_id = "arn:aws:kms:eu-central-1:111111111111:key/def456"
        }
      }
    }

    "222222222222" = {
      role_arn = "arn:aws:iam::222222222222:role/secrets-dr-replication-role"
      regions = {
        "us-east-1" = {
          kms_key_id = "arn:aws:kms:us-east-1:222222222222:key/xyz789"
        }
      }
    }
  }

  destinations_json = jsonencode(local.destinations)

  allowed_assume_roles = [
    for v in local.destinations : v.role_arn
  ]
}

module "secrets_dr_replication" {
  # Ajusta esta ruta a donde tengas el módulo:
  # por ejemplo: "../modules/secrets-dr-replication"
  source = "../../"

  name = "secrets-dr-replication"

  destinations_json    = local.destinations_json
  allowed_assume_roles = local.allowed_assume_roles

  environment_variables = {
    ENABLE_TAG_REPLICATION = "true"
  }

  lambda_timeout     = 10
  lambda_memory      = 128
  eventbridge_enabled = true

  tags = {
    Project = "SecretsDR"
    Owner   = "PlatformTeam"
  }
}

output "lambda_arn" {
  value = module.secrets_dr_replication.lambda_arn
}

output "eventbridge_rule_arn" {
  value = module.secrets_dr_replication.eventbridge_rule_arn
}
