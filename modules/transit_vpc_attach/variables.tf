variable "name" {
  type    = string
  default = ""
}
variable "default_route_table_association" {
  type    = string
  default = "enable"
}
variable "description" {
  type    = string
  default = "Transit Gateway"
}
variable "amazon_side_asn" {
  type    = number
  default = 64512
}
<<<<<<< HEAD
=======

>>>>>>> 1b3a3f4 (Terraform NAT Gateway Update)
variable "tags" {
  type    = map(string)
  default = {}
}
<<<<<<< HEAD
=======

>>>>>>> 1b3a3f4 (Terraform NAT Gateway Update)
variable "subnet_ids" {
  description = "One attachment subnet per Availability Zone."
  type        = list(string)
}
variable "vpc_id" {
  type = string
}
variable "transit_gw_id" {
  type = string
}
variable "route_table_ids" {
  description = "Unified route table IDs; when null legacy inputs are used."
  type        = list(string)
  default     = null
}
variable "destination_cidrs" {
  description = "Prefixes routed to TGW. Defaults preserve the original RFC1918 routing behavior."
  type        = list(string)
  default     = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}
variable "pub_route_tables" {
  type    = list(string)
  default = []
}
variable "pri_route_tables" {
  type    = list(string)
  default = []
}
variable "single_ngw_route_tables" {
  type    = list(string)
  default = null
}
variable "multi_ngw_route_tables" {
  type    = list(string)
  default = null
}
