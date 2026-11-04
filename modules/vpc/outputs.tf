output "vpc_id" { value = aws_vpc.vpc.id }
output "vpc_cidr" { value = aws_vpc.vpc.cidr_block }
output "public_subnets" { value = aws_subnet.public_subnet[*].id }
output "private_subnets" { value = aws_subnet.private_subnet[*].id }
output "public_rtb_id" { value = aws_route_table.public_rtb[*].id }
output "private_rtb_id" { value = aws_route_table.global_private_rtb[*].id }
output "single_nat_gw_rtb_id" { value = length(aws_route_table.single_nat_private_rtb) > 0 ? aws_route_table.single_nat_private_rtb[*].id : null }
output "multi_nat_gw_rtb_id" { value = length(aws_route_table.multi_nat_private_rtb) > 0 ? aws_route_table.multi_nat_private_rtb[*].id : null }
output "regional_nat_gw_rtb_id" { value = aws_route_table.regional_private_rtb[*].id }
output "nat_gateway_mode" { value = local.nat_mode }
output "nat_gateway_ids" {
  value = concat(
    aws_nat_gateway.single_nat_gateway[*].id,
    aws_nat_gateway.multi_nat_gateway[*].id,
    aws_nat_gateway.regional_nat_gateway[*].id
  )
}
output "private_route_table_ids" {
  description = "All private route tables regardless of NAT mode."
  value = concat(
    aws_route_table.global_private_rtb[*].id,
    aws_route_table.single_nat_private_rtb[*].id,
    aws_route_table.multi_nat_private_rtb[*].id,
    aws_route_table.regional_private_rtb[*].id
  )
}
output "all_route_table_ids" {
  value = concat(aws_route_table.public_rtb[*].id, aws_route_table.global_private_rtb[*].id,
    aws_route_table.single_nat_private_rtb[*].id, aws_route_table.multi_nat_private_rtb[*].id,
    aws_route_table.regional_private_rtb[*].id)
}
output "tgw_attachment_subnet_ids" {
  description = "One private subnet per AZ for Transit Gateway attachments."
  value = [for az in local.private_azs : aws_subnet.private_subnet[index(var.availability_zones, az)].id]
}
