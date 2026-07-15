# ADR Index

Map of all Architecture Decision Records (ADRs) in this repository.

An ADR records a design decision that is **hard to reverse**, **surprising without context**, and **the result of a real trade-off**. Routine changes (field additions, forced provider deprecations, doc clarifications, bug fixes) do not get an ADR. See `CONSTITUTION.md` §9 and `AGENTS.md` for the governing rules.

## How ADRs are organized

- **Repo-wide decisions** live in root [`docs/adr/`](./docs/adr/) — decisions that cut across modules (e.g. release tooling, the ghaps `config` contract). There are none yet; the folder is kept with a `.gitkeep`.
- **Module-scoped decisions** live in each module's `modules/<module>/docs/adr/` — co-located with the code they govern.

Place every ADR at the **narrowest scope that fully contains the decision**. If it only affects one module, it belongs in that module.

## Repo-wide ADRs

_None yet._

## Module ADRs

### aws-parameter-store-replication

| ADR | Decision |
|-----|----------|
| [unified-lambda-for-all-replication-modes](./modules/aws-parameter-store-replication/docs/adr/unified-lambda-for-all-replication-modes.md) | One Lambda handles EventBridge, manual, and full-sync modes, distinguished by event shape, instead of separate functions. |
| [delete-events-not-replicated](./modules/aws-parameter-store-replication/docs/adr/delete-events-not-replicated.md) | Delete events are intentionally not replicated, so replicas survive as a DR recovery point. |
| [full-sync-requires-explicit-event-flag](./modules/aws-parameter-store-replication/docs/adr/full-sync-requires-explicit-event-flag.md) | Full sync runs only on an explicit event flag; the config variable is an allow/deny guardrail, not a trigger. |
| [async-failure-visibility-via-dlq](./modules/aws-parameter-store-replication/docs/adr/async-failure-visibility-via-dlq.md) | Async invocation failures are routed to an SQS DLQ with CloudWatch alarms for operator visibility. |

### aws-secretsmanager-replication

| ADR | Decision |
|-----|----------|
| [origin-region-is-source-region](./modules/aws-secretsmanager-replication/docs/adr/origin-region-is-source-region.md) | The region name prefix and `origin-region` tag encode the **source** region, not the destination, for DR traceability. |
| [single-lambda-for-all-replication-modes](./modules/aws-secretsmanager-replication/docs/adr/single-lambda-for-all-replication-modes.md) | A single Lambda handles EventBridge, manual, and full-sync modes by event shape; the separate automatic/manual Lambdas were removed (breaking, v2.0.0). |

### github-repo-secrets-section

| ADR | Decision |
|-----|----------|
| [deterministic-secret-update-trigger](./modules/github-repo-secrets-section/docs/adr/deterministic-secret-update-trigger.md) | Secret updates fire on a caller-supplied SHA256 of the plaintext via `replace_triggered_by`, avoiding spurious diffs from non-deterministic ciphertext. |

## Adding a new ADR

1. Confirm it passes the three-part test above. If not, don't write one.
2. Choose the narrowest scope: a single module's `docs/adr/`, or root `docs/adr/` for genuinely cross-cutting decisions.
3. Name the file with a descriptive slug: `some-decision.md` (no numeric prefix).
4. Keep it terse — a title and one to three sentences covering context, decision, and trade-off. Optional `Status`/`Considered Options`/`Consequences` sections only when they add value.
5. Add a row to the relevant table in this index.
