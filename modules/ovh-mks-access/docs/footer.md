## Lifecycle and Security Notes

- ServiceAccount tokens do not expire automatically. They remain valid until the associated ServiceAccount/Secret is deleted or replaced. Increment `credential_generation` to rotate the corresponding credential material; this replaces the token Secret but not its ServiceAccount, so the prior token is invalidated when the old Secret is removed.
- Client certificates default to 90 days and cannot request more than one year. Kubernetes may issue a shorter lifetime. Rotation is explicit: increment `credential_generation` and apply before the actual certificate expiry.
- Changing a published payload creates a new OKMS version. Secret paths are immutable after creation; use a new path if a destination must change. The provider's default OKMS policy keeps up to 10 versions and prunes older versions; configure retention in the secret's metadata policy outside this root if a different policy is required.
- Setting `publish_to_okms = false` removes the Terraform-managed OKMS secret resources; setting `export_local_kubeconfigs = false` removes locally managed files. Removing an identity removes its RBAC bindings and associated ServiceAccount/credentials. A previously issued certificate can still authenticate until expiry but no longer has its RBAC bindings.
- The migration removes the previous Argo CD ServiceAccount binding to `cluster-admin`; the token and certificate principals instead receive only the configured `edit` policy. Review this permission reduction in the plan before applying.
- Existing ServiceAccounts, token Secrets, token data, and local kubeconfig state addresses are migrated where possible. Local kubeconfig filenames now include the method and are rewritten on apply.
- The standalone provider is pinned by `.terraform.lock.hcl`; this root uses the `ovh-eu` endpoint and takes OVH API credentials from the provider's normal external environment/CLI configuration. The `ovh_cloud_project_kube` data source retrieves the cluster connection details using `service_name` and `kube_id`; `okms_id` is required even if local export is selected.
- Existing OKMS secrets at a configured path must be imported into the corresponding `ovh_okms_secret.credential["<identity>/<method>"]` address before planning, or the path must be new and unused. Destroying the Terraform resource deletes the secret; verify any consumer dependencies before removing an identity or disabling publication.
- The configured path must be unique across all identity/method pairs; the OKMS provider treats it as an immutable secret identifier.
- The cluster's OVH-provided kubeconfig is used only by Terraform to administer RBAC and credentials. Do not distribute it as an application credential.

## Required Kubernetes Permissions

The Kubernetes principal returned in the OVHcloud MKS kubeconfig needs permission to manage the configured RoleBindings/ClusterRoleBindings, ServiceAccounts, and service-account-token Secrets. For client certificates it must also create, read, delete, and approve CSRs, and have the `approve` permission for the `kubernetes.io/kube-apiserver-client` signer. The managed MKS API server must support that signer and populate legacy ServiceAccount token Secrets.

## Examples

See the self-contained caller configurations in the module's `_examples/` folder:

- [Certificate](https://github.com/firestartr-pro/infra-ovh/tree/main/accounts/firestartr-pro/pro/04-kubernetes-access/_examples/certificate) — certificate-only identity and kubeconfig publication.
- [Token](https://github.com/firestartr-pro/infra-ovh/tree/main/accounts/firestartr-pro/pro/04-kubernetes-access/_examples/token) — ServiceAccount token identity and namespace-scoped RBAC.
- [Both methods](https://github.com/firestartr-pro/infra-ovh/tree/main/accounts/firestartr-pro/pro/04-kubernetes-access/_examples/both-methods) — one identity with certificate and token credentials.

## Resources

- **OVHcloud Secret Manager**: [Product documentation](https://www.ovhcloud.com/en/public-cloud/secret-manager/)
- **OVH Terraform Provider**: [`ovh_okms_secret`](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/okms_secret)
- **Kubernetes Provider**: [Terraform Registry](https://registry.terraform.io/providers/hashicorp/kubernetes/latest)
- **OVHcloud MKS**: [Managed Kubernetes Service](https://www.ovhcloud.com/en/public-cloud/kubernetes/)

## Support

For questions about this infrastructure root, use the repository issue tracker or the owning infrastructure team.
