# Plan: Clarify existing_resources example wording for unified Lambda behavior

**Spec:** `spec.md`
**Module:** `modules/aws-parameter-store-replication`

## Steps

1. Ensure `_examples/existing_resources/README.md` uses unified Lambda wording in "What it creates".
2. Regenerate module `README.md` via `terraform-docs .` to follow repository docs process.
3. Validate diagnostics for modified files.
