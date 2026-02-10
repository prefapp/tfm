terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}

###############################################################################
# Data sources
###############################################################################

data "aws_caller_identity" "current" {}

## Optional: existing CloudTrail

data "aws_cloudtrail" "existing" {
  count = var.cloudtrail_name != "" ? 1 : 0
  name  = var.cloudtrail_name
}


###############################################################################
# Locals (safe for count = 0)
###############################################################################

locals {
  source_secret_arns = flatten([
    for dest in local.parsed_destinations : [
      for region_name, region_cfg in try(dest.regions, {}) : try(region_cfg.source_secret_arn, [])
    ]
  ])
  destination_secret_arns = flatten([
    for dest in local.parsed_destinations : [
      for region_name, region_cfg in try(dest.regions, {}) : try(region_cfg.destination_secret_arn, [])
    ]
  ])
  using_existing_cloudtrail = var.cloudtrail_name != ""
  using_existing_s3_bucket  = var.s3_bucket_name != ""


  # For existing CloudTrail, use the provided name directly
  cloudtrail_arn  = var.cloudtrail_name != "" ? data.aws_cloudtrail.existing[0].arn : (length(aws_cloudtrail.secrets_management_events.*.arn) > 0 ? aws_cloudtrail.secrets_management_events[0].arn : "")
  cloudtrail_name = var.cloudtrail_name != "" ? var.cloudtrail_name : (length(aws_cloudtrail.secrets_management_events.*.name) > 0 ? aws_cloudtrail.secrets_management_events[0].name : "")

  s3_bucket_id       = local.using_existing_s3_bucket ? var.s3_bucket_name : (length(aws_s3_bucket.cloudtrail) > 0 ? aws_s3_bucket.cloudtrail[0].id : "")
  s3_bucket_arn      = local.using_existing_s3_bucket ? format("arn:aws:s3:::%s", var.s3_bucket_name) : (length(aws_s3_bucket.cloudtrail) > 0 ? aws_s3_bucket.cloudtrail[0].arn : "")
  s3_bucket_logs_arn = local.using_existing_s3_bucket ? format("arn:aws:s3:::%s/AWSLogs/%s/*", var.s3_bucket_name, data.aws_caller_identity.current.account_id) : (length(aws_s3_bucket.cloudtrail) > 0 ? "${aws_s3_bucket.cloudtrail[0].arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*" : "")

  has_existing_bucket = var.s3_bucket_name != ""

  # Pass DESTINATIONS_JSON and enable_tag_replication as environment variables to the Lambda
  # Note: Terraform-provided values override any conflicting keys in var.environment_variables
  environment = merge(
    var.environment_variables,
    {
      DESTINATIONS_JSON      = var.destinations_json
      ENABLE_TAG_REPLICATION = tostring(var.enable_tag_replication)
    }
  )

  parsed_destinations = try(jsondecode(var.destinations_json), {})
  kms_key_arns = flatten([
    for dest in local.parsed_destinations : [
      for region_name, region_cfg in try(dest.regions, {}) : region_cfg.kms_key_arn
    ]
  ])
}

###############################################################################
# Random suffix for bucket name when creating
###############################################################################

resource "random_integer" "suffix" {
  count = var.s3_bucket_name == "" && var.eventbridge_enabled ? 1 : 0
  min   = 10000
  max   = 99999
}

###############################################################################
# Lambda using the official module
###############################################################################

