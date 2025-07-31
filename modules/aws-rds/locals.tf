locals {
  default_ssm_prefix   = "${var.engine}/${var.environment}/${var.db_identifier}"
  db_name_ssm_name     = coalesce(var.db_name_ssm_name, "${local.default_ssm_prefix}/name")
  db_username_ssm_name = coalesce(var.db_username_ssm_name, "${local.default_ssm_prefix}/username")
  db_password_ssm_name = coalesce(var.db_password_ssm_name, "${local.default_ssm_prefix}/password")
  db_endpoint_ssm_name = coalesce(var.db_endpoint_ssm_name, "${local.default_ssm_prefix}/endpoint")
  db_host_ssm_name     = coalesce(var.db_host_ssm_name, "${local.default_ssm_prefix}/host")
  db_port_ssm_name     = coalesce(var.db_port_ssm_name, "${local.default_ssm_prefix}/port")
  security_group_name  = coalesce(var.security_group_name, "${var.engine}-${var.environment}-${var.db_identifier}-security-group")
  subnet_group_name    = coalesce(var.subnet_group_name, "${var.engine}-${var.environment}-${var.db_identifier}-subnet-group")
  vpc_by_id            = var.vpc_id != null && var.vpc_id != "" ? data.aws_vpc.by_id[0] : null
  vpc_by_tag           = var.vpc_id == null && var.vpc_tag_name != "" ? data.aws_vpc.this[0] : null
  vpc_id               = try(local.vpc_by_id.id, local.vpc_by_tag.id)
  vpc_cidr             = try(local.vpc_by_id.cidr_block, local.vpc_by_tag.cidr_block)
  subnet_ids           = var.subnet_ids != null ? var.subnet_ids : data.aws_subnets.this[0].ids
  sg_by_id             = var.security_group_id != null ? data.aws_security_group.by_id[0] : null
  sg_by_tag            = var.security_group_id == null && var.security_group_tag_name != "" ? data.aws_security_group.by_tag[0] : null
  use_existing_sg      = local.sg_by_id != null || local.sg_by_tag != null
  security_group_id    = local.use_existing_sg ? (try(local.sg_by_id.id, local.sg_by_tag.id)) : aws_security_group.this[0].id
}
