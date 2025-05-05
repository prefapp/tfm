# This module creates a DynamoDB table if `enable = true`
variable "enable" {
  type    = bool
  default = false
}

# DynamoDB table variablesº
variable "table_name" { type = string }
variable "hash_key" { type = string }
variable "tags" { type = map(string) }
variable "billing_mode" { type = string }


# Only declare the resource if `enable = true`
resource "aws_dynamodb_table" "this" {
  name         = var.table_name
  hash_key     = var.hash_key
  billing_mode = var.billing_mode

  attribute {
    name = var.hash_key
    type = "S"
  }
  tags = var.tags
}
