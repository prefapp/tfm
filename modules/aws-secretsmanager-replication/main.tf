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


###############################################################################
# Locals (safe for count = 0)
###############################################################################

locals {
  decoded_existing_bucket_policy            = var.existing_bucket_policy_json != null ? jsondecode(var.existing_bucket_policy_json) : null
  decoded_existing_bucket_policy_statements = local.decoded_existing_bucket_policy != null ? try(local.decoded_existing_bucket_policy.Statement, []) : []

  kms_key_arns = flatten([
    for dest in local.parsed_destinations : [
      for region_name, region_cfg in try(dest.regions, {}) : region_cfg.kms_key_arn
    ]
  ])

  using_existing_cloudtrail = var.cloudtrail_name != ""
  using_existing_s3_bucket  = var.s3_bucket_name != ""

  # For existing CloudTrail, use the provided ARN and name directly
  cloudtrail_arn  = var.cloudtrail_arn != "" ? var.cloudtrail_arn : (length(aws_cloudtrail.secrets_management_events.*.arn) > 0 ? aws_cloudtrail.secrets_management_events[0].arn : null)
  cloudtrail_name = var.cloudtrail_name != "" ? var.cloudtrail_name : (length(aws_cloudtrail.secrets_management_events.*.name) > 0 ? aws_cloudtrail.secrets_management_events[0].name : null)

  s3_bucket_id       = local.using_existing_s3_bucket ? var.s3_bucket_name : (length(aws_s3_bucket.cloudtrail) > 0 ? aws_s3_bucket.cloudtrail[0].id : null)
  s3_bucket_arn      = local.using_existing_s3_bucket ? format("arn:aws:s3:::%s", var.s3_bucket_name) : (length(aws_s3_bucket.cloudtrail) > 0 ? aws_s3_bucket.cloudtrail[0].arn : null)
  s3_bucket_logs_arn = local.using_existing_s3_bucket ? format("arn:aws:s3:::%s/AWSLogs/%s/*", var.s3_bucket_name, data.aws_caller_identity.current.account_id) : (length(aws_s3_bucket.cloudtrail) > 0 ? "${aws_s3_bucket.cloudtrail[0].arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*" : null)

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

  source_path = [
    "${path.module}/src/lambda_automatic_replication",
    "${path.module}/src/common"
  ]

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
        # Allow reading any secret in the account (for DR/backup)
        {
          Sid    = "AllowGetSecretValueAllSecrets"
          Effect = "Allow"
          Action = [
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret",
            "secretsmanager:ListSecretVersionIds",
            "secretsmanager:GetResourcePolicy"
          ]
          Resource = "*"
        },
        {
          Sid    = "ManageDestinationSecretsDynamic"
          Effect = "Allow"
          Action = [
            "secretsmanager:PutSecretValue",
            "secretsmanager:UpdateSecret",
            "secretsmanager:DescribeSecret",
            "secretsmanager:TagResource",
            "secretsmanager:UntagResource",
            "secretsmanager:UpdateSecretVersionStage",
            "secretsmanager:ListSecretVersionIds"
          ]
          Resource = "*"
        },
        {
          Sid      = "CreateSecretDynamic"
          Effect   = "Allow"
          Action   = ["secretsmanager:CreateSecret"]
          Resource = "*"
        },

        length(var.allowed_assume_roles) > 0 ? {
          Sid      = "AssumeDestinationRoles"
          Effect   = "Allow"
          Action   = ["sts:AssumeRole"]
          Resource = var.allowed_assume_roles
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

  source_path = [
    "${path.module}/src/lambda_manual_replication",
    "${path.module}/src/common"
  ]

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
        {
          Sid    = "SecretsManagerReadAll"
          Effect = "Allow"
          Action = [
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret"
          ]
          Resource = "*"
        },
        {
          Sid    = "SecretsManagerWrite"
          Effect = "Allow"
          Action = [
            "secretsmanager:PutSecretValue",
            "secretsmanager:UpdateSecret",
            "secretsmanager:TagResource",
            "secretsmanager:UntagResource"
          ]
          Resource = "*"
        },
        # Separate statement for CreateSecret with Resource = "*" and restrictive condition
        {
          Sid      = "CreateSecretDynamic"
          Effect   = "Allow"
          Action   = ["secretsmanager:CreateSecret"]
          Resource = "*"
        },
        length(var.allowed_assume_roles) > 0 ? {
          Sid      = "AssumeCrossAccountRoles"
          Effect   = "Allow"
          Action   = ["sts:AssumeRole"]
          Resource = var.allowed_assume_roles
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

# Strict S3 bucket policy: only when both bucket and trail are existing (safe to use SourceArn)
resource "aws_s3_bucket_policy" "cloudtrail_strict" {
  count  = var.eventbridge_enabled && var.manage_s3_bucket_policy && var.s3_bucket_name != "" && var.cloudtrail_name != "" ? 1 : 0
  bucket = var.s3_bucket_name

  lifecycle {
    precondition {
      condition     = !(var.cloudtrail_name != "" && var.cloudtrail_arn == "")
      error_message = "If cloudtrail_name is set, cloudtrail_arn must also be provided unless the module is creating the CloudTrail. This precondition prevents creating a policy with an invalid SourceArn reference."
    }
  }

  policy = (
    var.existing_bucket_policy_json != null ?
    jsonencode(merge(
      local.decoded_existing_bucket_policy,
      {
        Statement = concat(
          local.decoded_existing_bucket_policy_statements,
          [
            {
              Sid       = "AWSCloudTrailAclCheck"
              Effect    = "Allow"
              Principal = { Service = "cloudtrail.amazonaws.com" }
              Action    = ["s3:GetBucketAcl", "s3:GetBucketPolicy"]
              Resource  = local.s3_bucket_arn
              Condition = merge({
                StringEquals = {
                  "aws:SourceAccount" = data.aws_caller_identity.current.account_id
                }
                }, {
                ArnLike = {
                  "aws:SourceArn" = local.cloudtrail_arn
                }
              })
            },
            {
              Sid       = "AWSCloudTrailWrite"
              Effect    = "Allow"
              Principal = { Service = "cloudtrail.amazonaws.com" }
              Action    = "s3:PutObject"
              Resource  = local.s3_bucket_logs_arn
              Condition = merge({
                StringEquals = {
                  "s3:x-amz-acl"      = "bucket-owner-full-control"
                  "aws:SourceAccount" = data.aws_caller_identity.current.account_id
                }
                }, {
                ArnLike = {
                  "aws:SourceArn" = local.cloudtrail_arn
                }
              })
            }
          ]
        )
      }
    ))
    : jsonencode({
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
          Condition = merge({
            StringEquals = {
              "aws:SourceAccount" = data.aws_caller_identity.current.account_id
            }
            }, {
            ArnLike = {
              "aws:SourceArn" = local.cloudtrail_arn
            }
          })
        },
        {
          Sid       = "AWSCloudTrailWrite"
          Effect    = "Allow"
          Principal = { Service = "cloudtrail.amazonaws.com" }
          Action    = "s3:PutObject"
          Resource  = local.s3_bucket_logs_arn
          Condition = merge({
            StringEquals = {
              "s3:x-amz-acl"      = "bucket-owner-full-control"
              "aws:SourceAccount" = data.aws_caller_identity.current.account_id
            }
            }, {
            ArnLike = {
              "aws:SourceArn" = local.cloudtrail_arn
            }
          })
        }
      ]
    })
  )
}

# Fallback S3 bucket policy: all other cases (never references local.cloudtrail_arn)
resource "aws_s3_bucket_policy" "cloudtrail" {
  count  = var.eventbridge_enabled && var.manage_s3_bucket_policy && !(var.s3_bucket_name != "" && var.cloudtrail_name != "") && (var.s3_bucket_name != "" || length(aws_s3_bucket.cloudtrail) > 0) ? 1 : 0
  bucket = var.s3_bucket_name != "" ? var.s3_bucket_name : aws_s3_bucket.cloudtrail[0].id

  policy = (
    var.s3_bucket_name != "" && var.existing_bucket_policy_json != null ?
    jsonencode(merge(
      local.decoded_existing_bucket_policy,
      {
        Statement = concat(
          local.decoded_existing_bucket_policy_statements,
          [
            {
              Sid       = "AWSCloudTrailAclCheck"
              Effect    = "Allow"
              Principal = { Service = "cloudtrail.amazonaws.com" }
              Action    = ["s3:GetBucketAcl", "s3:GetBucketPolicy"]
              Resource  = local.s3_bucket_arn
              Condition = {
                StringEquals = {
                  "aws:SourceAccount" = data.aws_caller_identity.current.account_id
                }
              }
            },
            {
              Sid       = "AWSCloudTrailWrite"
              Effect    = "Allow"
              Principal = { Service = "cloudtrail.amazonaws.com" }
              Action    = "s3:PutObject"
              Resource  = local.s3_bucket_logs_arn
              Condition = {
                StringEquals = {
                  "s3:x-amz-acl"      = "bucket-owner-full-control"
                  "aws:SourceAccount" = data.aws_caller_identity.current.account_id
                }
              }
            }
          ]
        )
      }
    ))
    : jsonencode({
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
          Condition = {
            StringEquals = {
              "aws:SourceAccount" = data.aws_caller_identity.current.account_id
            }
          }
        },
        {
          Sid       = "AWSCloudTrailWrite"
          Effect    = "Allow"
          Principal = { Service = "cloudtrail.amazonaws.com" }
          Action    = "s3:PutObject"
          Resource  = local.s3_bucket_logs_arn
          Condition = {
            StringEquals = {
              "s3:x-amz-acl"      = "bucket-owner-full-control"
              "aws:SourceAccount" = data.aws_caller_identity.current.account_id
            }
          }
        }
      ]
    })
  )
}

