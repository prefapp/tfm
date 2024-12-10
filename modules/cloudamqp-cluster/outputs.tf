output name {
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
