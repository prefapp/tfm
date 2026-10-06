# Publish MKS access credentials to OVH Secret Manager

Access credentials are managed with Terraform and published as complete kubeconfigs to OVHcloud Secret Manager, one immutable path per identity and authentication method. This keeps distribution destinations declarative and supports both client certificates and ServiceAccount tokens, at the cost of persisting private keys, bearer tokens, and kubeconfig payloads in Terraform state; the state backend and saved plans must therefore be encrypted and access-restricted.
