# Plan: Remove unused source-account `ssm:GetParameters` permission

**Spec:** `spec.md`
**Module:** `modules/aws-parameter-store-replication`

## Steps

1. Remove `ssm:GetParameters` from the source read policy in `iam.tf`.
2. Keep `ssm:GetParameter` and conditional source-tag read action unchanged.
3. Regenerate `README.md` with `terraform-docs .`.
4. Run `terraform validate` for the module.
