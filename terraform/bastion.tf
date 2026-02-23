# Bastion Host
resource "yandex_compute_instance" "bastion" {
  name        = "${local.project_prefix}-bastion"
  hostname    = "${local.project_prefix}-bastion.ru-central1.internal"
  platform_id = "standard-v3"
  zone        = var.yc_zone
  
  resources {
    cores         = local.vm_specs.bastion.cores
    memory        = local.vm_specs.bastion.memory
    core_fraction = local.vm_specs.bastion.core_fraction
  }
  
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = local.vm_specs.bastion.disk_size
      type     = "network-ssd"
    }
  }
  
  network_interface {
    subnet_id = yandex_vpc_subnet.public["ru-central1-a"].id
    security_group_ids = [yandex_vpc_security_group.bastion.id]
    nat                = true
  }

  scheduling_policy {
    preemptible = var.vm_preemptible
  }
  
  metadata = {
    ssh-keys = "${var.vm_user}:${var.ssh_public_key}"
    user-data = <<-EOF
      #cloud-config
      package_update: true
      package_upgrade: true
      users:
      - name: ${var.vm_user}
        sudo: ALL=(ALL) NOPASSWD:ALL
        shell: /bin/bash
        ssh-authorized-keys:
          - ${var.ssh_public_key}
      packages:
        - fail2ban
        - python3
        - python3-pip
        - ansible
      runcmd:
        - systemctl enable fail2ban
        - systemctl start fail2ban
        - systemctl restart sshd
      EOF
  }
  
  labels = merge(local.common_tags, {
    role = "bastion"
  })
}