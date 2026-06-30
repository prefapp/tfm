# Tasks: Clarify `allowed_assume_roles` semantics

**Module:** `aws-parameter-store-replication`
**Spec:** `spec.md`
**Plan:** `plan.md`

## Task List

- [x] 1. Update `allowed_assume_roles` description in `variables.tf`
- [x] 2. Regenerate `README.md` with `terraform-docs .`
- [x] 3. Verify generated README input description

## Validation Notes

- Confirmed `README.md` inputs table now describes `allowed_assume_roles` as additional assumable roles.
- Verified IAM behavior reference in `iam.tf` remains unchanged (`distinct(concat(var.allowed_assume_roles, [for dest in local.destinations : dest.role_arn]))`).
