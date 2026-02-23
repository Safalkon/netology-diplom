# Backend Group для ALB
resource "yandex_alb_backend_group" "web" {
  name = "${local.project_prefix}-backend-group"

  http_backend {
    name             = "http-backend"
    port             = 80
    target_group_ids = [yandex_compute_instance_group.web_ig.application_load_balancer[0].target_group_id]
    
    healthcheck {
      timeout             = "3s"
      interval            = "5s"
      healthy_threshold   = 2
      unhealthy_threshold = 3
      http_healthcheck {
        path = "/"
      }
    }
    load_balancing_config {
      panic_threshold                = 50
      locality_aware_routing_percent = 50
    }
  }
  depends_on = [yandex_compute_instance_group.web_ig]
  
  labels = local.common_tags
}

# HTTP Router
resource "yandex_alb_http_router" "web" {
  name   = "${local.project_prefix}-http-router"
  labels = local.common_tags
}

# Virtual Host
resource "yandex_alb_virtual_host" "web" {
  name           = "default-host"
  http_router_id = yandex_alb_http_router.web.id

  route {
    name = "default-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.web.id
        timeout          = "60s"
      }
    }
  }
  
  depends_on = [yandex_alb_backend_group.web]
}

# Application Load Balancer
resource "yandex_alb_load_balancer" "web" {
  name       = "${local.project_prefix}-alb"
  network_id = yandex_vpc_network.main.id
  
  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.public["ru-central1-a"].id
    }
    location {
      zone_id   = "ru-central1-b"
      subnet_id = yandex_vpc_subnet.public["ru-central1-b"].id
    }
  }
  
  listener {
    name = "http-listener"
    
    endpoint {
      address {
        external_ipv4_address {}
      }
      ports = [80]
    }
    
    http {
      handler {
        http_router_id = yandex_alb_http_router.web.id
      }
    }
  }
  
  security_group_ids = [yandex_vpc_security_group.alb.id]
  labels = local.common_tags
  
  depends_on = [
    yandex_alb_virtual_host.web
  ]
}