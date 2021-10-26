variable "common_tags" {
  description = "Common Resource Tags"
  type = map
  default = {}
}

variable "vpc" {
  description = "AWS VPC"
  type = object({
    name = string
    cidr = string
    add_cidrs = list(string)
  })
}
