###############################################################################
# Lambda using the official module
###############################################################################


# --- Construcción de DESTINATIONS_JSON dinámico ---
locals {
  destinations_json = {
    for entry in flatten([
      for vault in var.aws_backup_vault : [
        for plan in vault.plan != null ? vault.plan : [] : (
          length(try(plan.copy_action, [])) > 0 ?
          [for ca in plan.copy_action : {
            account_id        = regex("arn:aws:backup:[^:]+:([0-9]+):backup-vault:.*", ca.destination_vault_arn)[0]
            vault_arn         = ca.destination_vault_arn
            region            = try(split(":", ca.destination_vault_arn)[3], null)
            delete_after_days = try(ca.delete_after, var.copy_action_default_values.delete_after)
          }] :
          [{
            account_id        = var.copy_action_default_values.destination_account_id
            vault_arn         = "arn:aws:backup:${var.copy_action_default_values.destination_region}:${var.copy_action_default_values.destination_account_id}:backup-vault:${vault.vault_name}"
            region            = var.copy_action_default_values.destination_region
            delete_after_days = var.copy_action_default_values.delete_after
          }]
        )
      ]
    ]) :
    entry.account_id => {
      vault_arn         = entry.vault_arn
      regions           = { (entry.region) = {} }
      delete_after_days = entry.delete_after_days
      iam_role_arn      = aws_iam_role.this[0].arn
    }
  }
}

module "lambda_automatic_replication" {
  count   = local.has_cross_account_copy ? 1 : 0
  source  = "terraform-aws-modules/lambda/aws"
  version = "8.7"

  function_name = "backups-automatic-replication"
  handler       = "handler.lambda_handler"
  runtime       = "python3.14"
  region        = "eu-west-1"
  source_path   = ["${path.module}/src/common"]

  timeout     = var.lambda_timeout
  memory_size = var.lambda_memory
  tags        = var.tags
  environment_variables = {
    DESTINATIONS_JSON = jsonencode(local.destinations_json)
  }
  #   DESTINATIONS_JSON = jsonencode({ "807867957104": { "vault_arn": "arn:aws:backup:eu-west-3:807867957104:backup-vault:common", "regions": { "eu-west-3": {} } ,"delete_after_days": 7, "iam_role_arn": "${aws_iam_role.this[0].arn}" } })

  attach_cloudwatch_logs_policy = false

  # Extra IAM permissions for Secrets Manager + STS
  attach_policy_json = true

  policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      for s in [
        {
          Sid    = "AllowUseKms"
          Effect = "Allow"
          Action = [
            "kms:DescribeKey",
            "kms:CreateGrant",
            "kms:GenerateDataKey",
            "kms:Encrypt",
            "kms:Decrypt",
            "kms:ReEncryptTo",
            "kms:ReEncryptFrom"
          ]
          Resource = "*"
        },
        {
          Sid    = "AllowCopyAWSBackups"
          Effect = "Allow"
          Action = [
            "backup:List*",
            "backup:Describe*",
            "backup:Copy*",
            "backup:StartCopyJob"
          ]
          Resource = "*"
        },
        {
          Action   = "iam:PassRole"
          Effect   = "Allow"
          Resource = "${aws_iam_role.this[0].arn}"
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
  count      = local.has_cross_account_copy ? 1 : 0
  role       = module.lambda_automatic_replication[0].lambda_role_name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}