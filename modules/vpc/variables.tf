variable "region" { type = string, default = "us-east-1" }
variable "name" { type = string, default = "" }
variable "cidr_block" { type = string, default = "10.20.0.0/16" }
variable "public_subnet_suffix" { type = string, default = "public" }
variable "private_subnet_suffix" { type = string, default = "private" }
variable "public_subnets" { type = list(string), default = [] }
variable "private_subnets" { type = list(string), default = [] }
variable "availability_zones" { type = list(string), default = [] }
variable "enable_nat_gateway" {
  description = "Legacy NAT enable flag. Used only when nat_gateway_mode is null."
  type = bool
  default = false
}
variable "single_nat_gateway" {
  description = "Legacy single NAT flag. Used only when nat_gateway_mode is null."
  type = bool
  default = false
}
variable "enable_igw" { type = bool, default = true }
variable "nat_gateway_mode" {
  description = "Explicit mode: none, single, per_az, regional. Null preserves legacy flags."
  type = string
  default = null
  validation {
    condition = var.nat_gateway_mode == null ? true : contains(["none", "single", "per_az", "regional"], var.nat_gateway_mode)
    error_message = "nat_gateway_mode must be none, single, per_az, regional, or null."
  }
}
