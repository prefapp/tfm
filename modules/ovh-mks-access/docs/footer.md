## Lifecycle and Security Notes

- ServiceAccount tokens do not expire automatically. They remain valid until the associated ServiceAccount/Secret is deleted or replaced. Increment `credential_generation` to rotate the corresponding credential material; this replaces the token Secret but not its ServiceAccount, so the prior token is invalidated when the old Secret is removed.
- Client certificates default to 90 days and cannot request more than one year. Kubernetes may issue a shorter lifetime. Rotation is explicit: increment `credential_generation` and apply before the actual certificate expiry. Rotation issues a new certificate with the same CN; the previous certificate remains authorized until it expires, so rotation is not immediate revocation.
- Changing a published payload creates a new OKMS version. Secret paths are immutable after creation; use a new path if a destination must change. The provider's default OKMS policy keeps up to 10 versions and prunes older versions; configure retention in the secret's metadata policy outside this root if a different policy is required.
- Setting `publish_to_okms = false` removes the Terraform-managed OKMS secret resources; setting `export_local_kubeconfigs = false` removes locally managed files. Removing an identity removes its RBAC bindings and associated ServiceAccount/credentials. A previously issued certificate can still authenticate until expiry but no longer has its RBAC bindings.
- The migration removes the previous Argo CD ServiceAccount binding to `cluster-admin`; the token and certificate principals instead receive only the configured `edit` policy. Review this permission reduction in the plan before applying.
- This module contains no automatic Terraform state migrations. Before applying it to an existing state, inspect the current and configured resource addresses and migrate state explicitly; otherwise Terraform may plan to create duplicate resources. Local kubeconfig files are generated at paths that include the authentication method and are rewritten on apply.
- Provider constraints are declared in `versions.tf`. The repository does not commit `.terraform.lock.hcl`; the root caller is responsible for its own provider lockfile. This root uses the `ovh-eu` endpoint and takes OVH API credentials from the provider's normal external environment/CLI configuration. The `ovh_cloud_project_kube` data source retrieves cluster connection details using `service_name` and `kube_id`; `okms_id` is required even if local export is selected.
- With OVH provider 2.21.0, `ovh_okms_secret` has no import support. Each configured OKMS path must therefore be new and unused. Destroying the Terraform resource deletes the secret; verify any consumer dependencies before removing an identity or disabling publication.
- The configured path must be unique across all identity/method pairs; the OKMS provider treats it as an immutable secret identifier.
- The cluster's OVH-provided kubeconfig is used only by Terraform to administer RBAC and credentials. Do not distribute it as an application credential.

## Import and Adoption

Only the following Kubernetes objects have a documented import format in the configured Kubernetes provider. The addresses assume a caller module named `ovh_mks_access`; substitute the actual module block name. Import only when the corresponding identity, auth method, scope, namespace, and role are configured, then review the complete plan before applying.

| Resource | Terraform address | Import ID |
|----------|-------------------|-----------|
| ServiceAccount | `module.ovh_mks_access.kubernetes_service_account_v1.identity["<identity>"]` | `<namespace>/<identity>` |
| Token Secret | `module.ovh_mks_access.kubernetes_secret_v1.token["<identity>"]` | `<namespace>/<identity>-token` |
| ClusterRoleBinding | `module.ovh_mks_access.kubernetes_cluster_role_binding_v1.cluster["<identity>"]` | `<identity>-<role>` |
| RoleBinding | `module.ovh_mks_access.kubernetes_role_binding_v1.namespace["<identity>/<namespace>"]` | `<namespace>/<identity>-<role>` |

For example, import a ServiceAccount with `terraform import 'module.ovh_mks_access.kubernetes_service_account_v1.identity["<identity>"]' '<namespace>/<identity>'`. Kubernetes Secrets can contain bearer tokens; the Kubernetes provider stores Secret data in Terraform state, so protect and encrypt the state.

The following generated resources are not a safe adoption path: `tls_private_key.client["<identity>"]`, `tls_cert_request.client["<identity>"]`, `terraform_data.credential_generation["<identity>"]`, and `local_sensitive_file.kubeconfig["<identity>/<method>"]`. The local file resource has no import support and overwrites an existing file at its configured path when created. OVH provider 2.21.0 does not support importing `module.ovh_mks_access.ovh_okms_secret.credential["<identity>/<method>"]`; use a new, unused OKMS path instead. Review credential replacement effects before applying.

The Kubernetes provider accepts a CSR name for `module.ovh_mks_access.kubernetes_certificate_signing_request_v1.client["<identity>"]` (the configured name is `<cluster_name>-<identity>-tf`), but importing it does not restore the issued certificate. This import therefore cannot adopt the module's certificate credential safely.

## Required Kubernetes Permissions

The Kubernetes principal returned in the OVHcloud MKS kubeconfig needs permission to manage the configured RoleBindings/ClusterRoleBindings, ServiceAccounts, and service-account-token Secrets. For client certificates it must also create, read, delete, and approve CSRs, and have the `approve` permission for the `kubernetes.io/kube-apiserver-client` signer. The managed MKS API server must support that signer and populate legacy ServiceAccount token Secrets.

## Examples

See the self-contained caller configurations in the module's `_examples/` folder:

- [Certificate](https://github.com/prefapp/tfm/tree/main/modules/ovh-mks-access/_examples/certificate) — certificate-only identity and kubeconfig publication.
- [Token](https://github.com/prefapp/tfm/tree/main/modules/ovh-mks-access/_examples/token) — ServiceAccount token identity and namespace-scoped RBAC.
- [Both methods](https://github.com/prefapp/tfm/tree/main/modules/ovh-mks-access/_examples/both-methods) — one identity with certificate and token credentials.

## Resources

- **OVHcloud Secret Manager**: [Product documentation](https://www.ovhcloud.com/en/public-cloud/secret-manager/)
- **OVH Terraform Provider**: [`ovh_okms_secret`](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/okms_secret)
- **Kubernetes Provider**: [Terraform Registry](https://registry.terraform.io/providers/hashicorp/kubernetes/latest)
- **OVHcloud MKS**: [Managed Kubernetes Service](https://www.ovhcloud.com/en/public-cloud/kubernetes/)

## Support

For questions about this infrastructure root, use the repository issue tracker or the owning infrastructure team.
