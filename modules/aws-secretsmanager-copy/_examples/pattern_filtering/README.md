# Pattern Filtering Example

This example demonstrates how to replicate only secrets matching a specific pattern using the aws-secretsmanager-copy module.

## Usage

```hcl
module "secretsmanager_copy" {
  source = "../../"

  name = "pattern-filtering-replication"

  allowed_assume_roles = [
    "arn:aws:iam::DESTINATION_ACCOUNT_ID:role/SecretsReplicationRole"
  ]

  environment_variables = {
    DESTINATIONS_JSON = jsonencode({
      "destination1" = {
        role_arn           = "arn:aws:iam::DESTINATION_ACCOUNT_ID:role/SecretsReplicationRole"
        region             = "us-east-1"
        secret_name_prefix = "filtered-"
      }
    })
    INCLUDE_PATTERN = "^prod-.*"
  }
}
```

This will only replicate secrets whose names start with `prod-`.

Replace `DESTINATION_ACCOUNT_ID` and `SecretsReplicationRole` with your actual values.
