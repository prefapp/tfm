resource "random_string" "this" {
  length  = 8
  special = false
  upper   = false
  numeric  = false
  lower   = true
}

output "random_string" {
  value = random_string.this.result
}