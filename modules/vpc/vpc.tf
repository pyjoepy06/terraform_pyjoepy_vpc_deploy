resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block
  tags = {
    Name = format("%s-vpc", var.name)
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  count  = var.enable_igw ? 1 : 0
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = format("%s-igw", var.name)
  }
}

#Build Public Subnets

resource "aws_subnet" "public_subnet" {
  #If public_subnets list length is 0 then don't deploy public subnets else deploy the number of subnets provided in list
  count                   = length(var.public_subnets) > 0 ? length(var.public_subnets) : 0
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = element(var.public_subnets, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = { Name = format("%s-${var.public_subnet_suffix}-subnet", var.name) }
}

#Build Private Subnets

resource "aws_subnet" "private_subnet" {
  #If private_subnets list length is 0 then don't deploy private subnets else deploy the number of subnets provided in list
  count             = length(var.private_subnets) > 0 ? length(var.private_subnets) : 0
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.private_subnets, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = { Name = format("%s-${var.private_subnet_suffix}-subnet", var.name) }
}

# #Build Public NAT Gateway with 1 NAT Gateway
resource "aws_eip" "single_nat_gateway_eip" {
  count = var.enable_nat_gateway && var.single_nat_gateway == true ? 1 : 0
  vpc   = true
}

# #Build Public NAT Gateway with HA per private_subnet
resource "aws_eip" "multi_nat_gateway_eip" {
  count = var.enable_nat_gateway == true && var.single_nat_gateway == false ? length(var.private_subnets) : 0
  vpc   = true
}

resource "aws_nat_gateway" "single_nat_gateway" {
  count         = var.enable_nat_gateway && var.single_nat_gateway == true ? 1 : 0
  allocation_id = element(aws_eip.single_nat_gateway_eip[*].id, count.index)
  subnet_id     = element(aws_subnet.public_subnet[*].id, count.index)

  depends_on = [aws_internet_gateway.internet_gateway]
}

resource "aws_nat_gateway" "multi_nat_gateway" {
  count         = var.enable_nat_gateway == true && var.single_nat_gateway == false ? length(var.private_subnets) : 0
  allocation_id = element(aws_eip.multi_nat_gateway_eip[*].id, count.index)
  subnet_id     = element(aws_subnet.public_subnet[*].id, count.index)

  depends_on = [aws_internet_gateway.internet_gateway]
}


#Create 1 Public Route table and create IGW route in route table, if length(var.public_subnets) > 0 create
resource "aws_route_table" "public_rtb" {
  count  = length(var.public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route" "public_internet_gateway" {
  count                  = var.enable_igw ? 1 : 0
  route_table_id         = aws_route_table.public_rtb[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway[0].id
}

resource "aws_route_table_association" "public_rtb_assign" {
  count          = length(var.public_subnets)
  subnet_id      = element(aws_subnet.public_subnet[*].id, count.index)
  route_table_id = aws_route_table.public_rtb[0].id
}

#Create 1 Private Route table in case we don't do NAT Gateways
resource "aws_route_table" "global_private_rtb" {
  count  = var.enable_nat_gateway == false ? 1 : 0
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table_association" "global_private_rtb_assign" {
  count          = var.enable_nat_gateway == false ? length(var.private_subnets) : 0
  subnet_id      = element(aws_subnet.private_subnet[*].id, count.index)
  route_table_id = aws_route_table.global_private_rtb[0].id
}

#Create Route Tables for Single or HA NAT Gateway, Create routes, and add routes to route table
#If no NAT Gatways were deployed ignored code completely

resource "aws_route_table" "single_nat_private_rtb" {
  count  = var.enable_nat_gateway && var.single_nat_gateway == true ? 1 : 0
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route" "single_nat_gateway_route" {
  count                  = length(var.private_subnets) > 0 && var.enable_nat_gateway && var.single_nat_gateway == true ? 1 : 0
  route_table_id         = aws_route_table.single_nat_private_rtb[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.single_nat_gateway[0].id
}

resource "aws_route_table_association" "single_nat_gw_rtb_assign" {
  count          = length(var.private_subnets) > 0 && var.enable_nat_gateway && var.single_nat_gateway == true ? length(var.private_subnets) : 0
  subnet_id      = element(aws_subnet.private_subnet[*].id, count.index)
  route_table_id = aws_route_table.single_nat_private_rtb[0].id
}


resource "aws_route_table" "multi_nat_private_rtb" {
  count  = length(var.private_subnets) > 0 && var.enable_nat_gateway == true && var.single_nat_gateway == false ? length(var.private_subnets) : 0
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route" "multi_nat_gateway_route" {
  count                  = length(var.private_subnets) > 0 && var.enable_nat_gateway == true && var.single_nat_gateway == false ? length(var.private_subnets) : 0
  route_table_id         = element(aws_route_table.multi_nat_private_rtb[*].id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.multi_nat_gateway[*].id, count.index)
}

resource "aws_route_table_association" "multi_nat_gw_rtb_assign" {
  count          = length(var.private_subnets) > 0 && var.enable_nat_gateway == true && var.single_nat_gateway == false ? length(var.private_subnets) : 0
  subnet_id      = element(aws_subnet.private_subnet[*].id, count.index)
  route_table_id = element(aws_route_table.multi_nat_private_rtb[*].id, count.index)
}
