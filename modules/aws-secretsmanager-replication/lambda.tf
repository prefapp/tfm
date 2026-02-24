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

