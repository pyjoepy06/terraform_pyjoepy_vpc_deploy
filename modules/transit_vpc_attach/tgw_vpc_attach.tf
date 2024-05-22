resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_attachment" {
  subnet_ids         = var.subnet_ids
  transit_gateway_id = var.transit_gw_id
  vpc_id             = var.vpc_id
}