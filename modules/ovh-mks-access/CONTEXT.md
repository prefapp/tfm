# OVHcloud MKS Access

This context manages identities and permissions for clients that access an OVHcloud Managed Kubernetes Service cluster.

## Language

**Access identity**:
A named Kubernetes principal with one RBAC role and scope. It may be authenticated through one or more credential methods.
_Avoid_: Credential, user (when referring to the combined identity rather than a certificate principal)

**Certificate credential**:
A Kubernetes client certificate whose CN matches its access identity. It expires, with a requested lifetime limited to one year by the MKS signer.
_Avoid_: Token

**Token credential**:
A bearer token associated with a Kubernetes ServiceAccount named after the access identity. It has no automatic expiration and remains valid until the associated resources are revoked or replaced. Kubernetes authorizes it as a ServiceAccount principal, distinct from the certificate principal, while both receive the access identity's configured RBAC policy.
_Avoid_: Certificate

**Credential destination**:
An OVHcloud Secret Manager path that stores a JSON secret containing a complete kubeconfig for one access identity and one credential method.
_Avoid_: Kubeconfig path (ambiguous with local files)
