#cloud-config
%{ if time_zone != "" ~}
timezone: ${time_zone}
%{ endif ~}
%{ if ntp_server != "" ~}
write_files:
  - path: /etc/ntp.conf
    permissions: 0600
    owner: root:root
    content: |
      tinker panic 0
      disable monitor
      restrict default ignore
      restrict 127.0.0.1
      restrict ::1
      server ${ntp_server}
      restrict ${ntp_server}
runcmd:
  - systemctl enable ntpd
  - systemctl start ntpd
%{ endif ~}

solace:
  configuration_keys:
    routername: ${router_name}
    system_scaling_maxconnectioncount: ${max_connection}
%{ if max_spool_mb > 0 ~}
    messagespool_maxspoolusage: ${max_spool_mb}
%{ endif ~}
%{ if (admin_user != "") && (admin_password != "") ~}
    username_admin_globalaccesslevel: ${admin_user}
    username_admin_password: ${admin_password}
%{ endif ~}
%{ if is_ha ~}
    configsync_enable: yes
    nodetype: ${node_type}
    redundancy_enable: yes
    redundancy_activestandbyrole: ${role}
    redundancy_authentication_presharedkey_key: ${presharedkey}
    redundancy_group_node_${primary_host}_connectvia: ${primary_ip}
    redundancy_group_node_${primary_host}_nodetype: message_routing
    redundancy_group_node_${backup_host}_connectvia: ${backup_ip}
    redundancy_group_node_${backup_host}_nodetype: message_routing
    redundancy_group_node_${monitor_host}_connectvia: ${monitor_ip}
    redundancy_group_node_${monitor_host}_nodetype: monitoring
%{ endif ~}
%{ if volume_name != "" && storage_count > 0 ~}
  storage:
    adb:
      device: ${volume_name}
    internalSpool:
      device: ${volume_name}
    adbBackup:
      device: ${volume_name}
    diagnostics:
      device: ${volume_name}
    jail:
      device: ${volume_name}
    var:
      device: ${volume_name}
%{ endif ~}