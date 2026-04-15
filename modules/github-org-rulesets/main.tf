module "ruleset" {
  source   = "git::https://github.com/prefapp/tfm.git//modules/github-org-ruleset?ref=feat/github-org-ruleset"
  for_each = var.config

  config = each.value
}
