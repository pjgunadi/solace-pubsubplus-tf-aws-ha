variable "vpc" {
  description = "AWS VPC"
  type = object({
    name = string
  })
}

variable "common_tags" {
  description = "Common Resource Tags"
  type = map
  default = {}
}

variable "solace_secgrp" {
  description = "Security Group for Solace"
  type = object({
    name = string
    ingress = map(object({
      from_port = string
      to_port = string
      protocol = string
      cidr_blocks = list(string)
    }))
  })
}