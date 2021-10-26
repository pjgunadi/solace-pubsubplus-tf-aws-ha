# Sample Terraform Script for Deploying Solace PubSub+ Software (Standalone or HA) in AWS

## Pre-requisite
Install and configure [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)

## Description
This template use internal modules for each AWS resource. It allow flexible implementation for various resource usage combinations. The script can create all required AWS resources or create partial resources by reusing other existing resources. Example:
- Reuse existing VPC, Subnets, and Security Group
- Create new Key-pairs and Solace instances

Because of this modularity, there is no dependency from one module with another. Hence, when creating more than one resource, it is recommended to create one resource at a time as Terraform script provision resources concurrently when there is no dependencies.

## Configuration
1. Download this template
2. Create variable file `terraform.tfvars`. See sample file [terraform_tfvars.sample](./terraform_tfvars.sample)
3. Common configuration:
   - AWS CLI Profile:
```
profile = "default"
```
   - AWS Region:
```
region = "ap-southeast-1"
```
   - Assign your own `common_tags`:
```
common_tags = {
  Owner = "Paulus"
  Environment = "Test"
  YourKey = "Your Tag Value"
}
```
4. Resource configuration:
   All resources has `create` flag indicating whether the resource should be created in AWS. When `create` attribute is `true`, the script will create the resource in AWS, otherwise it will lookup existing resource filter by `Name` tag.
   
   The following are the variables of AWS resources:
### VPC
```
vpc = {
  create = true
  name = "solace"
  cidr = "10.100.0.0/16"
  add_cidrs = []
}
```
### Subnets
```
subnets = {
  create = true
  subnets = {
    solace-subnet-a = { 
      name = "solace-subnet-a"
      cidr = "10.100.1.0/24"
      az_suffix = "a" #Availability Zone suffix
    }
    solace-subnet-b = { 
      name = "solace-subnet-b"
      cidr = "10.100.2.0/24"
      az_suffix = "b"
    }
    solace-subnet-c = { 
      name = "solace-subnet-c"
      cidr = "10.100.3.0/24"
      az_suffix = "c"
    }
  }
}
```
### Security Groups
```
solace_secgrp = {
  create = true
  name = "solace-secgrp"
  ingress = {
    ssh = {
      from_port = "22"
      to_port = "22"
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    cli = {
      from_port = "2222"
      to_port = "2222"
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    https = {
      from_port = "1943"
      to_port = "1943"
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    smf_tls = {
      from_port = "55443"
      to_port = "55443"
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
```
### Key-pairs
```
solace_keypair = {
  create = true
  name = "solace-keypair"
}
```
### Solace Instances
- Solace Image version:
```
solace_edition="standard"
solace_version="9.11.0.10"
```
- Optional configuration:
```
admin_user="admin"
admin_password="yourpassword"
time_zone="Asia/Singapore"
ntp_server="pool.ntp.org"
```
- Solace brokers configuration:
This sample has two sets of brokers: 1) HA setup, 2) Standalone:
```
solace_brokers = {
  create = true
  brokers = {
    pgsolace1 = {
      ha = true
      presharedkey = "Pre-Shared Authentication Keys for Software Event Brokers"
      primary_node = {
        name = "pgsolace1a"
        instance_type = "t3.medium"
        subnet_ref = "solace-subnet-a"
        private_ip = "10.100.1.11"
        public_ip = ""
      }
      backup_node = {
        name = "pgsolace1b"
        instance_type = "t3.medium"
        subnet_ref = "solace-subnet-b"
        private_ip = "10.100.2.11"
        public_ip = ""
      }
      monitor_node = {
       name = "pgsolace1c"
        instance_type = "t3.medium"
        subnet_ref = "solace-subnet-c"
        private_ip = "10.100.3.11"
        public_ip = ""
      }
      storage = {
        type = "gp2"
        device_name = "/dev/sdb"
        size = 30
      }
      solace_config = {
        max_connection = 100
        max_spool_mb = 1000
        volume_name = "nvme1n1"
      }
    }
    pgsolace2 = {
      ha = false
      presharedkey = ""
      primary_node = {
        name = "pgsolace2"
        instance_type = "t3.medium"
        subnet_ref = "solace-subnet-b"
        private_ip = "10.100.2.21"
        public_ip = ""
      }
      backup_node = {
        name = ""
        instance_type = ""
        subnet_ref = ""
        private_ip = ""
        public_ip = ""
      }
      monitor_node = {
       name = ""
        instance_type = ""
        subnet_ref = ""
        private_ip = ""
        public_ip = ""
      }
      storage = {
        type = "gp2"
        device_name = "/dev/sdb"
        size = 30
      }
      solace_config = {
        max_connection = 100
        max_spool_mb = 1000
        volume_name = "nvme1n1"
      }
    }
  }
}

```

## Terraform Command
1. Initialize:
```
terraform init -upgrade
```
2. Review Plan:
```
terraform plan
```
3. Apply Template:
```
terraform apply [--auto-approve]
```
4. Decommission resources:
```
terraform destroy [--auto-approve]
```

## Reference:
- [Solace manual setup for AWS](https://docs.solace.com/Solace-SW-Broker-Set-Up/Starting-SW-Brokers-for-the-First-Time/Set-Up-AWS-Manually.htm)
- [Solace HA Configuration](https://docs.solace.com/Configuring-and-Managing/Configuring-HA-Groups.htm)

**Notice:**
Running this script may incure charges in your AWS account depending on your resource consumption.
