locals {
  # Prefer the unified interface; preserve legacy route table inputs.
  legacy_route_tables = concat(
    var.pub_route_tables, var.pri_route_tables,
    coalesce(var.single_ngw_route_tables, []),
    coalesce(var.multi_ngw_route_tables, [])
  )
  selected_route_tables = distinct(var.route_table_ids != null ? var.route_table_ids : local.legacy_route_tables)
  route_pairs = {
    for pair in setproduct(local.selected_route_tables, var.destination_cidrs) :
    "${pair[0]}|${pair[1]}" => { route_table_id = pair[0], cidr = pair[1] }
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_attachment" {
  subnet_ids         = var.subnet_ids
  transit_gateway_id = var.transit_gw_id
  vpc_id             = var.vpc_id
  tags               = var.tags
}

resource "aws_route" "tgw_routes" {
  for_each               = local.route_pairs
  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.cidr
  transit_gateway_id     = var.transit_gw_id
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.vpc_attachment]
}
