# Comprehensive example values

The file [`values.reference.yaml`](./values.reference.yaml) contains an illustrative **`values:`** document showing how `application_gateway`, `web_application_firewall_policy`, `ssl_profiles`, `rewrite_rule_sets`, and related inputs can be shaped together.

It is **reference-only** (not wired to a runnable root module in this folder). Copy and adapt sections into your stack or workspace configuration, replacing placeholders such as `${{ tfworkspace:... }}`, IP addresses, hostnames, Key Vault secret URLs, and GitHub coordinates.
