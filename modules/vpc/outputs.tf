output "public_subnets"{
    value = aws_subnet.public_subnet[*].id
}

output "private_subnets"{
    value = aws_subnet.private_subnet[*].id
}

output "my_vpc_id"{
    value = aws_vpc.vpc.id
}

output "vpc_cidr"{
    value = aws_vpc.vpc
}

output "public_ip_nat"{
    value = aws_eip.single_nat_gateway_eip[*]
}