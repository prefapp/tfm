locals {
  broker_security_groups = contains(["private", "private_with_nlb"], var.access_mode) ? (
      var.existing_security_group_id != null ? [var.existing_security_group_id] : [aws_security_group.this[0].id]
    ) : null

  # AWS Target Group name limit is 32 chars. AWS appends a 6-char random suffix, so we have 26 chars for our prefix.
  # We use up to 21 chars for the base prefix and 5 for the port (max 65535), e.g. 'prefix-p65535-'.
  tg_name_prefix = "${substr(local.name_prefix, 0, 21)}-p"
  # Map well-known RabbitMQ ports to service names for SG descriptions
  rabbitmq_port_names = {
    5671  = "AMQPS"
    15672 = "Management UI"
  }
  vpc_id = var.vpc_id != null ? var.vpc_id : one(data.aws_vpc.by_name[*].id)
  vpc_cidr_block = var.vpc_id != null ? one(data.aws_vpc.this[*].cidr_block) : one(data.aws_vpc.by_name[*].cidr_block)
  single_broker_subnet_id = (
    length(var.broker_subnet_ids) > 0
    ? var.broker_subnet_ids[0]
    : (
        length(try(one(data.aws_subnets.broker[*].ids), [])) > 0
        ? try(one(data.aws_subnets.broker[*].ids)[0], null)
        : null
      )
  )
  broker_subnet_ids = (
    var.deployment_mode == "SINGLE_INSTANCE"
    ? (local.single_broker_subnet_id != null ? [local.single_broker_subnet_id] : [])
    : (length(var.broker_subnet_ids) > 0 ? var.broker_subnet_ids : try(one(data.aws_subnets.broker[*].ids), []))
  )

  lb_subnet_ids = length(var.lb_subnet_ids) > 0 ? var.lb_subnet_ids : one(data.aws_subnets.lb[*].ids)

  name_prefix = "mq-service-${var.project_name}-${var.environment}"

  common_tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    Source      = "Terraform-Module"
  })

  # Build a list of listener/target group configs from nlb_listener_ips
  nlb_listener_configs = var.access_mode == "private_with_nlb" ? flatten([
    for entry in var.nlb_listener_ips : (
      (lookup(entry, "expose_all_ports", false)) ? [
        for port, name in local.rabbitmq_port_names : {
          target_port   = port
          listener_port = port
          ips           = entry.ips
          port_key      = tostring(port)
        }
      ] : [
        {
          target_port = (
            can(tonumber(lookup(entry, "target_port", null))) ? tonumber(entry.target_port) : (
              length([for k, v in local.rabbitmq_port_names : k if v == entry.target_port]) > 0 ?
                [for k, v in local.rabbitmq_port_names : k if v == entry.target_port][0] : null
            )
          )
          listener_port = (
            lookup(entry, "listener_port", null) != null ? entry.listener_port : (
              can(tonumber(lookup(entry, "target_port", null))) ? tonumber(entry.target_port) : (
                length([for k, v in local.rabbitmq_port_names : k if v == entry.target_port]) > 0 ?
                  [for k, v in local.rabbitmq_port_names : k if v == entry.target_port][0] : null
              )
            )
          )
          ips           = entry.ips
          port_key      = tostring(lookup(entry, "listener_port", null) != null ? entry.listener_port : entry.target_port)
        }
      ]
    )
  ]) : []
}
