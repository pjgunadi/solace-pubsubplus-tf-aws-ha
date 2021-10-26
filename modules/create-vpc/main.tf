
resource "aws_vpc" "cluster_vpc" {
  cidr_block = var.vpc.cidr
  tags = merge({
    Name = var.vpc.name
    }, var.common_tags)
}

resource "aws_vpc_ipv4_cidr_block_association" "additional_cidr" {
  for_each = toset(var.vpc.add_cidrs)
  vpc_id     = aws_vpc.cluster_vpc.id
  cidr_block = each.value
}

resource "aws_internet_gateway" "cluster_igw" {
  depends_on = [
    aws_vpc.cluster_vpc
  ]
  vpc_id = "${aws_vpc.cluster_vpc.id}"
}

resource "aws_route" "internet_access" {
  depends_on = [
    aws_vpc.cluster_vpc
  ]
  route_table_id         = "${aws_vpc.cluster_vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.cluster_igw.id}"
}
