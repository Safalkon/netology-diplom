# Сервисный аккаунт для Instance Group
resource "yandex_iam_service_account" "ig_sa" {
  name        = "${local.project_prefix}-ig-sa"
  description = "Service account for Instance Group"
  folder_id   = var.yc_folder_id
}

# Права для управления ВМ
resource "yandex_resourcemanager_folder_iam_member" "compute_editor" {
  folder_id = var.yc_folder_id
  role      = "compute.editor"
  member    = "serviceAccount:${yandex_iam_service_account.ig_sa.id}"
}

# Права для управления VPC
resource "yandex_resourcemanager_folder_iam_member" "vpc_user" {
  folder_id = var.yc_folder_id
  role      = "vpc.user"
  member    = "serviceAccount:${yandex_iam_service_account.ig_sa.id}"
}

# Права для управления Load Balancer
resource "yandex_resourcemanager_folder_iam_member" "load_balancer_editor" {
  folder_id = var.yc_folder_id
  role      = "alb.editor"
  member    = "serviceAccount:${yandex_iam_service_account.ig_sa.id}"
}

resource "yandex_compute_instance_group" "web_ig" {
  name               = "${local.project_prefix}-web-ig"
  service_account_id = yandex_iam_service_account.ig_sa.id
  deletion_protection = false

  instance_template {
    name= "${local.project_prefix}-web-{instance.index}"
    platform_id = "standard-v3"

    resources {
      cores         = local.vm_specs.web.cores
      memory        = local.vm_specs.web.memory
      core_fraction = local.vm_specs.web.core_fraction
    }

    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = data.yandex_compute_image.ubuntu.id
        size     = local.vm_specs.web.disk_size
        type     = "network-hdd"
      }
    }

    network_interface {
      network_id = yandex_vpc_network.main.id
      subnet_ids = [for zone in ["ru-central1-a", "ru-central1-b"] : 
                   yandex_vpc_subnet.private_app[zone].id]
      security_group_ids = [yandex_vpc_security_group.web.id]
      nat                = false
    }

    metadata = {
      ssh-keys = "${var.vm_user}:${var.ssh_public_key}"
      user-data = <<-EOF
        #cloud-config
        package_update: true
        users:
          - name: ${var.vm_user}
            sudo: ALL=(ALL) NOPASSWD:ALL
            shell: /bin/bash
            ssh-authorized-keys:
              - ${var.ssh_public_key}
        
        packages:
          - nginx
          - git       
        write_files:
          - path: /var/www/html/index.html
            content: |
              <!DOCTYPE html>
              <html>
              <head>
                  <title>Netology Diplom Project</title>
                  <style>
                      body { font-family: Arial; text-align: center; padding: 50px; }
                      h1 { color: #0066cc; }
                  </style>
              </head>
              <body>
                  <h1>Netology Diplom - High Availability Website</h1>
                  <p>Server: $(hostname)</p>
                  <p>Zone: $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)</p>
              </body>
              </html>
        runcmd:
          - systemctl start nginx
          - systemctl enable nginx
          - sed -i "s/\$(hostname)/$(hostname)/g" /var/www/html/index.html
          - sed -i "s/\$(curl -s http:\/\/169.254.169.254\/latest\/meta-data\/placement\/availability-zone)/$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)/g" /var/www/html/index.html
      EOF
    }

    labels = merge(local.common_tags, {
      role = "web-server"
    })
  }

  scale_policy {
    fixed_scale {
      size = var.web_server_count
    }
  }

  allocation_policy {
    zones = ["ru-central1-a", "ru-central1-b"]
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion   = 0
    startup_duration = 60
  }
  
  application_load_balancer {
    target_group_name        = "${local.project_prefix}-alb-target-group"
    target_group_description = "ALB target group for web servers"
  }

  depends_on = [
    yandex_vpc_subnet.private_app,
    yandex_vpc_security_group.web,
    yandex_iam_service_account.ig_sa,
    yandex_resourcemanager_folder_iam_member.compute_editor,
    yandex_resourcemanager_folder_iam_member.vpc_user,
    yandex_resourcemanager_folder_iam_member.load_balancer_editor
  ]

  labels = local.common_tags
}