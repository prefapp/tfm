# mongodb-atlas-azure-privatelink

Owns the private connection between an Atlas project and an Azure virtual network. The only module in this catalog that spans two provider planes.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**two-sided endpoint**:
A working Private Link needs three resources in order: the Atlas `privatelink_endpoint` (which returns a service ID), the Azure `private_endpoint` in `azure_subnet_id`, and the Atlas `privatelink_endpoint_service` that ties them together. They cannot be created independently.

**manual connection**:
`endpoint_connection_is_manual_connection` — whether the Azure private service connection waits for approval on the Atlas side, with `endpoint_connection_request_message` carried along. Automatic is the normal path.

**referenced network**:
The Azure subnet and resource group are looked up, never created. This module owns the connection, not either network.
