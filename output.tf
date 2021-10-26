output "solace_node" {
  description = "Solace Node"
  value       = {
    for k, v in module.create-solacebrokers: k => {
        # primary_node
        primary_id = v.primary_id
        primary_ip = v.primary_ip
        # backup_node
        backup_id = v.backup_id
        backup_ip = v.backup_ip
        # monitor_node {
        monitor_id = v.monitor_id
        monitor_ip = v.monitor_ip
    }
    # if length(module.create-solacebrokers) > 0
  }
}
