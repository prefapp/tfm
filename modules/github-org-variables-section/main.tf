locals {
  selected_repo_full_names = toset(flatten([
    for _, var_config in var.config.variables : (
      var_config.visibility == "selected"
      ? (var_config.selectedRepositoryIds != null ? var_config.selectedRepositoryIds : [])
      : []
    )
  ]))
}

data "github_repository" "selected" {
  for_each  = local.selected_repo_full_names
  full_name = each.value
}

resource "github_actions_organization_variable" "this" {
  for_each = var.config.variables

  variable_name = each.key
  value         = each.value.value
  visibility    = each.value.visibility

  selected_repository_ids = each.value.visibility == "selected" ? [
    for repo_name in each.value.selectedRepositoryIds :
    data.github_repository.selected[repo_name].repo_id
  ] : null
}
