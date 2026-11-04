locals {
  # Legacy callers continue to work when nat_gateway_mode is not set.
  nat_mode = var.nat_gateway_mode != null ? var.nat_gateway_mode : (
    !var.enable_nat_gateway ? "none" : (var.single_nat_gateway ? "single" : "per_az")
  )
  public_subnet_by_az = {
    for i, cidr in var.public_subnets : var.availability_zones[i] => aws_subnet.public_subnet[i].id
  }
  private_azs = distinct([
    for i, cidr in var.private_subnets : var.availability_zones[i]
  ])
  # Preserve the first-occurrence AZ order for predictable NAT indexing.
  per_az_public_subnets = [
    for az in local.private_azs : lookup(local.public_subnet_by_az, az, null)
  ]
}

resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block
  tags       = { Name = "${var.name}-vpc" }
}

resource "aws_internet_gateway" "internet_gateway" {
  count  = var.enable_igw ? 1 : 0
  vpc_id = aws_vpc.vpc.id
  tags   = { Name = "${var.name}-igw" }
}

resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  tags                    = { Name = "${var.name}-${var.public_subnet_suffix}-${count.index + 1}" }
}

resource "aws_subnet" "private_subnet" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.availability_zones[count.index]
  tags              = { Name = "${var.name}-${var.private_subnet_suffix}-${count.index + 1}" }
}

# Keep existing Terraform addresses for legacy single and multi NAT resources.
resource "aws_eip" "single_nat_gateway_eip" {
  count  = local.nat_mode == "single" ? 1 : 0
  domain = "vpc"
}

resource "aws_eip" "multi_nat_gateway_eip" {
  count  = local.nat_mode == "per_az" ? length(local.private_azs) : 0
  domain = "vpc"
}

resource "aws_nat_gateway" "single_nat_gateway" {
  count         = local.nat_mode == "single" ? 1 : 0
  allocation_id = aws_eip.single_nat_gateway_eip[0].id
  subnet_id     = aws_subnet.public_subnet[0].id
  depends_on    = [aws_internet_gateway.internet_gateway]
  tags          = { Name = "${var.name}-nat-single" }
}

resource "aws_nat_gateway" "multi_nat_gateway" {
  count         = local.nat_mode == "per_az" ? length(local.private_azs) : 0
  allocation_id = aws_eip.multi_nat_gateway_eip[count.index].id
  subnet_id     = local.per_az_public_subnets[count.index]
  depends_on    = [aws_internet_gateway.internet_gateway]
  tags          = { Name = "${var.name}-nat-${local.private_azs[count.index]}" }
}

resource "aws_nat_gateway" "regional_nat_gateway" {
  count             = local.nat_mode == "regional" ? 1 : 0
  vpc_id            = aws_vpc.vpc.id
  availability_mode = "regional"
  depends_on        = [aws_internet_gateway.internet_gateway]
  tags              = { Name = "${var.name}-nat-regional" }
}

resource "aws_route_table" "public_rtb" {
  count  = length(var.public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route" "public_internet_gateway" {
  count                  = var.enable_igw && length(var.public_subnets) > 0 ? 1 : 0
  route_table_id         = aws_route_table.public_rtb[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway[0].id
}

resource "aws_route_table_association" "public_rtb_assign" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rtb[0].id
}

resource "aws_route_table" "global_private_rtb" {
  count  = local.nat_mode == "none" && length(var.private_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table_association" "global_private_rtb_assign" {
  count          = local.nat_mode == "none" ? length(var.private_subnets) : 0
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.global_private_rtb[0].id
}

resource "aws_route_table" "single_nat_private_rtb" {
  count  = local.nat_mode == "single" ? 1 : 0
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route" "single_nat_gateway_route" {
  count                  = local.nat_mode == "single" ? 1 : 0
  route_table_id         = aws_route_table.single_nat_private_rtb[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.single_nat_gateway[0].id
}

resource "aws_route_table_association" "single_nat_gw_rtb_assign" {
  count          = local.nat_mode == "single" ? length(var.private_subnets) : 0
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.single_nat_private_rtb[0].id
}

resource "aws_route_table" "multi_nat_private_rtb" {
  count  = local.nat_mode == "per_az" ? length(var.private_subnets) : 0
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route" "multi_nat_gateway_route" {
  count                  = local.nat_mode == "per_az" ? length(var.private_subnets) : 0
  route_table_id         = aws_route_table.multi_nat_private_rtb[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.multi_nat_gateway[index(local.private_azs, var.availability_zones[count.index])].id
}

resource "aws_route_table_association" "multi_nat_gw_rtb_assign" {
  count          = local.nat_mode == "per_az" ? length(var.private_subnets) : 0
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.multi_nat_private_rtb[count.index].id
}

resource "aws_route_table" "regional_private_rtb" {
  count  = local.nat_mode == "regional" ? 1 : 0
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route" "regional_nat_gateway_route" {
  count                  = local.nat_mode == "regional" ? 1 : 0
  route_table_id         = aws_route_table.regional_private_rtb[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.regional_nat_gateway[0].id
}

resource "aws_route_table_association" "regional_nat_rtb_assign" {
  count          = local.nat_mode == "regional" ? length(var.private_subnets) : 0
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.regional_private_rtb[0].id
}
