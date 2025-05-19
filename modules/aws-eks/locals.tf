# Get only two of the private subnets to create the cluster
locals {
  private_subnet_ids = data.aws_subnets.private_by_tag.ids
}

locals {
  vpc_id = data.aws_vpc.by_tag.id
}
