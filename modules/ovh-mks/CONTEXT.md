# ovh-mks

Owns an OVHcloud Managed Kubernetes Service cluster and its node pools. The private network and subnet are existing infrastructure discovered by name and CIDR.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**MKS cluster**:
An OVHcloud-managed Kubernetes control plane in a Public Cloud project and region.

**node pool**:
A named group of worker nodes belonging to an MKS cluster. A pool can be pinned to an availability zone and configured with capacity bounds.

**network discovery**:
Selecting an existing private network by exact name and its subnet by CIDR within the cluster's region. The MKS cluster module does not own those network resources.

**free plan**:
The OVHcloud MKS plan for a managed control plane. It does not make worker nodes or other Public Cloud resources free.
