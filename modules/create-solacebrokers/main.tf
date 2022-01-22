data "aws_ami" "solace_std" {
  most_recent      = true
  owners = ["${var.ami_owner}"]

  filter {
    name   = "name"
    values = ["solace-pubsub-${var.solace_edition}-${var.solace_version}-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_vpc" "cluster_vpc" {
  filter {
    name = "tag:Name"
    values = [ var.vpc.name ]
  }
}

data "aws_availability_zone" "cluster_az" {
  for_each = var.subnets
  name = format("%s%s", var.region, each.value.az_suffix)
}

data "aws_subnet" "cluster_subnets" {
  for_each = var.subnets

  filter {
    name   = "tag:Name"
    values = [each.value.name]
  }
}

data "aws_security_group" "solace_secgrp" {
  filter {
    name = "tag:Name"
    values = [ var.solace_secgrp.name ]
  }
}

data "template_file" "cloud_init_primary" {
  for_each = var.solace_brokers
  template = file("${path.module}/scripts/cloudInit.tpl")

  vars = {
    hostname = each.value.primary_node.hostname
    fqdn = each.value.primary_node.fqdn
    time_zone = var.time_zone
    ntp_server = var.ntp_server
    max_connection = each.value.solace_config.max_connection
    max_spool_mb = each.value.solace_config.max_spool_mb
    storage_count = length(each.value.storage)
    volume_name = length(each.value.storage) > 0 ? each.value.storage[0].volume_name : ""
    admin_user = var.admin_user
    admin_password = var.admin_password
    is_ha = each.value.ha
    role = "primary"
    node_type = "message_routing"
    router_name = each.value.primary_node.name
    presharedkey = base64encode(each.value.presharedkey)
    primary_host = each.value.primary_node.name
    primary_ip = each.value.primary_node.private_ip
    backup_host = each.value.backup_node.name
    backup_ip = each.value.backup_node.private_ip
    monitor_host = each.value.monitor_node.name
    monitor_ip = each.value.monitor_node.private_ip
  }
}

data "template_file" "cloud_init_backup" {
  for_each = var.solace_brokers
  template = file("${path.module}/scripts/cloudInit.tpl")

  vars = {
    hostname = each.value.backup_node.hostname
    fqdn = each.value.backup_node.fqdn
    time_zone = var.time_zone
    ntp_server = var.ntp_server
    max_connection = each.value.solace_config.max_connection
    max_spool_mb = each.value.solace_config.max_spool_mb
    storage_count = length(each.value.storage)
    volume_name = length(each.value.storage) > 0 ? each.value.storage[0].volume_name : ""
    admin_user = var.admin_user
    admin_password = var.admin_password
    is_ha = each.value.ha
    role = "backup"
    node_type = "message_routing"
    router_name = each.value.backup_node.name
    presharedkey = base64encode(each.value.presharedkey)
    primary_host = each.value.primary_node.name
    primary_ip = each.value.primary_node.private_ip
    backup_host = each.value.backup_node.name
    backup_ip = each.value.backup_node.private_ip
    monitor_host = each.value.monitor_node.name
    monitor_ip = each.value.monitor_node.private_ip
  }
}

data "template_file" "cloud_init_monitor" {
  for_each = var.solace_brokers
  template = file("${path.module}/scripts/cloudInit_monitor.tpl")

  vars = {
    hostname = each.value.monitor_node.hostname
    fqdn = each.value.monitor_node.fqdn
    time_zone = var.time_zone
    ntp_server = var.ntp_server
    storage_count = length(each.value.monitor_storage)
    volume_name = length(each.value.monitor_storage) > 0 ? each.value.monitor_storage[0].volume_name : ""
    admin_user = var.admin_user
    admin_password = var.admin_password
    is_ha = each.value.ha
    role = "monitor"
    node_type = "monitoring"
    router_name = each.value.monitor_node.name
    presharedkey = base64encode(each.value.presharedkey)
    primary_host = each.value.primary_node.name
    primary_ip = each.value.primary_node.private_ip
    backup_host = each.value.backup_node.name
    backup_ip = each.value.backup_node.private_ip
    monitor_host = each.value.monitor_node.name
    monitor_ip = each.value.monitor_node.private_ip
  }
}

locals {
  solace_primary = {
    for k, v in var.solace_brokers : k => {
      name = v.primary_node.name
      instance_type = v.primary_node.instance_type
      subnet_ref = v.primary_node.subnet_ref
      private_ip = v.primary_node.private_ip
      public_ip = v.primary_node.public_ip
      root_size = v.primary_node.root_size
      storage = v.storage
    }
  }
  solace_backup = {
    for k, v in var.solace_brokers : k => {
      name = v.backup_node.name
      instance_type = v.backup_node.instance_type
      subnet_ref = v.backup_node.subnet_ref
      private_ip = v.backup_node.private_ip
      public_ip = v.backup_node.public_ip
      root_size = v.backup_node.root_size
      storage = v.storage
    }
    if v.ha
  }
  solace_monitor = {
    for k, v in var.solace_brokers : k => {
      name = v.monitor_node.name
      instance_type = v.monitor_node.instance_type
      subnet_ref = v.monitor_node.subnet_ref
      private_ip = v.monitor_node.private_ip
      public_ip = v.monitor_node.public_ip
      root_size = v.monitor_node.root_size
      storage = v.monitor_storage
    }
    if v.ha
  }
}

resource "aws_instance" "solace_primary" {
  for_each = local.solace_primary
  ami = data.aws_ami.solace_std.id
  instance_type = each.value.instance_type
  key_name = var.solace_keypair
  vpc_security_group_ids = [ data.aws_security_group.solace_secgrp.id ]
  subnet_id = data.aws_subnet.cluster_subnets[each.value.subnet_ref].id
  private_ip = each.value.private_ip
  user_data = data.template_file.cloud_init_primary[each.key].rendered

  root_block_device {
    volume_size = each.value.root_size
    tags = var.common_tags
  }

  dynamic "ebs_block_device" {
    for_each = each.value.storage
    content {
      device_name = ebs_block_device.value.device_name
      volume_type = ebs_block_device.value.type
      volume_size = ebs_block_device.value.size
      tags = var.common_tags
    }
  }

  tags = merge({
    Name = each.value.name
    }, var.common_tags)
}

resource "aws_instance" "solace_backup" {
  for_each = local.solace_backup
  ami = data.aws_ami.solace_std.id
  instance_type = each.value.instance_type
  key_name = var.solace_keypair
  vpc_security_group_ids = [ data.aws_security_group.solace_secgrp.id ]
  subnet_id = data.aws_subnet.cluster_subnets[each.value.subnet_ref].id
  private_ip = each.value.private_ip
  user_data = data.template_file.cloud_init_backup[each.key].rendered

  root_block_device {
    volume_size = each.value.root_size
    tags = var.common_tags
  }

  dynamic "ebs_block_device" {
    for_each = each.value.storage
    content {
      device_name = ebs_block_device.value.device_name
      volume_type = ebs_block_device.value.type
      volume_size = ebs_block_device.value.size
      tags = var.common_tags
    }
  }

  tags = merge({
    Name = each.value.name
    }, var.common_tags)
}

resource "aws_instance" "solace_monitor" {
  for_each = local.solace_monitor
  ami = data.aws_ami.solace_std.id
  instance_type = each.value.instance_type
  key_name = var.solace_keypair
  vpc_security_group_ids = [ data.aws_security_group.solace_secgrp.id ]
  subnet_id = data.aws_subnet.cluster_subnets[each.value.subnet_ref].id
  private_ip = each.value.private_ip
  user_data = data.template_file.cloud_init_monitor[each.key].rendered

  root_block_device {
    volume_size = each.value.root_size
    tags = var.common_tags
  }

  dynamic "ebs_block_device" {
    for_each = each.value.storage
    content {
      device_name = ebs_block_device.value.device_name
      volume_type = ebs_block_device.value.type
      volume_size = ebs_block_device.value.size
      tags = var.common_tags
    }
  }
  
  tags = merge({
    Name = each.value.name
    }, var.common_tags)
}