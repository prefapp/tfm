# Plan: Validate destination `role_arn` format

**Spec:** `spec.md`
**Module:** `modules/aws-parameter-store-replication`

## Steps

1. Replace non-empty `role_arn` validation with IAM role ARN regex validation
2. Validate updated Terraform file for diagnostics
3. Mark tasks complete