module "lambda_automatic_replication" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 7.0"

  function_name = "${var.name}-automatic"
  handler       = "handler.lambda_handler"
  runtime       = "python3.12"

  source_path = "${path.module}/lambda_automatic_replication"

  timeout     = var.lambda_timeout
  memory_size = var.lambda_memory
  tags        = var.tags

  environment_variables = local.environment

  attach_cloudwatch_logs_policy = false

  # Extra IAM permissions for Secrets Manager + STS
  attach_policy_json = true

  policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      for s in [
        length(local.source_secret_arns) > 0 ? {
          Sid    = "AllowReplicationRole"
          Effect = "Allow"
          Action = [
            "secretsmanager:DescribeSecret",
            "secretsmanager:GetSecretValue",
            "secretsmanager:ListSecretVersionIds",
            "secretsmanager:GetResourcePolicy"
          ]
          Resource = local.source_secret_arns
        } : null,
        length(local.destination_secret_arns) > 0 ? {
          Sid    = "ManageDestinationSecrets"
          Effect = "Allow"
          Action = [
            "secretsmanager:CreateSecret",
            "secretsmanager:PutSecretValue",
            "secretsmanager:UpdateSecret",
            "secretsmanager:DescribeSecret",
            "secretsmanager:TagResource",
            "secretsmanager:UntagResource",
            "secretsmanager:UpdateSecretVersionStage",
            "secretsmanager:ListSecretVersionIds"
          ]
          Resource = local.destination_secret_arns
        } : null,
        length(var.allowed_assume_roles) > 0 ? {
          Sid      = "AssumeDestinationRoles"
          Effect   = "Allow"
          Action   = ["sts:AssumeRole"]
          Resource = var.allowed_assume_roles
        } : null,
        length(local.kms_key_arns) > 0 ? {
          Sid    = "KMSUsage"
          Effect = "Allow"
          Action = [
            "kms:Decrypt",
            "kms:GenerateDataKey",
            "kms:Encrypt",
            "kms:ReEncrypt*",
            "kms:DescribeKey"
          ]
          Resource = local.kms_key_arns
        } : null
      ] : s if s != null
    ]
  })
}


resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = module.lambda_automatic_replication.lambda_role_name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


################################################################################
# Lambda for manual secret replication (triggered via API or console, not EventBridge)
################################################################################
module "lambda_manual_replication" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 7.0"

  count = var.manual_replication_enabled ? 1 : 0

  function_name = "${var.name}-manual"
  handler       = "handler.lambda_handler"
  runtime       = "python3.12"

  source_path = "${path.module}/lambda_manual_replication"

  timeout     = var.lambda_timeout
  memory_size = var.lambda_memory
  tags        = var.tags

  environment_variables = merge(
    var.environment_variables,
    {
      DESTINATIONS_JSON      = var.destinations_json
      ENABLE_TAG_REPLICATION = tostring(var.enable_tag_replication)
      ENABLE_FULL_SYNC       = tostring(var.enable_full_sync)
    }
  )

  attach_cloudwatch_logs_policy = false

  attach_policy_json = true
  policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      for s in [
        var.enable_full_sync ? {
          # allow reading and listing all secrets for all-secret-replication use case
          Sid    = "SecretsManagerFullSyncRead"
          Effect = "Allow"
          Action = [
            "secretsmanager:ListSecrets",
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret"
          ]
          Resource = "*"
        } : null,
        length(local.source_secret_arns) > 0 ? {
          Sid    = "SecretsManagerRead"
          Effect = "Allow"
          Action = [
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret"
          ]
          Resource = local.source_secret_arns
        } : null,
        length(local.destination_secret_arns) > 0 ? {
          Sid    = "SecretsManagerWrite"
          Effect = "Allow"
          Action = [
            "secretsmanager:CreateSecret",
            "secretsmanager:PutSecretValue",
            "secretsmanager:UpdateSecret",
            "secretsmanager:TagResource",
            "secretsmanager:UntagResource"
          ]
          Resource = local.destination_secret_arns
        } : null,
        length(var.allowed_assume_roles) > 0 ? {
          Sid      = "AssumeCrossAccountRoles"
          Effect   = "Allow"
          Action   = ["sts:AssumeRole"]
          Resource = var.allowed_assume_roles
        } : null,
        length(local.kms_key_arns) > 0 ? {
          Sid    = "KMSUsage"
          Effect = "Allow"
          Action = [
            "kms:Decrypt",
            "kms:Encrypt",
            "kms:GenerateDataKey",
            "kms:DescribeKey",
            "kms:ReEncrypt*"
          ]
          Resource = local.kms_key_arns
        } : null
      ] : s if s != null
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_manual_basic_execution" {
  count      = var.manual_replication_enabled ? 1 : 0
  role       = module.lambda_manual_replication[0].lambda_role_name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}



###############################################################################
# S3 bucket for CloudTrail (create only if not provided)
###############################################################################

resource "aws_s3_bucket" "cloudtrail" {
  count         = var.s3_bucket_name == "" && var.eventbridge_enabled ? 1 : 0
  bucket        = var.s3_bucket_name != "" ? var.s3_bucket_name : "${var.prefix}-cloudtrail-${data.aws_caller_identity.current.account_id}-${random_integer.suffix[0].result}"
  force_destroy = false
  tags          = var.tags
}

