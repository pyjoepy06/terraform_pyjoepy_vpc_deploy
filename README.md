# Terraform AWS VPC Deployment — NAT modernization

VPC, subnet, NAT Gateway and Transit Gateway attachment modules. Supports **none**, **single**, **per_az**, and **regional** NAT configurations.

## NAT modes

| Mode | Behavior | Public subnets needed for NAT? |
| --- | --- | --- |
| `none` | No NAT; private subnets have no default internet route | No |
| `single` | One zonal NAT, shared across private AZs | Yes |
| `per_az` | One zonal NAT in each AZ containing private subnets | Yes, one per private AZ |
| `regional` | One Regional NAT resource, AWS-managed AZ expansion | No |

Set `nat_gateway_mode = "regional"` on a VPC module to use the new option. The legacy `enable_nat_gateway` and `single_nat_gateway` flags remain supported **only when** `nat_gateway_mode = null` (the default). Regional NAT requires AWS provider >= 6.24.0 and a supported commercial AWS Region. Public Regional NAT requires an Internet Gateway, but not public subnets.

### Example: private-only Regional NAT VPC

```hcl
module "workload_vpc" {
  source             = "./modules/vpc"
  name               = "workload"
  cidr_block         = "10.50.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]
  public_subnets     = []
  private_subnets    = ["10.50.10.0/24", "10.50.20.0/24"]
  nat_gateway_mode   = "regional"
}
```

### Example: Transit Gateway attachment with unified routing

```hcl
module "attachment" {
  source            = "./modules/transit_vpc_attach"
  subnet_ids        = module.workload_vpc.tgw_attachment_subnet_ids
  vpc_id            = module.workload_vpc.vpc_id
  transit_gw_id     = module.transit_gateway.tgw_id
  route_table_ids   = module.workload_vpc.all_route_table_ids
  destination_cidrs = ["10.100.0.0/16", "172.20.0.0/16"]
}
```

The TGW module accepts the old route-table inputs when `route_table_ids` is omitted. The default destination prefixes preserve the old three RFC1918 aggregate routes, but **you should explicitly scope prefixes for production**. TGW attachments must use exactly one subnet per AZ. Subnets are mapped by position to `availability_zones`; the module supports one public and one private subnet per AZ.

## Existing deployments: migration warnings

**Review `terraform plan` carefully before applying.** Changing NAT modes can replace NAT Gateways, route tables, and subnet associations and interrupt connections or change public egress IPs. The old multi-NAT logic assigned public subnets by list index, potentially placing multiple NATs in one AZ; the corrected implementation maps NATs to private AZs. Existing resources may need migration and/or recreation.

The Transit Gateway route resources have been consolidated from `class_a_*`, `class_b_*`, and `class_c_*` into `aws_route.tgw_routes`. Terraform will otherwise propose deleting/recreating these route resources. Use carefully reviewed `terraform state mv` or `moved` blocks for existing state, or plan a maintenance window. Do not blindly apply this change to an existing production deployment.

For new infrastructure:

```bash
terraform init -upgrade
terraform fmt -recursive
terraform validate
terraform plan
```

This branch is for review and testing; no infrastructure has been deployed. Regional NAT charges are based on active AZs and data processing; it is not inherently cheaper than zonal NAT. Private NAT Gateway functionality is not replaced by Regional NAT.

## Security note

Review the existing `modules/security_groups/sg.tf` before using in production; it permits all inbound IPv4 traffic. Also review historical Terraform state files in version control for secrets and remove them safely if present.

## Author

Joel Gray — Apache 2.0 licensed.
