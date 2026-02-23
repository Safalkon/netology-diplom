# Network Outputs
output "bastion_public_ip" {
  description = "Public IP address of bastion host"
  value       = try(yandex_compute_instance.bastion.network_interface[0].nat_ip_address, null)
}

output "alb_public_ip" {
  description = "Public IP address of Application Load Balancer"
  value       = try(yandex_alb_load_balancer.web.listener[0].endpoint[0].address[0].external_ipv4_address[0].address, null)
}

output "zabbix_public_ip" {
  description = "Public IP address of Zabbix server"
  value       = try(yandex_compute_instance.zabbix.network_interface[0].nat_ip_address, null)
}

output "kibana_public_ip" {
  description = "Public IP address of Kibana"
  value       = try(yandex_compute_instance.kibana.network_interface[0].nat_ip_address, null)
}

output "instance_group_instances" {
  description = "Instances in the instance group"
  value = try([
    for instance in yandex_compute_instance_group.web_ig.instances : {
      name         = instance.name
      status       = instance.status
      zone_id      = instance.zone_id
      fqdn         = instance.fqdn
      network_interface = instance.network_interface
    }
  ], [])
}

output "web_server_distribution" {
  description = "Web server distribution across zones"
  value = {
    for zone in ["ru-central1-a", "ru-central1-b"] :
    zone => try([
      for instance in yandex_compute_instance_group.web_ig.instances :
      instance.name if instance.zone_id == zone
    ], [])
  }
}

output "elasticsearch_internal_ip" {
  description = "Internal IP address of Elasticsearch"
  value       = try(yandex_compute_instance.elasticsearch.network_interface[0].ip_address, null)
}

output "fqdn_list" {
  description = "All FQDN names for Ansible inventory"
  value = {
    bastion       = try(yandex_compute_instance.bastion.hostname, null)
    zabbix        = try(yandex_compute_instance.zabbix.hostname, null)
    elasticsearch = try(yandex_compute_instance.elasticsearch.hostname, null)
    kibana        = try(yandex_compute_instance.kibana.hostname, null)
    instance_group_instances = try([
      for instance in yandex_compute_instance_group.web_ig.instances : 
      instance.fqdn
    ], [])
  }
}

output "ssh_via_bastion" {
  description = "SSH command template to connect via bastion"
  value       = "ssh -J ${var.vm_user}@${try(yandex_compute_instance.bastion.network_interface[0].nat_ip_address, "BASTION_IP")} ${var.vm_user}@<internal_ip>"
}

output "vpc_info" {
  description = "VPC and subnet information"
  value = {
    vpc_id = try(yandex_vpc_network.main.id, null)
    subnets = {
      public = try(
        { for k, v in yandex_vpc_subnet.public : k => {
          id          = v.id
          cidr_blocks = v.v4_cidr_blocks
          zone        = v.zone
        }},
        null
      )
      
      private_app = try(
        { for k, v in yandex_vpc_subnet.private_app : k => {
          id          = v.id
          cidr_blocks = v.v4_cidr_blocks
          zone        = v.zone
        }},
        null
      )
      
      private_data = try(
        { for k, v in yandex_vpc_subnet.private_data : k => {
          id          = v.id
          cidr_blocks = v.v4_cidr_blocks
          zone        = v.zone
        }},
        null
      )
    }
  }
}

# Output для получения внутренних IP всех инстансов для Ansible
output "internal_ips_for_ansible" {
  description = "Internal IP addresses for Ansible inventory"
  value = {
    bastion_internal = try(yandex_compute_instance.bastion.network_interface[0].ip_address, null)
    zabbix_internal = try(yandex_compute_instance.zabbix.network_interface[0].ip_address, null)
    elasticsearch_internal = try(yandex_compute_instance.elasticsearch.network_interface[0].ip_address, null)
    kibana_internal = try(yandex_compute_instance.kibana.network_interface[0].ip_address, null)
    web_servers_internal = try([
      for instance in yandex_compute_instance_group.web_ig.instances :
      instance.network_interface[0].ip_address
    ], [])
  }
  sensitive = false
}
output "instance_group_info" {
  description = "Information about instance group"
  value = {
    id              = try(yandex_compute_instance_group.web_ig.id, null)
    name            = try(yandex_compute_instance_group.web_ig.name, null)
    status          = try(yandex_compute_instance_group.web_ig.status, null)
    target_group_id = try(yandex_compute_instance_group.web_ig.application_load_balancer[0].target_group_id, null)
  }
}