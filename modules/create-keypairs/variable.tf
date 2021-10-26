variable "solace_keypair" {
  description = "Solace Key Pair"
  type        = string
}

variable "common_tags" {
  description = "Common Resource Tags"
  type = map
  default = {}
}