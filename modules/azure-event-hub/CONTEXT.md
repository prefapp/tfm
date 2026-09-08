# azure-event-hub

Owns an Event Hubs namespace, its hubs, consumer groups and authorization rules, plus the Event Grid system topics that feed them.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**namespace**:
The `azurerm_eventhub_namespace` — SKU, capacity and managed identity. Every hub in this module lives inside it.

**consumer group**:
A named read position on a hub. Two independent readers of the same hub need two consumer groups, not two hubs.

**authorization rule**:
A named SAS policy on a hub, granting listen/send/manage. Rules are per hub here, not per namespace.

**system topic**:
An Event Grid system topic referenced by `eventhub.*.system_topic_name`, wired to a subscription that delivers events into a hub. It is the bridge between Event Grid and Event Hubs.
