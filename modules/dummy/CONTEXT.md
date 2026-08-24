# dummy

Owns nothing real. It simulates latency and failure at plan, apply and destroy so provisioning systems and CI pipelines can be exercised against predictable bad behaviour.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**phase**:
One of `plan`, `apply` or `destroy`. Every input is scoped to a phase, and the three behave independently: a module can apply cleanly and always fail on destroy.

**crash**:
A forced non-zero exit in a phase. With `crash_on_<phase>` alone it happens every time.
_Avoid_: error, failure (too vague)

**tries before ok**:
The retry counter (`tries_before_<phase>_ok`): fail this many attempts, then succeed. Set to 0 or less to crash forever. It is how a *transient* fault is modelled rather than a permanent one.

**instance name**:
`instance_name` — the identifier keying the on-disk counter that makes the retry behaviour work across runs. Two instances sharing a name share a counter.

**destroy-time value**:
Destroy-time provisioners may only read `self`, so the module carries what it needs into `self.triggers` at create time. Values changed after creation do not reach the destroy path (see [ADR 0001](./docs/adr/0001-destroy-time-self-triggers-approach.md)).
