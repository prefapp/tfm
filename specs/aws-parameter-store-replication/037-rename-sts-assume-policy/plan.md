# Plan: Rename destination assume-role inline policy to match its actual purpose

**Spec:** `spec.md`
**Module:** `modules/aws-parameter-store-replication`

## Steps

1. Rename the inline policy resource label in `iam.tf` from `lambda_ssm_write_destinations` to `lambda_sts_assume_destinations`.
2. Rename the generated policy `name` suffix to `sts-assume-destinations`.
3. Regenerate module `README.md` with `terraform-docs .`.
4. Validate Terraform/docs for modified files.
