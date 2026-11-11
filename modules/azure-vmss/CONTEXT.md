# azure-vmss

Owns a Linux virtual machine scale set and its extensions.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**common**:
The `common` object naming the existing resource group and region the scale set is created in. The module does not create either.

**upgrade policy**:
Part of the `vmss` object — how instances are replaced on a model change (manual, automatic or rolling). It decides whether an apply is disruptive.

**extension**:
An `azurerm_virtual_machine_scale_set_extension` — an agent installed on every instance. Extensions run on instance creation, so adding one usually implies an instance refresh.
