# Comprehensive reference — `azure-kv`

`values.reference.yaml` shows **tag merge**, **access policies** by `object_id`, **group**, **service principal**, and **user** lookup patterns.

If **`enable_rbac_authorization`** is `true`, set **`access_policies`** to `[]` in Terraform (the module precondition rejects non-empty policies with RBAC enabled).
