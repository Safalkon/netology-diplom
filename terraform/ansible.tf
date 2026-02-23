# Ansible inventory generation
resource "local_file" "ansible_inventory_ini" {
  filename = "${path.module}/../ansible/inventory.ini"
  content = templatefile("${path.module}/templates/inventory.ini.tpl", {
    alb_public_ip = try(yandex_alb_load_balancer.web.listener[0].endpoint[0].address[0].external_ipv4_address[0].address, "")
    bastion_public_ip   = try(yandex_compute_instance.bastion.network_interface[0].nat_ip_address, "")
    bastion_internal_ip = try(yandex_compute_instance.bastion.network_interface[0].ip_address, "")
    bastion_fqdn        = try(yandex_compute_instance.bastion.fqdn, "")
    
    zabbix_public_ip   = try(yandex_compute_instance.zabbix.network_interface[0].nat_ip_address, "")
    zabbix_internal_ip = try(yandex_compute_instance.zabbix.network_interface[0].ip_address, "")
    zabbix_fqdn        = try(yandex_compute_instance.zabbix.fqdn, "")
    
    elasticsearch_internal_ip = try(yandex_compute_instance.elasticsearch.network_interface[0].ip_address, "")
    elasticsearch_fqdn        = try(yandex_compute_instance.elasticsearch.fqdn, "")
    
    kibana_public_ip   = try(yandex_compute_instance.kibana.network_interface[0].nat_ip_address, "")
    kibana_internal_ip = try(yandex_compute_instance.kibana.network_interface[0].ip_address, "")
    kibana_fqdn        = try(yandex_compute_instance.kibana.fqdn, "")
    
    web_servers = try([
      for instance in yandex_compute_instance_group.web_ig.instances : {
        fqdn = instance.fqdn
        ip   = instance.network_interface[0].ip_address
        zone = instance.zone_id
      }
    ], [])
    
    vm_user = var.vm_user
  })
  depends_on = [
    yandex_compute_instance.bastion,
    yandex_compute_instance.zabbix,
    yandex_compute_instance.elasticsearch,
    yandex_compute_instance.kibana,
    yandex_compute_instance_group.web_ig,yandex_alb_load_balancer.web
  ]
}

resource "local_file" "ansible_config" {
  filename = "${path.module}/../ansible/ansible.cfg"
  content  = <<-EOF
[defaults]
inventory = ./inventory.ini
host_key_checking = False
retry_files_enabled = False
gathering = smart
allow_broken_conditionals = True

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s
pipelining = True
EOF

  depends_on = [
    local_file.ansible_inventory_ini
  ]
}