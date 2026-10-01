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
terraform -chdir=_examples/<example> init
terraform -chdir=_examples/<example> plan -var-file=/path/to/protected.tfvars
```

To rotate credentials for one identity, increment its `credential_generation` and apply. This replaces its enabled certificate key/CSR and/or token Secret. The generated kubeconfig for each method is published to its configured OKMS path as `{"kubeconfig":"<complete YAML kubeconfig>"}`; consumers retrieve the `kubeconfig` property. Terraform state and saved plan files contain sensitive credential material and must be protected.
