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
  destinations = {
    "111111111111" = {
      role_arn = "arn:aws:iam::111111111111:role/secrets-dr-replication-role"
      regions = {
        "eu-west-1" = {
          kms_key_arn = "arn:aws:kms:eu-west-1:111111111111:key/abc123"
        }
      }
    }
  }

  destinations_json = jsonencode(local.destinations)
  allowed_assume_roles = [for v in local.destinations : v.role_arn]
}

module "secrets_dr_replication" {
  source = "../../"

  name = "secrets-dr-replication"
  prefix = "secretsmanager-replication"

  destinations_json    = local.destinations_json
  allowed_assume_roles = local.allowed_assume_roles

  # Specify existing CloudTrail and S3 bucket
  cloudtrail_arn  = "arn:aws:cloudtrail:eu-west-1:111111111111:trail/existing-trail"
  cloudtrail_name = "existing-trail"
  s3_bucket_name  = "existing-cloudtrail-bucket"

  manage_s3_bucket_policy = false # If bucket policy is managed externally

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
