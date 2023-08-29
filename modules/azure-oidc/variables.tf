variable "organization" {
  type = string
}

variable "subs" {
  type = list(string)
}

variable "role_definition_name" {
  type = string
  default = "Contributor"
}

variable "application" {
  type = string
  default = "foo"
}
