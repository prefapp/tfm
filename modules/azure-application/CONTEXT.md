# azure-application

Owns an Entra ID application registration, its service principal, and the credentials and role grants attached to them.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**app registration**:
The `azuread_application` — the directory object defining the application's identity. The *service principal* is its instance in this tenant; the two are separate objects and both are owned here.
_Avoid_: app, service principal (they are not the same)

**redirect URI set**:
One `azuread_application_redirect_uris` resource per platform (web, SPA, public client). Platforms are managed independently, so adding a SPA URI does not disturb the web ones.

**Microsoft Graph role**:
An `msgraph_roles` entry, written into the application's required resource access. Requesting a role is not the same as being granted it — admin consent happens outside this module.

**federated credential**:
A trust that lets an external workload (a GitHub Actions job, a Kubernetes service account) get a token as this application without a secret. Preferred over `client_secret`.

**client secret rotation**:
The `time_rotating` clock that ages the generated password; the value is written to a Key Vault secret rather than exposed as an output.
