# Comprehensive reference

[`values.reference.yaml`](./values.reference.yaml) shows two **illustrative** input shapes (Standard-style and Premium-style). It is not consumed by Terraform directly; map fields to module arguments or use `yamldecode()` in a root module.

Premium `redis_configuration` connection strings must be real storage endpoints in your environment (placeholders below).
