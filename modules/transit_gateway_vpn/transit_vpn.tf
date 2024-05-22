resource "aws_customer_gateway" "vpn_endpoint_ip" {
  bgp_asn    = var.bgp_number
  ip_address = var.vpn_ip_address
  type       = "ipsec.1"
}

resource "aws_vpn_connection" "vpn_connection" {
  customer_gateway_id = aws_customer_gateway.vpn_endpoint_ip.id
  transit_gateway_id  = var.transit_gw_id
  type                = aws_customer_gateway.vpn_endpoint_ip.type
  static_routes_only  = true
}

resource "aws_ec2_transit_gateway_route" "vpn_routes" {
  count                          = length(var.client_campus_network_routes) > 0 ? length(var.client_campus_network_routes) : 0
  destination_cidr_block         = element(var.client_campus_network_routes, count.index)
  transit_gateway_attachment_id  = aws_vpn_connection.vpn_connection.transit_gateway_attachment_id
  transit_gateway_route_table_id = var.tgw_association_default_route_table_id
}