data "aws_availability_zones" "available" {}

resource "aws_subnet" "public" {
  count                   = length(var.subnet_cidr_blocks)
  vpc_id                  = var.vpc_id
  cidr_block              = var.subnet_cidr_blocks[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = length(var.subnet_names) > count.index ? var.subnet_names[count.index] : "public-subnet-${count.index + 1}"
  }
}
