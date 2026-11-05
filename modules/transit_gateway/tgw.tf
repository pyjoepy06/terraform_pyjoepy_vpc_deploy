resource "aws_ec2_transit_gateway" "transit_gateway" {
  description                     = var.description
  amazon_side_asn                 = var.amazon_side_asn
  default_route_table_association = var.default_route_table_association

  tags = { Name = format("%s-transit-gateway", var.name) }
}

