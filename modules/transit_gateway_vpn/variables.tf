variable "bgp_number" {
  description = "BGP Number for AWS Transit Gateway"
  type        = number
  default     = 64520
}

variable "vpn_ip_address" {
  description = "Public IP address of VPN tunnel endpoint"
  type        = string
  default     = "8.8.8.8"
}

variable "transit_gw_id" {
  description = "Transit Gateway ID"
  type        = string
  default     = ""
}

variable "client_campus_network_routes" {
  description = "A list of routes to forward over VPN tunnel to client VPN endpoint"
  type        = list(string)
  default     = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}

variable "tgw_association_default_route_table_id" {
  description = "TGW Route Table to add routes to"
  type        = string
  default     = ""
}