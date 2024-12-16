output "name" {
  value = cloudamqp_instance.instance.id
}

output "cloudamqp_instance_rqm_version" {
  value = cloudamqp_instance.instance.rmq_version
}

output "instance_host" {
  value = cloudamqp_instance.instance.host
}

output "instance_vhost" {
  value = cloudamqp_instance.instance.vhost
}
