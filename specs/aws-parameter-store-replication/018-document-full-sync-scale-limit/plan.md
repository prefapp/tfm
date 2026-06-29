# Plan: Document full-sync scale and timeout limitations

**Spec:** `spec.md`
**Module:** `modules/aws-parameter-store-replication`

## Steps

1. Add a new note in `docs/header.md` describing full-sync timeout constraints.
2. Mention default timeout (600s), AWS max timeout (900s), and no built-in continuation semantics.
3. Add mitigation guidance for large DR bootstrap use cases.
4. Regenerate `README.md` with `terraform-docs .`.
5. Mark tasks complete.
