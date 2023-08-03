variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "organization" {
  type = string
}

variable "subs" {
  type = list(string)
}
