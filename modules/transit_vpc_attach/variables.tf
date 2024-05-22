variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = ""
}

variable "default_route_table_association"{
    description = "Whether resource attachments are automatically associated with the default association route table. Valid values: disable, enable. Default value: enable"
    default = "enable"
}

variable "description"{
    description = "Description of the EC2 Transit Gateway."
    default = "Transit Gateway"
}

variable "amazon_side_asn"{
    description = "Private Autonomous System Number (ASN) for the Amazon side of a BGP session."
    type = number
    default = "64512"
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "subnet_ids"{
    description = "A list of public subnets inside the VPC"
    type        = list(string)
    default     = []
}

variable "vpc_id"{
    description = "VPC ID"
    type = string
    default = ""
}

variable "region" {
  description = "The primary region where Terraform will deploy infrastructure."
  type        = string
}

variable "transit_gw_id"{
    description = "Transit Gateway ID"
    type = string
    default = ""
}
