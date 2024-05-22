output "tgw_id" {
  value = aws_ec2_transit_gateway.transit_gateway.id
}

output "default_rtb_id" {
  value = aws_ec2_transit_gateway.transit_gateway.association_default_route_table_id
}