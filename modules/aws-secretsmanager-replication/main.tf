terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

###############################################################################
# Data sources
###############################################################################

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

## Optional: existing CloudTrail
data "aws_cloudtrail" "existing" {
  count = var.cloudtrail_name != "" ? 1 : 0
  name  = var.cloudtrail_name
}

## Optional: existing S3 bucket
data "aws_s3_bucket" "existing_cloudtrail" {
  count  = var.s3_bucket_name != "" ? 1 : 0
  bucket = var.s3_bucket_name
}

## Data source to read the policy of the existing bucket (optional)
data "aws_s3_bucket_policy" "existing" {
  count  = var.s3_bucket_name != "" ? 1 : 0
  bucket = var.s3_bucket_name
}

###############################################################################
# Locals (safe for count = 0)
###############################################################################

locals {
  using_existing_cloudtrail = var.cloudtrail_name != ""
  using_existing_s3_bucket  = var.s3_bucket_name != ""

  existing_cloudtrail_arns  = data.aws_cloudtrail.existing.*.arn
  existing_cloudtrail_names = data.aws_cloudtrail.existing.*.name

  created_cloudtrail_arns  = aws_cloudtrail.secrets_management_events.*.arn
  created_cloudtrail_names = aws_cloudtrail.secrets_management_events.*.name

  s3_bucket_ids  = aws_s3_bucket.cloudtrail.*.id
  s3_bucket_arns = aws_s3_bucket.cloudtrail.*.arn

  cloudtrail_arn  = local.using_existing_cloudtrail && length(local.existing_cloudtrail_arns) > 0 ? local.existing_cloudtrail_arns[0] : (length(local.created_cloudtrail_arns) > 0 ? local.created_cloudtrail_arns[0] : "")
  cloudtrail_name = local.using_existing_cloudtrail && length(local.existing_cloudtrail_names) > 0 ? local.existing_cloudtrail_names[0] : (length(local.created_cloudtrail_names) > 0 ? local.created_cloudtrail_names[0] : "")

  s3_bucket_id       = local.using_existing_s3_bucket ? var.s3_bucket_name : (length(local.s3_bucket_ids) > 0 ? local.s3_bucket_ids[0] : "")
  s3_bucket_arn      = local.using_existing_s3_bucket ? format("arn:aws:s3:::%s", var.s3_bucket_name) : (length(local.s3_bucket_arns) > 0 ? local.s3_bucket_arns[0] : "")
  s3_bucket_logs_arn = local.using_existing_s3_bucket ? format("arn:aws:s3:::%s/AWSLogs/%s/*", var.s3_bucket_name, data.aws_caller_identity.current.account_id) : (length(local.s3_bucket_arns) > 0 ? "${local.s3_bucket_arns[0]}/AWSLogs/${data.aws_caller_identity.current.account_id}/*" : "")

  has_existing_bucket    = var.s3_bucket_name != ""
  existing_bucket_policy = length(data.aws_s3_bucket_policy.existing) > 0 ? data.aws_s3_bucket_policy.existing[0].policy : ""
  bucket_policy_has_cloudtrail = local.existing_bucket_policy != "" && (
    contains(local.existing_bucket_policy, "cloudtrail.amazonaws.com")
    && contains(local.existing_bucket_policy, "s3:GetBucketAcl")
    && contains(local.existing_bucket_policy, "s3:PutObject")
  )

  # Pass DESTINATIONS_JSON and enable_tag_replication as environment variables to the Lambda
  environment = merge(
    {
      DESTINATIONS_JSON      = var.destinations_json
      ENABLE_TAG_REPLICATION = tostring(var.enable_tag_replication)
    },
    var.environment_variables
  )
}

###############################################################################
# Random suffix for bucket name when creating
###############################################################################

resource "random_integer" "suffix" {
  count = var.s3_bucket_name == "" ? 1 : 0
  min   = 10000
  max   = 99999
}

###############################################################################
# Lambda using the official module
###############################################################################

module "lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 7.0"

  function_name = var.name
  handler       = "handler.lambda_handler"
  runtime       = "python3.12"

  source_path = "${path.module}/lambda"

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
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "sts:AssumeRole"
        ]
        Resource = var.allowed_assume_roles
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = module.lambda.lambda_role_name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

###############################################################################
# S3 bucket for CloudTrail (create only if not provided)
###############################################################################

resource "aws_s3_bucket" "cloudtrail" {
  count = var.s3_bucket_name == "" ? 1 : 0

  bucket        = var.s3_bucket_name != "" ? var.s3_bucket_name : "${var.prefix}-cloudtrail-${data.aws_caller_identity.current.account_id}-${random_integer.suffix[0].result}"
  force_destroy = true
  tags          = var.tags
}

###############################################################################
# CloudTrail (create only if not provided)
###############################################################################

resource "aws_cloudtrail" "secrets_management_events" {
  count                         = var.cloudtrail_name == "" ? 1 : 0
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
}

###############################################################################
# S3 bucket policy (manage only if requested and bucket is known)
###############################################################################

resource "aws_s3_bucket_policy" "cloudtrail" {
  count  = var.manage_s3_bucket_policy && local.s3_bucket_id != "" ? 1 : 0
  bucket = local.s3_bucket_id

  policy = jsonencode({
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

###############################################################################
# Optional: simple precondition checks to fail early with clear messages
###############################################################################

## Fallback validation (compatible with Terraform < 1.5 and >= 1.5)
resource "null_resource" "validate_inputs_fallback" {
  # Input validations for compatibility with Terraform < 1.5
  # If you use Terraform >= 1.5, consider migrating these validations to precondition blocks in the affected resources.
  count = (
    (!var.manage_s3_bucket_policy && var.s3_bucket_name != "" && !local.bucket_policy_has_cloudtrail)
    || (var.cloudtrail_name != "" && var.s3_bucket_name == "")
    # You can add more validations here if you add new variable combinations
  ) ? 1 : 0

  provisioner "local-exec" {
    when    = "create"
    command = <<-EOT
      echo "ERROR: Input validation failed for the secretsmanager-replication module."
      if [ "${var.cloudtrail_name}" != "" ] && [ "${var.s3_bucket_name}" = "" ]; then
        echo " - You provided cloudtrail_name but not s3_bucket_name. Provide the S3 bucket name used by that trail."
      fi
      if [ "${var.manage_s3_bucket_policy}" = "false" ] && [ "${var.s3_bucket_name}" != "" ] && [ "${local.bucket_policy_has_cloudtrail}" = "false" ]; then
        echo " - manage_s3_bucket_policy=false and an existing s3_bucket_name was provided,"
        echo "   but the bucket policy does not appear to allow CloudTrail to write logs."
        echo "   Ensure the bucket policy allows cloudtrail.amazonaws.com to call s3:GetBucketAcl, s3:GetBucketPolicy and s3:PutObject on AWSLogs/<ACCOUNT_ID>/*."
      fi
      exit 1
    EOT
  }
}
