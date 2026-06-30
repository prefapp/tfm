locals {
  destination_account_id = "123456789012" # Replace with your destination account ID
  destination_role_arn   = "arn:aws:iam::${local.destination_account_id}:role/ParameterReplicationRole"
}

module "parameter_replication" {
  source = "../../"

  name   = "app-parameters"
  prefix = "myorg"

  # Destination configuration: account ID with regions and optional KMS keys
  destinations_json = jsonencode({
    (local.destination_account_id) = {
      "role_arn" = local.destination_role_arn
      "regions" = {
        "us-east-1" = {}
        "eu-west-1" = {}
      }
    }
  })

  # Optional: Enable EventBridge to automatically trigger replication on parameter changes
  # eventbridge_enabled = true

  tags = {
    Environment = "production"
    Team        = "platform"
    ManagedBy   = "Terraform"
  }
}

output "replication_lambda_arn" {
  description = "ARN of the unified parameter replication Lambda function"
  value       = module.parameter_replication.lambda_replication_arn
}