# Baseline hardening for CloudTrail S3 bucket
resource "aws_s3_bucket_public_access_block" "cloudtrail" {
  count  = var.s3_bucket_name == "" && var.eventbridge_enabled ? 1 : 0
  bucket = aws_s3_bucket.cloudtrail[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail" {
  count  = var.s3_bucket_name == "" && var.eventbridge_enabled ? 1 : 0
  bucket = aws_s3_bucket.cloudtrail[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

###############################################################################
# CloudTrail (create only if not provided)
###############################################################################

resource "aws_cloudtrail" "secrets_management_events" {
  count                         = var.cloudtrail_name == "" && var.eventbridge_enabled ? 1 : 0
  name                          = "${var.prefix}-secrets-management-events"
  is_multi_region_trail         = false
  include_global_service_events = false
  enable_logging                = true
  s3_bucket_name                = local.s3_bucket_id

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }

  tags = var.tags

  depends_on = [aws_s3_bucket_policy.cloudtrail]
}

###############################################################################
# S3 bucket policy (manage only if requested and bucket is known)
###############################################################################

resource "aws_s3_bucket_policy" "cloudtrail" {
  count  = var.eventbridge_enabled && var.manage_s3_bucket_policy && (var.s3_bucket_name != "" || length(aws_s3_bucket.cloudtrail) > 0) ? 1 : 0
  bucket = var.s3_bucket_name != "" ? var.s3_bucket_name : aws_s3_bucket.cloudtrail[0].id

  policy = var.s3_bucket_name != "" && var.existing_bucket_policy_json != null ? (
    jsonencode(merge(
      jsondecode(var.existing_bucket_policy_json),
      {
        Statement = concat(
          try(jsondecode(var.existing_bucket_policy_json).Statement, []),
          [
            {
              Sid       = "AWSCloudTrailAclCheck"
              Effect    = "Allow"
              Principal = { Service = "cloudtrail.amazonaws.com" }
              Action    = ["s3:GetBucketAcl", "s3:GetBucketPolicy"]
              Resource  = local.s3_bucket_arn
            },
            {
              Sid       = "AWSCloudTrailWrite"
              Effect    = "Allow"
              Principal = { Service = "cloudtrail.amazonaws.com" }
              Action    = "s3:PutObject"
              Resource  = local.s3_bucket_logs_arn
              Condition = {
                StringEquals = {
                  "s3:x-amz-acl" = "bucket-owner-full-control"
                }
              }
            }
          ]
        )
      }
    ))
    ) : jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid       = "AWSCloudTrailAclCheck"
          Effect    = "Allow"
          Principal = { Service = "cloudtrail.amazonaws.com" }
          Action = [
            "s3:GetBucketAcl",
            "s3:GetBucketPolicy"
          ]
          Resource = local.s3_bucket_arn
        },
        {
          Sid       = "AWSCloudTrailWrite"
          Effect    = "Allow"
          Principal = { Service = "cloudtrail.amazonaws.com" }
          Action    = "s3:PutObject"
          Resource  = local.s3_bucket_logs_arn
          Condition = {
            StringEquals = {
              "s3:x-amz-acl" = "bucket-owner-full-control"
            }
          }
        }
      ]
  })
}


check "input_validation" {
  assert {
    condition = !(
      var.eventbridge_enabled && var.s3_bucket_name == "" && !var.manage_s3_bucket_policy
    )
    error_message = "If the module is creating the CloudTrail S3 bucket (s3_bucket_name == '' and eventbridge_enabled = true), manage_s3_bucket_policy must be true. Otherwise, CloudTrail log delivery will fail due to missing bucket policy."
  }
  assert {
    condition     = !(var.eventbridge_enabled && var.cloudtrail_name != "" && var.s3_bucket_name == "")
    error_message = "You provided cloudtrail_name but not s3_bucket_name. Provide the S3 bucket name used by that trail."
  }
  assert {
    condition = !(
      var.manage_s3_bucket_policy && var.s3_bucket_name != "" && var.existing_bucket_policy_json == null
    )
    error_message = "When managing the policy on an existing S3 bucket (s3_bucket_name set), you must provide existing_bucket_policy_json to avoid overwriting existing statements."
  }
}
