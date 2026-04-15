module "ruleset" {
  source   = "../github-org-ruleset"
  for_each = var.config

  config = each.value
}
