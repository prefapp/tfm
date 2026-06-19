# Basic Example: Parameter Store Replication to Another AWS Account

This example shows how to set up basic cross-account parameter replication.

## Usage

```bash
cd _examples/basic
terraform init
terraform plan
terraform apply
```

## Configuration

The example replicates parameters to a destination account in two regions.
Adjust the variables in `terraform.tfvars` (or set environment variables) to match your environment.

## What it creates

- Lambda function for automatic parameter replication
- IAM roles and policies for cross-account access
- EventBridge rule to trigger replication on parameter changes (optional)
- EventBridge rule to trigger automatic replication on parameter changes (optional)

## Notes

- Ensure the destination account has the corresponding replication role set up
- The destination parameter names will be the same as source by default
- Tags are replicated by default
