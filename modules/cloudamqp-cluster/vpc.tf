# Optional VPC
resource "cloudamqp_vpc" "vpc" {
  count = var.enable_vpc ? 1 : 0
  name = var.vpc_name
  region = var.vpc_region
  subnet = join(",", var.vpc_subnet)
  tags = var.vpc_tags
}

# Optional VPC connect
resource "cloudamqp_vpc_connect" "this" {
  count = var.enable_vpc_connect ? 1 : 0
  instance_id = cloudamqp_instance.this.id
  region = var.instance_region
  approved_subscriptions = var.vpc_connect_approved_subscriptions
  depends_on = [cloudamqp_vpc.vpc]
}
