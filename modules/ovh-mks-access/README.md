<!-- BEGIN_TF_DOCS -->
# **OVHcloud MKS Kubernetes Access Terraform Root**

## Overview

This Terraform root manages Kubernetes identities and their access to an OVHcloud Managed Kubernetes Service (MKS) cluster. Each identity receives a role and scope shared by whichever authentication methods are enabled for it: a Kubernetes client certificate, a ServiceAccount bearer token, or both. Certificate and token credentials use distinct Kubernetes principals but are bound to the same configured access policy.

Credentials can be published as complete kubeconfigs to OVHcloud Secret Manager (OKMS), and optionally written to local files with restrictive permissions. The kubeconfig payload is stored as JSON with a `kubeconfig` property. Credential values, including private keys and tokens, are stored in Terraform state; use an encrypted backend with tightly restricted access.

## Key Features

- **Authentication choices**: Enable `certificate`, `token`, or both for each identity.
- **Shared RBAC policy**: Apply `readonly` (`view`) or `readwrite` (`edit`) to certificate users and ServiceAccounts with the same identity name.
- **Scoped permissions**: Bind access cluster-wide or only in explicitly listed namespaces.
- **OVHcloud Secret Manager**: Publish one complete kubeconfig per identity and method to a distinct configured secret path.
- **Optional local export**: Write kubeconfig files with `0600` permissions for testing or manual distribution.
- **Credential lifecycle**: Request certificates for 90 days by default (maximum one year) and rotate enabled credentials explicitly with `credential_generation`.

## Basic Usage

Configure this root's `terraform.tfvars` with the OVHcloud Public Cloud project `project_description` (for example, `prefapp`), MKS cluster `kube_id`, credential destinations, and identity matrix. Terraform finds the unique matching project by its description, uses its `service_name` to retrieve the cluster kubeconfig through the native `ovh_cloud_project_kube` data source, and exposes that identifier as the `service_name` output. No local administrator kubeconfig file is needed. Supply the required OKMS ID with a protected var-file because the repository wrapper selects `terraform.tfvars` automatically. OVH provider credentials must be available through the standard OVH provider environment/CLI configuration.

The target namespaces in `namespaces` and each configured ServiceAccount namespace must already exist. The OVH identity must be authorized to retrieve the MKS kubeconfig and administer the target cluster (RBAC, ServiceAccounts, Secrets, and client-certificate CSRs for the `kubernetes.io/kube-apiserver-client` signer), as well as create and version secrets in the configured OKMS.

### Certificate identity

```hcl
identities = {
  developers-readonly = {
    role         = "readonly"
    scope        = "cluster"
    auth_methods = ["certificate"]
    secret_paths = {
      certificate = "mks/production/developers-readonly/certificate"
    }
  }
}
```

### Token identity

```hcl
identities = {
  deployment-bot = {
    role                      = "readwrite"
    scope                     = "namespaces"
    namespaces                = ["apps"]
    auth_methods              = ["token"]
    service_account_namespace = "kube-system"
    secret_paths = {
      token = "mks/production/deployment-bot/token"
    }
  }
}
```

### Both methods for one identity

```hcl
identities = {
  argocd = {
    role         = "readwrite"
    scope        = "cluster"
    auth_methods = ["certificate", "token"]
    secret_paths = {
      certificate = "mks/production/argocd/certificate"
      token       = "mks/production/argocd/token"
    }
  }
}
```

Use distinct immutable OKMS paths for every identity/method pair. Increment an identity's `credential_generation` to replace its enabled credential material and publish new OKMS versions.

## Operating the root

Set the `project_description`, `kube_id`, desired `identities` and each active method's `secret_paths` in `terraform.tfvars`. The project description must resolve to exactly one OVHcloud Public Cloud project. Keep `okms_id` in a protected local var-file, as it is required input but not stored in the versioned configuration. `publish_to_okms` is enabled by default; local files are opt-in with `export_local_kubeconfigs = true`. Run a plan and inspect RBAC removals and OKMS path changes before applying:

```sh
./accounts/terrafire.sh -p firestartr-pro pro 04-kubernetes-access -- -var-file=/path/to/protected-okms.tfvars
./accounts/terrafire.sh -a firestartr-pro pro 04-kubernetes-access -- -var-file=/path/to/protected-okms.tfvars
```

