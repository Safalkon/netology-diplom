#Zabbix Server
resource "yandex_compute_instance" "zabbix" {
  name        = "${local.project_prefix}-zabbix"
  hostname    = "zabbix"
  platform_id = "standard-v3"
  zone        = var.yc_zone
  
  resources {
    cores         = local.vm_specs.monitoring.cores
    memory        = local.vm_specs.monitoring.memory
    core_fraction = local.vm_specs.monitoring.core_fraction
  }
  
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = local.vm_specs.monitoring.disk_size
      type     = "network-hdd"
    }
  }
  
  network_interface {
    subnet_id = yandex_vpc_subnet.public["ru-central1-a"].id
    security_group_ids = [yandex_vpc_security_group.zabbix.id]
    nat                = true 
  }
  
  scheduling_policy {
    preemptible = var.vm_preemptible
  }
  
  metadata = {
    ssh-keys = "${var.vm_user}:${var.ssh_public_key}"
    user-data = local.common_user_data
  }
  
  labels = merge(local.common_tags, {
    role = "zabbix-server"
  })
  
  depends_on = [
    yandex_vpc_subnet.public,
    yandex_vpc_security_group.zabbix
  ]
}