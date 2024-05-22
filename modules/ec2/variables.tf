variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = ""
}

variable "iam_instance_profile" {
  description = "IAM Instance Profile/Role"
  type        = string
  default     = null
}

variable "instance_count" {
  description = "How many instances to deploy"
  type        = number
  default     = 1
}

variable "ami" {
  description = "AMI ID"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "Instance type to be used"
  type        = string
  default     = ""
}

variable "vpc_security_group_ids" {
  description = "Security Groups"
  type        = list(string)
  default     = [""]
}

variable "subnet_id" {
  description = "Subnet ID"
  type        = string
  default     = "subnet-068e2114e4b5cf5ed"
}

variable "volume_type" {
  description = "Volume type for root volume gp2, gp3, i2, etc)"
  type        = string
  default     = "gp2"
}

variable "volume_size" {
  description = "Volume Size for root volume"
  type        = number
  default     = 30
}

variable "root_block_device" {
  description = "Root EBS Volume Allows you to set drive name, size, and type"
  type        = list(map(string))
  default     = []
}

variable "key_name" {
  description = "The key name to use for the instance"
  type        = string
  default     = ""
}

variable "host_id" {
  description = "Dedicated Host ID"
  type        = string
  default     = null
}

variable "tenancy" {
  description = "The tenancy of the instance (if the instance is running in a VPC). Available values: default, dedicated, host."
  type        = string
  default     = "default"
}


variable "custom_tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "private_ip" {
  description = "Private IP address to associate with the instance in a VPC"
  type        = list(string)
  default     = null
}

variable "secondary_private_ips" {
  description = "A list of secondary private IPv4 addresses to assign to the instance's primary network interface (eth0) in a VPC"
  type        = list(string)
  default     = null
}

variable "device_index" {
  description = "Integer to define the devices index, 0 is the default device_index/primary interface"
  type        = number
  default     = 0
}

variable "private_ips" {
  description = "A list of private IP address to associate with the instance in a VPC. Should match the number of instances."
  type        = list(string)
  default     = []
}

variable "multi_volume_instance" {
  description = "If instance needs multiple Volumes/Disk enable this option and pass the volume names and number of volumes needed"
  type        = bool
  default     = false
}

variable "ebs_device_names" {
  description = "Volume names example: /dev/sda or xvfa"
  type        = list(string)
  default = [
    "/dev/sdd",
    "/dev/sde"
  ]
}

variable "ebs_volume_count" {
  description = "How many Volumes do you want to create"
  type        = number
  default     = 2
}

variable "ec2_ebs_volume_size" {
  description = "Enter the Volume size for each volume in order"
  type        = list(number)
  default = [
    50,
    50
  ]
}

variable "multi_interface_instance" {
  description = "If instance needs multiple Interfaces enable this option and pass the interface IP"
  type        = bool
  default     = false
}

variable "ec2_interface_count" {
  description = "How many ENIs you want to create"
  type        = number
  default     = 2
}

variable "ec2_interface_ip" {
  description = "ENIs allow you to apply multiple IPs to one interface or you can past a list of IPs to for loop and create multiple interfaces"
  type        = list(list(string))
  default = [
    ["10.0.0.50"],
    ["10.0.0.65"]
  ]
}

variable "ec2_interface_subnet_ids" {
  description = "Subnets IDs for each interface in order"
  type        = list(string)
  default     = ["subnet-xxx", "subnet-xxx"]
}

variable "interfaces_description" {
  description = "Interfaces decsription - needed for SBCE Deployment"
  type        = list(string)
  default     = [""]
}