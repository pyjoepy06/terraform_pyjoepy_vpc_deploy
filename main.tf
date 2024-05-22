module "prod_vpc_east_1_deploy" {
  source             = "./modules/vpc"
  region             = "us-east-1"
  name               = "prod_us_east"                       #VPC Name
  cidr_block         = "172.25.0.0/20"                      #VPC CIDR
  availability_zones = ["us-east-1a", "us-east-1b"]         #VPC AZ Zone
  public_subnets     = ["172.25.0.0/25", "172.25.0.128/25"] #Public Subnets with IGW routes auto-added - **1 Public Subnet Must Exist pending feature fix**
  private_subnets    = ["172.25.1.0/25", "172.25.1.128/25"] #Private Subnets
  enable_nat_gateway = false                                #Set to either true or false - Creates a NAT Gateway for Private Subnets Outbound Internet Connectivity
  single_nat_gateway = false                                #Set to either true or false - Creates Either one NAT gateway or enables HA per AZ provided NAT Gateways in the Private Subnets
}

module "dev_vpc_east_2_deploy" {
  source             = "./modules/vpc"
  region             = "us-east-1"
  name               = "dev_us_east"                                           #VPC Name
  cidr_block         = "172.26.0.0/23"                                         #VPC CIDR
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]              #VPC AZ Zone
  public_subnets     = ["172.26.0.0/25"]                                       #Public Subnets with IGW routes auto-added - **1 Public Subnet Must Exist pending feature fix**
  private_subnets    = ["172.26.1.0/25", "172.26.1.128/25", "172.26.0.128/25"] #Private Subnets
  enable_nat_gateway = false                                                   #Set to either true or false - Creates a NAT Gateway for Private Subnets Outbound Internet Connectivity
  single_nat_gateway = false                                                   #Set to either true or false - Creates Either one NAT gateway or enables HA per AZ provided NAT Gateways in the Private Subnets
}

module "transit_gateway_us_east_1" {
  source                          = "./modules/transit_gateway"
  name                            = "prod-us-east-1"
  default_route_table_association = "enable"
  description                     = "Transit Gateway for US-East-1 VPCs"
  amazon_side_asn                 = 64514
  region                          = "us-east-1"
}

#Module for Enable VPC Attachments
module "prod_vpc_east_1_tgw_attach" {
  source        = "./modules/transit_vpc_attach"
  subnet_ids    = module.prod_vpc_east_1_deploy.private_subnets  #Leverage Private Subnets in VPC Module Above
  transit_gw_id = module.transit_gateway_us_east_1.tgw_id #Leverage TGW ID in module above
  vpc_id        = module.prod_vpc_east_1_deploy.vpc_id        #Leverage TGW ID in module above
  #region        = "us-east-1"
  pub_route_tables        = module.prod_vpc_east_1_deploy.public_rtb_id
  pri_route_tables        = module.prod_vpc_east_1_deploy.private_rtb_id
  single_ngw_route_tables = module.prod_vpc_east_1_deploy.single_nat_gw_rtb_id #If NAT Gateways are created route tables get updated else null
  multi_ngw_route_tables  = module.prod_vpc_east_1_deploy.multi_nat_gw_rtb_id  #If NAT Gateways are created route tables get updated else null
}

#Module for Enable VPC Attachments
module "dev_vpc_east_2_tgw_attach" {
  source        = "./modules/transit_vpc_attach"
  subnet_ids    = module.dev_vpc_east_2_deploy.private_subnets   #Leverage Private Subnets in VPC Module Above
  transit_gw_id = module.transit_gateway_us_east_1.tgw_id #Leverage TGW ID in module above
  vpc_id        = module.dev_vpc_east_2_deploy.vpc_id        #Leverage TGW ID in module above
  #region        = "us-east-1"
  pub_route_tables        = module.dev_vpc_east_2_deploy.public_rtb_id
  pri_route_tables        = module.dev_vpc_east_2_deploy.private_rtb_id
  single_ngw_route_tables = module.dev_vpc_east_2_deploy.single_nat_gw_rtb_id #If NAT Gateways are created route tables get updated else null
  multi_ngw_route_tables  = module.dev_vpc_east_2_deploy.multi_nat_gw_rtb_id  #If NAT Gateways are created route tables get updated else null
}