# Discover Firestartr integration roles by name and tags

The module identifies the customer roles `FirestartrBackstageReader` and `FirestartrArgoCDAdmin` by exact role name, then verifies their `FirestartrIntegration`, `ManagedBy=Prefapp`, and `ProvisionedBy=CloudFormation` tags before creating EKS access entries. AWS provider role discovery supports name filtering but not a direct tag query; requiring exactly one correctly tagged result prevents ambiguous or unrelated roles from receiving cluster access.
