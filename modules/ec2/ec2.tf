# AMI ISO EC2 instances

resource "aws_instance" "this" {
  count = var.instance_count

  ami                    = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = var.vpc_security_group_ids
  subnet_id              = var.subnet_id
  key_name               = var.key_name
  private_ip             = element(var.private_ip, count.index)
  secondary_private_ips  = var.secondary_private_ips
  iam_instance_profile   = var.iam_instance_profile
  host_id                = var.host_id
  tenancy                = var.tenancy

  root_block_device {
    volume_type = var.volume_type
    volume_size = var.volume_size
  }

  tags = merge({ Name = var.name }, var.custom_tags)
}

resource "aws_ebs_volume" "ebs_volume" {
  # If multi_volume_instance is true then note how many instances are deployed and create the # of volumes needed
  count             = var.multi_volume_instance == true ? var.instance_count * var.ebs_volume_count : 0
  availability_zone = element(aws_instance.this.*.availability_zone, count.index)
  size              = element(var.ec2_ebs_volume_size, count.index)
}

resource "aws_volume_attachment" "volume_attachement" {
  # If multi_volume_instance is true then note how many instances are deployed and attach the volume created in aws_ebs_volume assigned to each instance
  count       = var.multi_volume_instance == true ? var.instance_count * var.ebs_volume_count : 0
  volume_id   = aws_ebs_volume.ebs_volume.*.id[count.index]
  device_name = element(var.ebs_device_names, count.index)
  instance_id = element(aws_instance.this.*.id, count.index)
}

resource "aws_network_interface" "this_nic" {
  # If multi_volume_instance is true then note how many instances are deployed and create the # of volumes needed
  count           = var.multi_interface_instance == true ? var.instance_count * var.ec2_interface_count : 0
  subnet_id       = element(var.ec2_interface_subnet_ids, count.index)
  private_ips     = element(var.ec2_interface_ip, count.index)
  security_groups = var.vpc_security_group_ids
  description     = element(var.interfaces_description, count.index)

  attachment {
    instance     = element(aws_instance.this.*.id, count.index)
    device_index = var.device_index + count.index + 1
    # device_index = 0 + the index of the interface we are setting up + 1
    # Example 2 interfaces needed:
    # Interface 0 is taken because of primary interface
    # To add first interface its 0+0 (we are on the first ip in the list)+1 = 1 (device_index = 1)
    # To add second interface its 0+1 (we are on the second ip in the list) +1 = 2 (device_index =2) 
  }
}