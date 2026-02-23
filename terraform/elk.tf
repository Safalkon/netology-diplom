# Elasticsearch Server
resource "yandex_compute_instance" "elasticsearch" {
  name        = "${local.project_prefix}-elasticsearch"
  hostname    = "elasticsearch"
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
      type     = "network-ssd"
    }
  }
  
  network_interface {
    subnet_id = yandex_vpc_subnet.private_data["ru-central1-a"].id
    security_group_ids = [yandex_vpc_security_group.elasticsearch.id]
    nat                = false  # No public IP
    ip_address = cidrhost(
      yandex_vpc_subnet.private_data["ru-central1-a"].v4_cidr_blocks[0], 
      10
    )
  }
  
  scheduling_policy {
    preemptible = var.vm_preemptible
  }
  
  metadata = {
    ssh-keys = "${var.vm_user}:${var.ssh_public_key}"
    user-data = local.common_user_data
  }
  
  labels = merge(local.common_tags, {
    role = "elasticsearch"
  })
  
  depends_on = [
    yandex_vpc_subnet.private_data,
    yandex_vpc_security_group.elasticsearch,
  ]
}

# Kibana Server
resource "yandex_compute_instance" "kibana" {
  name        = "${local.project_prefix}-kibana"
  hostname    = "kibana"
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
      type     = "network-ssd"
    }
  }
  
  network_interface {
    subnet_id = yandex_vpc_subnet.public["ru-central1-a"].id
    security_group_ids = [yandex_vpc_security_group.kibana.id]
    nat                = true  # Public IP for web access
  }
  
  scheduling_policy {
    preemptible = var.vm_preemptible
  }
  
  metadata = {
    ssh-keys = "${var.vm_user}:${var.ssh_public_key}"
  }
  
  labels = merge(local.common_tags, {
    role = "kibana"
  })
  
  depends_on = [
    yandex_vpc_subnet.public,
    yandex_vpc_security_group.kibana
  ]
}