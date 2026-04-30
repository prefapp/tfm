variable "subs" {
  description = "List of GitHub OIDC subject claims allowed to assume the role"
  type        = list(string)
}
