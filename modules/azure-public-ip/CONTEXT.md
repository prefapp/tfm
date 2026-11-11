# azure-public-ip

Owns one public IP address.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**allocation method**:
`Static` or `Dynamic`. Standard-SKU addresses are always static, so the two inputs are not independent.

**domain name label**:
The DNS label that gives the address an `<label>.<region>.cloudapp.azure.com` name. It must be unique within the region.
