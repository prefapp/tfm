# Historical README fragments (for comparison only)
#
# The old README included two fenced blocks. The first was labeled ```yaml but contained HCL,
# and placed `tags_from_rg` inside `common`, which does not match variables.tf.
#
# --- Original "yaml" fence (invalid as YAML; tags_from_rg misplaced) ---
#
#   common = {
#     resource_group_name = "my-resource-group"
#     location            = "eastus"
#     tags_from_rg     = true
#
#   vmss = {
#     ...
#   }
# }
#
# --- Original ```hcl fence (tags_from_rg still inside common — still wrong for this module) ---
#
#   common = {
#     resource_group_name = "my-resource-group"
#     location            = "eastus"
#     tags_from_rg     = true
#   }
#
#   vmss = {
#     ...
#   }
# }
#
# Use module.reference.hcl and values.reference.yaml in this folder instead.
