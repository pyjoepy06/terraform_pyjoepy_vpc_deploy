module "vpc_east_1_deploy" {
  source             = "./aws/modules/vpc"
  region             = "us-east-1"
  name               = "prod_us_east" #VPC Name
  cidr               = "172.25.0.0/20" #VPC CIDR
  availability_zones = ["us-east-1a", "us-east-1b"] #VPC AZ Zone
  public_subnets     = ["172.25.0.0/25", "172.25.0.128/25"] #Public Subnets with IGW routes auto-added
  private_subnets    = ["172.25.1.0/25", "172.25.1.128/25"] #Private Subnets
  enable_nat_gateway = false #Set to either true or false - Creates a NAT Gateway for Private Subnets Outbound Internet Connectivity
  single_nat_gateway = false #Set to either true or false - Creates Either one NAT gateway or enables HA per AZ provided NAT Gateways in the Private Subnets
}

module "transit_gateway_us_east_1" {
  source                          = "./aws/modules/transit_gateway"
  name                            = "prod-us-east-1"
  default_route_table_association = "enable"
  description                     = "Transit Gateway for US-East-1 VPCs"
  amazon_side_asn                 = 64514
  region                          = "us-east-1"
}

#Module for Enable VPC Attachments
module "prod_vpc_east_1_tgw_attach" {
  source        = "./aws/modules/transit_vpc_attach"
  subnet_ids    = module.vpc_east_1_deploy.private_subnets #Leverage Private Subnets in VPC Module Above
  transit_gw_id = module.transit_gateway_us_east_1.transit_gw_id #Leverage TGW ID in module above
  vpc_id        = module.vpc_east_1_deploy.my_vpc_id #Leverage TGW ID in module above
  region        = "us-east-1"
}