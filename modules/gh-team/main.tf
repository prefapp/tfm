# Create the GitHub Team
resource "github_team" "this" {
  name           = var.config.group.name
  description    = var.config.group.description
  privacy        = var.config.group.privacy
  parent_team_id = var.config.group.parentTeamId
}

# Add team memberships
resource "github_team_membership" "members" {
  for_each = {
    for m in var.config.group_members : m.username => m
  }

  team_id  = github_team.this.id
  username = each.value.username
  role     = "member"   
}
