locals {
  destination_account_id = "123456789012" # Replace with your destination account ID
  destination_role_arn   = "arn:aws:iam::${local.destination_account_id}:role/ParameterReplicationRole"
}

module "parameter_replication_with_existing_resources" {
  source = "../../"

  name   = "app-parameters"
  prefix = "myorg"

  # Destination configuration
  destinations_json = jsonencode({
    (local.destination_account_id) = {
      "role_arn" = local.destination_role_arn
      "regions" = {
        "us-east-1" = {
          "kms_key_arn" = "arn:aws:kms:us-east-1:${local.destination_account_id}:key/12345678-1234-1234-1234-123456789012"
        }
        "eu-west-1" = {}
      }
    }
  })

  # Allow Lambda to assume the destination role
  allowed_assume_roles = [local.destination_role_arn]

  # Enable EventBridge to automatically trigger replication on parameter changes
  eventbridge_enabled = true

  tags = {
    Environment = "production"
    Team        = "platform"
    ManagedBy   = "Terraform"
    LandingZone = "true"
  }
}

output "automatic_replication_lambda_arn" {
  description = "ARN of the automatic parameter replication Lambda function"
  value       = module.parameter_replication_with_existing_resources.lambda_automatic_replication_arn
}

output "eventbridge_rule_arn" {
  description = "ARN of the EventBridge rule"
  value       = module.parameter_replication_with_existing_resources.eventbridge_rule_arn
}
