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
  # Here we define the multi-account/multi-region/multi-KMS structure
  destinations = {
    "111111111111" = {
      role_arn = "arn:aws:iam::111111111111:role/secrets-dr-replication-role"
      regions = {
        "us-east-1" = {
          kms_key_arn = "arn:aws:kms:us-east-1:111111111111:key/abc123"
          source_secret_arn = "arn:aws:secretsmanager:us-east-1:111111111111:secret:example-source-secret-abc123"
          destination_secret_arn = "arn:aws:secretsmanager:us-east-1:111111111111:secret:example-dest-secret-xyz789"
        }
        "eu-central-1" = {
          kms_key_arn = "arn:aws:kms:eu-central-1:111111111111:key/def456"
          source_secret_arn = "arn:aws:secretsmanager:eu-central-1:111111111111:secret:example-source-secret-def456"
          destination_secret_arn = "arn:aws:secretsmanager:eu-central-1:111111111111:secret:example-dest-secret-uvw000"
        }
      }
    }

    "222222222222" = {
      role_arn = "arn:aws:iam::222222222222:role/secrets-dr-replication-role"
      regions = {
        "us-east-1" = {
          kms_key_arn = "arn:aws:kms:us-east-1:222222222222:key/xyz789"
          source_secret_arn = "arn:aws:secretsmanager:us-east-1:222222222222:secret:example-source-secret-xyz789"
          destination_secret_arn = "arn:aws:secretsmanager:us-east-1:222222222222:secret:example-dest-secret-abc111"
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
  # Adjust this path to where you have the module:
  # for example: "../modules/secrets-dr-replication"
  source = "../../"

  name = "secrets-dr-replication"

  prefix = "secretsmanager-replication"

  destinations_json    = local.destinations_json
  allowed_assume_roles = local.allowed_assume_roles

  # environment_variables can be used to pass additional custom variables if needed

  lambda_timeout     = 10
  lambda_memory      = 128
  eventbridge_enabled = true

  tags = {
    Project = "SecretsDR"
    Owner   = "PlatformTeam"
  }
}

output "lambda_arn" {
  value = module.secrets_dr_replication.lambda_automatic_replication_arn
}

output "eventbridge_rule_arn" {
  value = module.secrets_dr_replication.eventbridge_rule_arn
}
