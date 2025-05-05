output "vpc_id" {
  description = "ID of the created VPC"
  value       = cloudamqp_vpc.this.id
}

output "vpc_name" {
  description = "Name of the created VPC"
  value       = cloudamqp_vpc.this.name
}
