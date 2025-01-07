output "name" {
  value = cloudamqp_instance.this.id
}

output "cloudamqp_instance_rqm_version" {
  value = cloudamqp_instance.this.rmq_version
}

output "instance_host" {
  value = cloudamqp_instance.this.host
}

output "instance_vhost" {
  value = cloudamqp_instance.this.vhost
}

output "instance_id" {
  value = cloudamqp_instance.this.id
}

output "instance_url" {
  value     = cloudamqp_instance.this.url
  sensitive = true
}

output "instance_api_key" {
  value     = cloudamqp_instance.this.apikey
  sensitive = true
}

output "instance_host_internal" {
  value     = cloudamqp_instance.this.host_internal
  sensitive = true
}

output "instance_vhost_dedicated" {
  value = cloudamqp_instance.this.vhost
}

output "instance_dedicated" {
  value = cloudamqp_instance.this.dedicated
}

output "instance_backend" {
  value = cloudamqp_instance.this.backend
}
