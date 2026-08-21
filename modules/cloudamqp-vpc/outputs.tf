output "vpc_id" {
  description = "ID of the created VPC"
  value       = cloudamqp_vpc.this.id
}

output "vpc_name" {
  description = "Name of the created VPC"
  value       = cloudamqp_vpc.this.name
}

output "id" {
  description = "The identifier for the VPC Connect resource. Will be the same as instance_id."
  value       = try(cloudamqp_vpc_connect.this[0].id, null)
}

output "status" {
  description = "Private Service Connect status [enable, pending, disable]."
  value       = try(cloudamqp_vpc_connect.this[0].status, null)
}
