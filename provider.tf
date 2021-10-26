terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.41"
    }
  }

  required_version = ">= 0.15.3"
}

provider "aws" {
  profile = var.profile
  region  = var.region
}
