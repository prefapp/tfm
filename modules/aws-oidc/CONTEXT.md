# aws-oidc

Owns the GitHub Actions OIDC provider for an account and the roles that trust it.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**subject claim**:
An entry of `subs` — the `sub` value a GitHub Actions token must carry to assume the role (repository, branch, environment or tag). It is the whole of the trust decision, so it should be as narrow as the workflow allows.
_Avoid_: audience, claim

**provider ownership**:
`create_oidc_provider` — false when the account already has the GitHub OIDC provider. An account can hold only one provider per issuer URL, so exactly one module instance may own it.
