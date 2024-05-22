# AWS_TF_VPC_DEPLOY

Deploying VPCs in AWS varies per client this code is used to deploy a VPC with multiple subnets and is able to enable or disable NAT Gateway on a deployed VPC by simply updating one variable as true or false

## Requirements for executing code

To run this code you need to leverage, also update your **backend.tf** if your saving state files to S3 or Terraform Cloud:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

### How can this help with day-to-day tasks

- Run this script to deploy any kind of VPC you want (PublicxPrivate) 3x1, 2x2, 4x4, etc
- To run this script in multi-regions in the same account simply use the Projects Folder and create sub-folders with the main.tf and providers.tf files
- In the main.tf and providers.tf and update your region and variables, cd to the folder, run the terraform init, plan, and apply and watch your VPC get build!!!

## Usage

The main.tf will execute the following code below are examples of deploy multiple options of VPCs and the VPCs get attached to a TGW with all Class A, Class B, Class C routes auto added to the route table

```hcl
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
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## VPC Module Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="name"></a> [name](#name) | Name to be used on all the resources as identifier | `string`  | n/a | no |
| <a name="region"></a> [region](#region) | The primary region where Terraform will deploy infrastructure. | `string` | n/a | no |
| <a name="create_vpc"></a> [create_vpc](#create_vpc) |  Controls if VPC should be created (it affects almost all resources) | `bool` | true | yes | n/a |
| <a name="cidr"></a> [cidr](#cidr) |  The CIDR block for the VPC. Default value is a valid CIDR, but should be overridden | `"10.20.0.0/16"` | n/a | yes |
| <a name=public_subnet_suffix"></a> [public\_subnet\_suffix](#public\_subnet\_suffix) |  Suffix to append to public subnets name | `string` | `"public"` |no |
| <a name=private_subnet_suffix"></a> [private\_subnet\_suffix](#private\_subnet\_suffix) |  Suffix to append to private subnets name | `string` | `"private"` | no |
| <a name="public_subnets"></a> [public\_subnets](#public\_subnets) | A list of public subnets inside the VPC | `list(string)` | `[]` | yes |
| <a name="private_subnets"></a> [private\_subnets](#private\_subnets) | A list of private subnets inside the VPC | `list(string)` | `[]` | yes |
| <a name="availability_zones"></a> [availability\_zones](#availability\_zones) | A list of availablity zones for your subnets | `list(string)` | `[]` | yes |
| <a name="enable_nat_gateway"></a> [enable\_nat\_gateway](#enable\_nat\_gateway) | Should be true if you want to provision NAT Gateways for each of your private networks | `bool` | `false` | no |
| <a name="single_nat_gateway"></a> [single\_nat\_gateway](#single\_nat\_gateway) | Should be true if you want to provision a single shared NAT Gateway across all of your private networks | `bool` | `false` | no |

## VPC Module Outputs

| Name | Description |
|------|-------------|
| public_subnets | Subnet IDs of all public subnets |
| private_subnets | Subnet IDs of all private subnets |
| vpc_cidr | VPC CIDR |
| public_ip_nat | A List of NAT Gateway Public IPs |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


### Peding Feature Fix

- If no Public Subnet is provide the code errors out due to tuple lookup
- Reverting from Single NAT to HA Nat Gateway needs to be fixed
- Deleting Subnets that have TGW attachments in them causes timeout issues, possibly create code to that detects if ENIs are used in Subnets for TGW and/or delete subnets manually

## Authors

Module managed by [Joel Gray](https://github.com/pyjoepy06).

## License

Apache 2 Licensed. See LICENSE for full details.