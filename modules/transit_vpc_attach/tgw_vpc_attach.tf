locals {
  # Do not derive resource instance keys from apply-time route table IDs.
  # Caller should provide each route table once; duplicate IDs would create
  # duplicate routes and cause AWS RouteAlreadyExists errors.
  
  legacy_route_tables = concat(
    var.pub_route_tables,
    var.pri_route_tables,
    var.single_ngw_route_tables == null ? [] : var.single_ngw_route_tables,
    var.multi_ngw_route_tables == null ? [] : var.multi_ngw_route_tables
  )
  selected_route_tables = var.route_table_ids == null ? local.legacy_route_tables : var.route_table_ids
  destination_count     = length(var.destination_cidrs)
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_attachment" {
  subnet_ids         = var.subnet_ids
  transit_gateway_id = var.transit_gw_id
  vpc_id             = var.vpc_id
  tags               = var.tags
}

resource "aws_route" "tgw_routes" {
  count = length(local.selected_route_tables) * local.destination_count

  route_table_id         = local.selected_route_tables[floor(count.index / local.destination_count)]
  destination_cidr_block = var.destination_cidrs[count.index % local.destination_count]
  transit_gateway_id     = var.transit_gw_id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.vpc_attachment]
}
