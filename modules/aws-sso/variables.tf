variable "data_file" {
  type = string
  description = "absolute path of the data to use (in YAML format)"
}

variable "identity_store_arn" {
  type = string
  description = "the arn of the SSO instance"
}

variable "store_id" {
   type = string
   description = "the Identity store id"
}
