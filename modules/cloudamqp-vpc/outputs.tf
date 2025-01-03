output "vpc_id" {
  description = "ID of the created VPC"
  value       = cloudamqp_vpc.this.id
}

output "vpc_name" {
  description = "Name of the created VPC"
  value       = cloudamqp_vpc.this.name
}

output "id" {
  description = "The identifier for this resource. Will be the same as instance_id."
  value       = cloudamqp_vpc_connect.this.id
}

output "status" {
  description = "Private Service Connect status [enable, pending, disable]."
  value       = cloudamqp_vpc_connect.this.status
}

output "service_name" {
  description = "Service name (alias for Azure) of the PrivateLink."
  value       = cloudamqp_vpc_connect.service_name
}
