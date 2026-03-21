variable "config" {
  description = "GitHub membership configuration (organization role + team relationships)"
  type = object({
    relationships = optional(list(object({
      username  = string
      team_slug = string   # team slug (e.g. "jvazquez-prefapp-all")
      role      = optional(string, "member")  # member | maintainer
    })), [])

    user = optional(object({
      username = string
      role     = optional(string, "member")  # member | admin
    }))
  })

  validation {
    condition = alltrue([
      for r in var.config.relationships : contains(["member", "maintainer"], r.role)
    ])
    error_message = "relationship.role must be 'member' or 'maintainer'."
  }

  validation {
    condition = var.config.user == null || contains(["member", "admin"], var.config.user.role)
    error_message = "user.role must be 'member' or 'admin'."
  }
}
