output "organization_membership" {
  description = "Organization-level membership"
  value = var.config.user != null ? {
    username = github_membership.this[0].username
    role     = github_membership.this[0].role
  } : null
}

output "team_memberships" {
  description = "Team memberships created"
  value = [
    for r in var.config.relationships : {
      username = r.username
      teamId   = r.teamId
      role     = r.role
    }
  ]
}

output "user" {
  description = "User details"
  value = var.config.user
}
