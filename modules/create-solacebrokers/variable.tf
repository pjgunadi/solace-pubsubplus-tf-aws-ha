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
    name = string
  })
}

variable "subnets" {
  description = "AWS Subnets"
  type = map(object({
    name = string
    az_suffix = string
  }))
}

variable "solace_secgrp" {
  description = "Security Group for Solace"
  type = object({
    name = string
  })
}

variable "solace_keypair" {
  description = "Solace Key Pair"
  type        = string
}

variable "solace_brokers" {
  description = "Solace Brokers"
  type = map(object({
      ha = bool
      presharedkey = string
      primary_node = object({
        name = string
        instance_type = string
        subnet_ref = string
        private_ip = string
        public_ip = string
        root_size = number
        hostname = string
        fqdn = string
      })
      
      backup_node = object({
        name = string
        instance_type = string
        subnet_ref = string
        private_ip = string
        public_ip = string
        root_size = number
        hostname = string
        fqdn = string
      })
      monitor_node = object({
        name = string
        instance_type = string
        subnet_ref = string
        private_ip = string
        public_ip = string
        root_size = number
        hostname = string
        fqdn = string
      })
      
      storage = list(object({
        volume_name = string
        type = string
        device_name = string
        size = number
      }))

      monitor_storage = list(object({
        volume_name = string
        type = string
        device_name = string
        size = number
      }))
      
      solace_config = object({
        max_connection = number
        max_spool_mb = number
      })
    }))
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