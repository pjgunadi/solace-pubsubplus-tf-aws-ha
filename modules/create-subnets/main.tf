
data "aws_vpc" "cluster_vpc" {
  filter {
    name = "tag:Name"
    values = [ var.vpc.name ]
  }
}

data "aws_availability_zone" "cluster_az" {
  for_each = var.subnets
  name = format("%s%s", var.region, each.value.az_suffix)
}

resource "aws_subnet" "cluster_subnets" {
  for_each = var.subnets
  vpc_id = data.aws_vpc.cluster_vpc.id
  availability_zone = data.aws_availability_zone.cluster_az[each.key].id
  cidr_block = each.value.cidr
  map_public_ip_on_launch = true
  tags = merge({
    Name = each.value.name
    }, var.common_tags)
}
