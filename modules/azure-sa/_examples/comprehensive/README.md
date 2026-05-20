# Comprehensive YAML reference

[`values.reference.yaml`](./values.reference.yaml) lists **illustrative** values for most module inputs (network deny, blob properties, containers, queues, tables, shares, lifecycle rules, tags).

It is **not** consumed by Terraform automatically. Typical uses:

- Copy fragments into `.tfvars` or HCL `module` arguments.
- Or load with `yamldecode(file(...))` in a root module and map fields to the `azure-sa` module.

**Convention:** keep large YAML samples in `_examples/**` (or similar) instead of embedding them in `README.md` so `terraform-docs` stays maintainable.
