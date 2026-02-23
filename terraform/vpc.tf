# VPC Network
resource "yandex_vpc_network" "main" {
  name        = "${local.project_prefix}-vpc"
  description = "Main VPC for diplom project"
  labels      = local.common_tags
}

# Public Subnets
resource "yandex_vpc_subnet" "public" {
  for_each = toset(["ru-central1-a", "ru-central1-b"])
  
  name           = "${local.project_prefix}-public-subnet-${each.key}"
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [
    cidrsubnet(var.vpc_cidr, 8, 
      each.key == "ru-central1-a" ? 1 : 2
    )
  ]
  zone           = each.key
  
  labels = merge(local.common_tags, {
    subnettype = "public"
    zone       = each.key
  })
}

# Private App Subnets
resource "yandex_vpc_subnet" "private_app" {
  for_each = toset(["ru-central1-a", "ru-central1-b"])
  
  name           = "${local.project_prefix}-private-app-subnet-${each.key}"
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [
    cidrsubnet(var.vpc_cidr, 8, 
      each.key == "ru-central1-a" ? 11 : 12
    )
  ]
  zone           = each.key
  route_table_id = yandex_vpc_route_table.nat_route.id 
  
  labels = merge(local.common_tags, {
    subnettype = "private-app"
    zone       = each.key
  })
}

# Private Data Subnets
resource "yandex_vpc_subnet" "private_data" {
  for_each = toset(["ru-central1-a", "ru-central1-b"])
  
  name           = "${local.project_prefix}-private-data-subnet-${each.key}"
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [
    cidrsubnet(var.vpc_cidr, 8, 
      each.key == "ru-central1-a" ? 21 : 22
    )
  ]
  zone           = each.key
  route_table_id = yandex_vpc_route_table.nat_route.id
  
  labels = merge(local.common_tags, {
    subnettype = "private-data"
    zone       = each.key
  })
}

# NAT Gateway
resource "yandex_vpc_gateway" "nat_gateway" {
  name = "${local.project_prefix}-nat-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "nat_route" {
  name       = "${local.project_prefix}-nat-route"
  network_id = yandex_vpc_network.main.id
  
  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
  
  labels = local.common_tags
}