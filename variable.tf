variable "profile" {
  description = "AWS Profile"
  type        = string
  default     = "default"
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "ap-southeast-1"
}

variable "common_tags" {
  description = "Common Resource Tags"
  type = map
  default = {}
}

variable "vpc" {
  description = "AWS VPC"
  type = object({
    create = bool
    name = string
    cidr = string
    add_cidrs = list(string)
  })
}

variable "subnets" {
  description = "AWS Subnets"
  type = object({
    create = bool
    subnets = map(object({
      name = string
      cidr = string
      az_suffix = string
    }))
  })
}

variable "solace_secgrp" {
  description = "Security Group for Solace"
  type = object({
    create = bool
    name = string
    ingress = map(object({
      from_port = string
      to_port = string
      protocol = string
      cidr_blocks = list(string)
    }))
  })
}

variable "solace_keypair" {
  description = "Solace Key Pair"
  type = object({
    create = bool
    name = string
  })
}

variable "solace_brokers" {
  description = "Solace Brokers"
  type = object({
    create = bool
    brokers = map(object({
      ha = bool
      presharedkey = string
      primary_node = object({
        name = string
        instance_type = string
        subnet_ref = string
        private_ip = string
        public_ip = string
      })
      
      backup_node = object({
        name = string
        instance_type = string
        subnet_ref = string
        private_ip = string
        public_ip = string
      })
      monitor_node = object({
        name = string
        instance_type = string
        subnet_ref = string
        private_ip = string
        public_ip = string
      })
      
      storage = object({
        type = string
        device_name = string
        size = number
      })
      
      solace_config = object({
        max_connection = number
        max_spool_mb = number
        volume_name = string
      })
    }))
  })
}

variable "admin_user" {
  description = "Solace Admin user"
  type        = string
  default     = "admin"
}

variable "admin_password" {
  description = "Solace Admin password"
  type        = string
}

variable "time_zone" {
  description = "Timezone"
  type = string
  default = "Asia/Singapore"
}

variable "ntp_server" {
  description = "NTP Server"
  type = string  
}

variable "solace_version" {
  description = "Solace Broker version"
  type = string
  default = "9.10.0.15"
}

variable "solace_edition" {
  description = "Solace Broker edition"
  type = string
  default = "standard"
}

variable "ami_owner" {
  description = "Solace Image Owner"
  type = string
  default = "910732127950"
}
