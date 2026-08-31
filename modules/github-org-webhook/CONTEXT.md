# github-org-webhook

Owns one organization-level webhook.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**webhook**:
The single `github_organization_webhook` this module owns: its URL, content type, secret, TLS strictness and the event list that triggers it.

**active**:
Whether GitHub delivers to the webhook. An inactive webhook still exists and keeps its configuration.

**insecureSsl**:
Whether GitHub skips TLS verification when delivering. Off by default; turning it on is a deliberate downgrade.
