module "secretsmanager_copy" {
  source = "../../"

  name = "pattern-filtering-replication"

  allowed_assume_roles = [
    "arn:aws:iam::123456789012:role/SecretsReplicationRole"
  ]

  environment_variables = {
    DESTINATIONS_JSON = jsonencode({
      "destination1" = {
        role_arn           = "arn:aws:iam::123456789012:role/SecretsReplicationRole"
        region             = "us-east-1"
        secret_name_prefix = "filtered-"
      }
    })
    INCLUDE_PATTERN = "^prod-.*"
  }
}
