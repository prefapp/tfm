# OVHcloud Private Network

This context manages an OVHcloud Public Cloud private network, its DHCP subnet, and an attached Public Cloud gateway. The network can provide private connectivity and outbound access for workloads, including an MKS cluster.

## Language

**Private network**:
An OVHcloud Public Cloud network scoped to a region, with a VLAN identifier and an associated subnet.

**DHCP subnet**:
A subnet on the private network that assigns addresses from a configured pool through DHCP.

**Public Cloud gateway**:
An OVHcloud gateway attached to the private network and subnet to provide outbound connectivity.
