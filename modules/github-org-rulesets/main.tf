module "ruleset" {
  source   = "../github-org-ruleset"
  for_each = coalesce(var.config, {})

  config = each.value
}
