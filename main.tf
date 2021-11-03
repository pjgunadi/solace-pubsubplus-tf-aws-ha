
module "create-vpc" {
  source = "./modules/create-vpc"
  count = var.vpc.create == false ? 0 : 1
  vpc = var.vpc
  common_tags = var.common_tags
}

module "create-subnets" {
  source = "./modules/create-subnets"
  count = var.subnets.create == false ? 0 : 1
  vpc = {
    name = var.vpc.name
  }
  region = var.region
  subnets = var.subnets.subnets
  common_tags = var.common_tags
  depends_on = [
    module.create-vpc
  ]
}

module "create-securitygroup" {
  source = "./modules/create-securitygroup"
  count = var.solace_secgrp.create == false ? 0 : 1
  vpc = {
    name = var.vpc.name
  }
  solace_secgrp = var.solace_secgrp
  common_tags = var.common_tags
  depends_on = [
    module.create-vpc
  ]
}

module "create-keypairs" {
  source = "./modules/create-keypairs"
  count = var.solace_keypair.create == false ? 0 : 1
  solace_keypair = var.solace_keypair.name
  common_tags = var.common_tags
}

module "create-solacebrokers" {
  source = "./modules/create-solacebrokers"
  count = var.solace_brokers.create == false ? 0 : 1
  region = var.region
  vpc = {
    name = var.vpc.name
  }

  subnets = var.subnets.subnets
  solace_keypair = var.solace_keypair.name
  solace_secgrp = var.solace_secgrp
  solace_brokers = var.solace_brokers.brokers
  common_tags = var.common_tags
  solace_version = var.solace_version
  solace_edition = var.solace_edition
  admin_user = var.admin_user
  admin_password = var.admin_password
  time_zone = var.time_zone
  ntp_server = var.ntp_server
  depends_on = [
    module.create-vpc,
    module.create-subnets,
    module.create-securitygroup,
    module.create-keypairs,
  ]
}
