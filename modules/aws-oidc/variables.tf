variable "region" {
  description = "Region to deploy resources"
  type        = string
  default     = "eu-west-1"
}
variable "subs" {
  description = "List of GitHub OIDC subject claims allowed to assume the role"
  type        = list(string)
}
