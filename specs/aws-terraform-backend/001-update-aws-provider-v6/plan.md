# Plan: Update AWS provider constraint to v6 for aws-terraform-backend

**Spec:** `spec.md`
**Module:** `modules/aws-terraform-backend`

## Steps

1. Update `modules/aws-terraform-backend/versions.tf` to set AWS provider constraint to `~> 6.40`.
2. Fix `modules/aws-terraform-backend/variables.tf` by replacing the invalid variable default for `aws_region` with a Terraform-valid default.
3. Add `.terraform-docs.yml` and `docs/header.md` + `docs/footer.md` to the module, following existing AWS module conventions.
4. Regenerate module `README.md` with `terraform-docs .` from module directory.
5. Run module checks (`terraform fmt -check` and `terraform init -backend=false`) to verify formatting and provider resolution.
6. Update `tasks.md` with final completion status.
