# Sample Terraform Script for Deploying Solace PubSub+ Software (Standalone or HA) in AWS

## Pre-requisite
Install and configure [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)

## Description
This template use internal modules for each AWS resource. It allow flexible implementation for various resource usage combinations. The script can create all required AWS resources or create partial resources by reusing other existing resources. Example:
- Reuse existing VPC, Subnets, and Security Group
- Create new Key-pairs and Solace instances

In order to reuse existing resource, set attribute `create = false ` for the object.

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
Example for creating a new VPC:
```
vpc = {
  create = true
  name = "solace"
  cidr = "10.100.0.0/16"
  add_cidrs = []
}
```
Example for reusing existing VPC:
```
vpc = {
  create = false
  name = "solace"
  cidr = "10.100.0.0/16"
  add_cidrs = []
}
```
### Subnets
```
subnets = {
  create = true
  subnets = [
    { 
      name = "solace-subnet-a"
      cidr = "10.100.1.0/24"
      az_suffix = "a" #Availability Zone suffix
    },
    { 
      name = "solace-subnet-b"
      cidr = "10.100.2.0/24"
      az_suffix = "b"
    },
    { 
      name = "solace-subnet-c"
      cidr = "10.100.3.0/24"
      az_suffix = "c"
    }
  ]
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
        root_size = 10
      }
      backup_node = {
        name = "pgsolace1b"
        instance_type = "t3.medium"
        subnet_ref = "solace-subnet-b"
        private_ip = "10.100.2.11"
        public_ip = ""
        root_size = 10
      }
      monitor_node = {
       name = "pgsolace1c"
        instance_type = "t3.medium"
        subnet_ref = "solace-subnet-c"
        private_ip = "10.100.3.11"
        public_ip = ""
        root_size = 30
      }
      storage = [
        {
          volume_name = "nvme1n1"
          type = "gp2"
          device_name = "/dev/sdb"
          size = 30
        }
      ]
      solace_config = {
        max_connection = 100
        max_spool_mb = 1000
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
        root_size = 10
      }
      backup_node = {
        name = ""
        instance_type = ""
        subnet_ref = ""
        private_ip = ""
        public_ip = ""
        root_size = 0
      }
      monitor_node = {
       name = ""
        instance_type = ""
        subnet_ref = ""
        private_ip = ""
        public_ip = ""
        root_size = 0
      }
      storage = [
        {
          volume_name = "nvme1n1"
          type = "gp2"
          device_name = "/dev/sdb"
          size = 30
        }
      ]
      solace_config = {
        max_connection = 100
        max_spool_mb = 1000
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

## Access to Solace VM
Use your certificate to connect to your Solace VM:
```
ssh -i <your-private-key-file> sysadmin@solace-ip
```

## Required Step for Completing HA
After provisioning Solace PubSub+ HA triplet, there is one manual step required from CLI:
1. SSH to your primary node
2. Open CLI:
```
solacectl cli
```
3. Assert leader on primary node:
```
solace> enable
solace# admin
solace(admin)# config-sync assert-leader router
solace(admin)# end
```
4. Wait for about 30 seconds, then verify:
```
solace# show config-sync
```
The first two lines status should show:
```
Admin Status                      : Enabled
Oper Status                       : Up
```

## Reference:
- [Solace manual setup for AWS](https://docs.solace.com/Solace-SW-Broker-Set-Up/Starting-SW-Brokers-for-the-First-Time/Set-Up-AWS-Manually.htm)
- [Solace HA Configuration](https://docs.solace.com/Configuring-and-Managing/Configuring-HA-Groups.htm)

**Notice:**
Running this script may incure charges in your AWS account depending on your resource consumption.
