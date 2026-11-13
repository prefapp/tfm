# github-org-secrets-section

Owns one *section* of an organization's GitHub Actions, Codespaces and Dependabot secrets — not necessarily all of them.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps, `config`, CR, module contract, state boundary, composite module) lives in the root [`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the other contexts.

## Language

**section**:
The subset of organization secrets this module instance owns. Several sections can coexist in one organization, each in its own state, provided their secret names do not overlap.
_Avoid_: all secrets, the secret set

**secret type**:
One of `actions`, `codespaces` or `dependabot`. Each has its own public key and its own GitHub resource.

**visibility**:
`all`, `private` or `selected` — which repositories can read the secret.

**selected repositories**:
The `owner/repo` list a secret is scoped to. It is read only when visibility is `selected` and silently ignored otherwise.

**encrypted value**:
Libsodium ciphertext supplied by the caller. Terraform never encrypts or decrypts secret values.
