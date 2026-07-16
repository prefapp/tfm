###############################################################################
# Lambda for secret replication
# Handles EventBridge-driven (CloudTrail), manual single-secret, and full-sync
# invocation modes in a single function, distinguished by event shape.
###############################################################################

module "lambda_replication" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 7.0"

  function_name = "${var.name}-replication"
  handler       = "handler.lambda_handler"
  runtime       = "python3.12"

  timeout     = var.lambda_timeout
  memory_size = var.lambda_memory
  tags        = var.tags

  environment_variables = merge(
    var.environment_variables,
    {
      DESTINATIONS_JSON         = var.destinations_json
      ENABLE_TAG_REPLICATION    = tostring(var.enable_tag_replication)
      ENABLE_FULL_SYNC          = tostring(var.enable_full_sync)
      ADD_REGION_PREFIX_TO_NAME = tostring(var.add_region_prefix_to_name)
    }
  )

  create_package         = false
  local_existing_package = data.archive_file.lambda.output_path

  attach_cloudwatch_logs_policy = false

  # Extra IAM permissions for Secrets Manager + STS (all invocation modes)
  attach_policy_json = true
  policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      for s in [
        # Read any secret in the source account (automatic, manual, full sync)
        {
          Sid    = "SecretsManagerReadAll"
          Effect = "Allow"
          Action = [
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret",
            "secretsmanager:ListSecretVersionIds",
            "secretsmanager:GetResourcePolicy"
          ]
          Resource = "*"
        },
        # List secrets is only needed for full-sync mode
        var.enable_full_sync ? {
          Sid      = "SecretsManagerListForFullSync"
          Effect   = "Allow"
          Action   = ["secretsmanager:ListSecrets"]
          Resource = "*"
        } : null,
        # Manage (write) secrets in destination accounts
        {
          Sid    = "ManageDestinationSecrets"
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
          Sid      = "CreateDestinationSecrets"
          Effect   = "Allow"
          Action   = ["secretsmanager:CreateSecret"]
          Resource = "*"
        },
        length(var.allowed_assume_roles) > 0 ? {
          Sid      = "AssumeDestinationRoles"
          Effect   = "Allow"
          Action   = ["sts:AssumeRole"]
          Resource = var.allowed_assume_roles
        } : null,
        length(var.source_kms_key_arns) > 0 ? {
          Sid    = "DecryptSourceSecrets"
          Effect = "Allow"
          Action = [
            "kms:Decrypt",
            "kms:DescribeKey"
          ]
          Resource = var.source_kms_key_arns
        } : null
      ] : s if s != null
    ]
  })
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = module.lambda_replication.lambda_role_name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
