output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_cidr" {
  value = aws_vpc.vpc.cidr_block
}

output "public_subnets" {
  value = aws_subnet.public_subnet[*].id
}

output "private_subnets" {
  value = aws_subnet.private_subnet[*].id
}

output "public_rtb_id" {
  value = length(aws_route_table.public_rtb[*].id) > 0 ? aws_route_table.public_rtb[*].id : aws_route_table.public_rtb[*].id
}

output "private_rtb_id" {
  value = length(aws_route_table.global_private_rtb[*].id) > 0 ? aws_route_table.global_private_rtb[*].id : aws_route_table.global_private_rtb[*].id
}

output "single_nat_gw_rtb_id" {
  value = length(aws_route_table.single_nat_private_rtb.*.id) > 0 ? aws_route_table.single_nat_private_rtb.*.id : null
}

output "multi_nat_gw_rtb_id" {
  value = length(aws_route_table.multi_nat_private_rtb.*.id) > 0 ? aws_route_table.multi_nat_private_rtb.*.id : null
}
