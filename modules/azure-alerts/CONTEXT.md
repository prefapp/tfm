# azure-alerts

Owns the alerting surface for a subscription: action groups, activity-log and scheduled-query alerts, budgets, quota alerts and backup alert routing.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**action group**:
The notification target every other alert type points at. Nothing here notifies anyone without one.

**alert family**:
The five independent groups this module owns — `log_alert`, `budget`, `quota_alert`, `backup_alert` and their action groups. Each accepts an empty list, so a module instance may own only one family.

**legacy map form**:
Most inputs accept either a list of objects (preferred) or an older map of objects. Both are supported; new configuration should use the list form.
_Avoid_: deprecated input

**alert processing rule**:
What `backup_alert` creates: a rule that routes Azure Backup's built-in alerts to an action group. It does not define the alert condition, only where it goes.
