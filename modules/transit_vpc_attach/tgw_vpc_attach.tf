resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_attachment" {
  subnet_ids         = var.subnet_ids
  transit_gateway_id = var.transit_gw_id
  vpc_id             = var.vpc_id
}

resource "aws_route" "class_a_public" {
  count                  = length(var.pub_route_tables)
  route_table_id         = element(var.pub_route_tables, count.index)
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = var.transit_gw_id
}

resource "aws_route" "class_a_private" {
  count                  = length(var.pri_route_tables)
  route_table_id         = element(var.pri_route_tables, count.index)
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = var.transit_gw_id
}

resource "aws_route" "class_a_single_nat_gw" {
  count                  = var.single_ngw_route_tables != null ? length(var.single_ngw_route_tables) : 0
  route_table_id         = element(var.single_ngw_route_tables, count.index)
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = var.transit_gw_id
}

resource "aws_route" "class_a_multi_nat_gw" {
  count                  = var.multi_ngw_route_tables != null ? length(var.multi_ngw_route_tables) : 0
  route_table_id         = element(var.multi_ngw_route_tables, count.index)
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = var.transit_gw_id
}

resource "aws_route" "class_b_public" {
  count                  = length(var.pub_route_tables)
  route_table_id         = element(var.pub_route_tables, count.index)
  destination_cidr_block = "172.16.0.0/12"
  transit_gateway_id     = var.transit_gw_id
}

resource "aws_route" "class_b_private" {
  count                  = length(var.pri_route_tables)
  route_table_id         = element(var.pri_route_tables, count.index)
  destination_cidr_block = "172.16.0.0/12"
  transit_gateway_id     = var.transit_gw_id
}

resource "aws_route" "class_b_single_nat_gw" {
  count                  = var.single_ngw_route_tables != null ? length(var.single_ngw_route_tables) : 0
  route_table_id         = element(var.single_ngw_route_tables, count.index)
  destination_cidr_block = "172.16.0.0/12"
  transit_gateway_id     = var.transit_gw_id
}

resource "aws_route" "class_b_multi_nat_gw" {
  count                  = var.multi_ngw_route_tables != null ? length(var.multi_ngw_route_tables) : 0
  route_table_id         = element(var.multi_ngw_route_tables, count.index)
  destination_cidr_block = "172.16.0.0/12"
  transit_gateway_id     = var.transit_gw_id
}

resource "aws_route" "class_c_public" {
  count                  = length(var.pub_route_tables)
  route_table_id         = element(var.pub_route_tables, count.index)
  destination_cidr_block = "192.168.0.0/16"
  transit_gateway_id     = var.transit_gw_id
}

resource "aws_route" "class_c_private" {
  count                  = length(var.pri_route_tables)
  route_table_id         = element(var.pri_route_tables, count.index)
  destination_cidr_block = "192.168.0.0/16"
  transit_gateway_id     = var.transit_gw_id
}

resource "aws_route" "class_c_single_nat_gw" {
  count                  = var.single_ngw_route_tables != null ? length(var.single_ngw_route_tables) : 0
  route_table_id         = element(var.single_ngw_route_tables, count.index)
  destination_cidr_block = "192.168.0.0/16"
  transit_gateway_id     = var.transit_gw_id
}

resource "aws_route" "class_c_multi_nat_gw" {
  count                  = var.multi_ngw_route_tables != null ? length(var.multi_ngw_route_tables) : 0
  route_table_id         = element(var.multi_ngw_route_tables, count.index)
  destination_cidr_block = "192.168.0.0/16"
  transit_gateway_id     = var.transit_gw_id
}