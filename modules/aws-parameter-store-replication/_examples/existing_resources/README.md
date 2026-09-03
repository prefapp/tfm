# EventBridge with KMS Example

This example shows how to set up event-driven parameter replication with EventBridge and KMS encryption per destination region.

## Usage

```bash
cd _examples/existing_resources
terraform init
terraform plan
terraform apply
```

## Configuration

Adjust the destination account ID, role ARN, and KMS key ARNs to match your environment.

## What it creates

- Unified Lambda function for parameter replication (EventBridge + manual invocation)
- IAM roles and policies for cross-account access
- EventBridge rule to trigger replication on parameter Create and Update events

## Notes

- Ensure the destination account has the corresponding replication role set up
- KMS keys must exist in the destination regions before applying
- The destination parameter names will be the same as source by default
