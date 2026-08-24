# azure-app-gateway

Owns an Application Gateway, its public IP and its WAF policy.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**blocks_definition**:
The nested structure inside `application_gateway` that carries listeners, backend pools, settings, probes and routing rules. It is the bulk of the configuration.

**SSL profile vs SSL policy**:
A *policy* (`ssl_policy`) sets the gateway-wide TLS floor — protocol version and cipher suites. A *profile* (`ssl_profiles`) overrides that for a specific listener, typically for mutual TLS.
_Avoid_: TLS config (ambiguous)

**rewrite rule set**:
A named set of header or URL rewrites that routing rules can reference. Defined once, referenced many times.

**WAF policy**:
The `azurerm_web_application_firewall_policy` this module creates and attaches. It is a separate resource from the gateway, so it can outlive a listener change.
