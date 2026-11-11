# github-repo-secrets-section

Owns one *section* of a repository's Actions, Dependabot and Codespaces secrets.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**section**:
The subset of a repository's secrets this module instance owns. Several sections can coexist for one repository, each in its own state, as long as secret names do not overlap.
_Avoid_: all secrets, the secret set

**secret kind**:
Which of the three surfaces a secret lives on — `actions`, `codespaces` or `dependabot`. The same name on two surfaces is two different secrets.

**pre-encrypted value**:
The values in the config are already sealed with libsodium against the matching public key. The module never sees plaintext and cannot encrypt for you.

**plaintext digest**:
An `*_sha256` entry — the SHA-256 of the *plaintext*, supplied by the caller. It is the only reliable signal that a secret's value really changed, because the ciphertext differs on every encryption (see [ADR 0001](./docs/adr/0001-deterministic-secret-update-trigger.md)).
_Avoid_: hash of the ciphertext

**update trigger**:
The `terraform_data` + `replace_triggered_by` mechanism keyed on the plaintext digest. Without a digest the module deliberately does not update an existing secret.
