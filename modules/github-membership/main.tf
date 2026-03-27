# Organization membership (admin / member)
resource "github_membership" "this" {
  count    = var.config.user != null ? 1 : 0
  username = try(var.config.user.username, null)
  role     = try(var.config.user.role, null)
}

# Team memberships
resource "github_team_membership" "relationships" {
  for_each = {
    for r in var.config.relationships : "${r.username}-${r.teamId}" => r
  }

  team_id  = each.value.teamId   # numeric team ID (not slug)
  username = each.value.username
  role     = each.value.role
}
