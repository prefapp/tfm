variable "name" {
  type        = string
  description = "The name of the Role Definition"
}

variable "assignable_scopes" {
  type        = list(string)
  description = "One or more assignable scopes for this Role Definition. The first one will become de scope at which the Role Definition applies to."
}

variable "permissions" {
  type        = object({
    actions          = optional(list(string), [])
    data_actions     = optional(list(string), [])
    not_actions      = optional(list(string), [])
    not_data_actions = optional(list(string), [])
  })
  description = "A permissions block with possible 'actions', 'data_actions', 'not_actions' and/or 'not_data_actions'."
}
