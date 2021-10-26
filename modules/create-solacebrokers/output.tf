output "primary_id" {
  description = "Solace Primary Node Id"
  value       = {
    for k, v in aws_instance.solace_primary: k => v.id
  }
}

output "backup_id" {
  description = "Solace Backup Node Id"
  value       = {
    for k, v in aws_instance.solace_backup: k => v.id
  }
}

output "monitor_id" {
  description = "Solace Monitor Node Id"
  value       = {
    for k, v in aws_instance.solace_monitor: k => v.id
  }
}

output "primary_ip" {
  description = "Solace Primary Node IP"
  value       = {
    for k, v in aws_instance.solace_primary: k => v.public_ip
  }
}

output "backup_ip" {
  description = "Solace Backup Node IP"
  value       = {
    for k, v in aws_instance.solace_backup: k => v.public_ip
  }
}

output "monitor_ip" {
  description = "Solace Monitor Node IP"
  value       = {
    for k, v in aws_instance.solace_monitor: k => v.public_ip
  }
}