To rotate credentials for one identity, increment its `credential_generation` and apply. This replaces its enabled certificate key/CSR and/or token Secret. The generated kubeconfig for each method is published to its configured OKMS path as `{"kubeconfig":"<complete YAML kubeconfig>"}`; consumers retrieve the `kubeconfig` property. Terraform state and saved plan files contain sensitive credential material and must be protected.

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |
| <a name="provider_local"></a> [local](#provider\_local) | n/a |
| <a name="provider_ovh"></a> [ovh](#provider\_ovh) | n/a |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |
| <a name="provider_time"></a> [time](#provider\_time) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_certificate_signing_request_v1.client](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/certificate_signing_request_v1) | resource |
| [kubernetes_cluster_role_binding_v1.cluster](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding_v1) | resource |
| [kubernetes_role_binding_v1.namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role_binding_v1) | resource |
| [kubernetes_secret_v1.token](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_service_account_v1.identity](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account_v1) | resource |
| [local_sensitive_file.kubeconfig](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/sensitive_file) | resource |
| [ovh_okms_secret.credential](https://registry.terraform.io/providers/hashicorp/ovh/latest/docs/resources/okms_secret) | resource |
| [terraform_data.configuration](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.credential_generation](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [time_sleep.token_propagation](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [tls_cert_request.client](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/cert_request) | resource |
| [tls_private_key.client](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [kubernetes_secret_v1.token](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/secret_v1) | data source |
| [ovh_cloud_project_kube.my_kube_cluster](https://registry.terraform.io/providers/hashicorp/ovh/latest/docs/data-sources/cloud_project_kube) | data source |
| [ovh_cloud_projects.projects](https://registry.terraform.io/providers/hashicorp/ovh/latest/docs/data-sources/cloud_projects) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Nombre del clúster, usado en solicitudes de certificado y kubeconfigs. | `string` | `null` | no |
| <a name="input_export_local_kubeconfigs"></a> [export\_local\_kubeconfigs](#input\_export\_local\_kubeconfigs) | Escribe localmente los kubeconfigs habilitados con permisos 0600, además de publicarlos en OKMS si corresponde. | `bool` | `false` | no |
| <a name="input_identities"></a> [identities](#input\_identities) | Matriz de identidades de acceso. Las claves son el CN del certificado y el nombre<br/>de la ServiceAccount. auth\_methods admite certificate, token o ambos. Cada método<br/>habilitado debe tener secret\_paths.<método> cuando publish\_to\_okms está activo.<br/>role admite readonly (ClusterRole view) o readwrite (ClusterRole edit).<br/>scope admite cluster (todos los namespaces) o namespaces (lista explícita). | <pre>map(object({<br/>    role                      = string<br/>    scope                     = string<br/>    auth_methods              = optional(set(string), ["certificate"])<br/>    namespaces                = optional(set(string), [])<br/>    service_account_namespace = optional(string, "kube-system")<br/>    secret_paths              = optional(map(string), {})<br/>    expiration_seconds        = optional(number, 7776000)<br/>    credential_generation     = optional(number, 0)<br/>  }))</pre> | <pre>{<br/>  "argocd": {<br/>    "auth_methods": [<br/>      "certificate",<br/>      "token"<br/>    ],<br/>    "role": "readwrite",<br/>    "scope": "cluster",<br/>    "secret_paths": {<br/>      "certificate": "mks/prefapp-pro/argocd/certificate",<br/>      "token": "mks/prefapp-pro/argocd/token"<br/>    }<br/>  },<br/>  "developers-readonly": {<br/>    "auth_methods": [<br/>      "certificate"<br/>    ],<br/>    "role": "readonly",<br/>    "scope": "cluster",<br/>    "secret_paths": {<br/>      "certificate": "mks/prefapp-pro/developers-readonly/certificate"<br/>    }<br/>  },<br/>  "developers-readwrite": {<br/>    "auth_methods": [<br/>      "certificate"<br/>    ],<br/>    "role": "readwrite",<br/>    "scope": "cluster",<br/>    "secret_paths": {<br/>      "certificate": "mks/prefapp-pro/developers-readwrite/certificate"<br/>    }<br/>  }<br/>}</pre> | no |
| <a name="input_kube_id"></a> [kube\_id](#input\_kube\_id) | Identificador del clúster OVHcloud Managed Kubernetes Service. | `string` | n/a | yes |
| <a name="input_okms_id"></a> [okms\_id](#input\_okms\_id) | Identificador del servicio OVHcloud Secret Manager (OKMS) donde se publicarán los kubeconfigs. | `string` | n/a | yes |
| <a name="input_project_description"></a> [project\_description](#input\_project\_description) | Descripción del proyecto OVHcloud Public Cloud que contiene el clúster MKS, por ejemplo prefapp. | `string` | n/a | yes |
| <a name="input_publish_to_okms"></a> [publish\_to\_okms](#input\_publish\_to\_okms) | Publica cada kubeconfig habilitado como una nueva versión JSON en la ruta OKMS indicada por identidad y método. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_matrix"></a> [access\_matrix](#output\_access\_matrix) | Identidades, métodos de autenticación, rol, alcance y destinos configurados. |
| <a name="output_okms_secret_paths"></a> [okms\_secret\_paths](#output\_okms\_secret\_paths) | Rutas de OVH Secret Manager configuradas para cada credencial publicada. |
| <a name="output_service_name"></a> [service\_name](#output\_service\_name) | Identificador OVHcloud del proyecto encontrado por project\_description. |

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
<!-- END_TF_DOCS -->
