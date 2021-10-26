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
    cidr = string
    az_suffix = string
  }))
}
