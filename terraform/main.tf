# main.tf - корневой файл, включающий все ресурсы

# Провайдер (если его нет в providers.tf)

terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}


provider "yandex" {
  # Вариант 1: Аутентификация через файл ключа сервисного аккаунта (рекомендуется)
  service_account_key_file = var.service_account_key_file
  
  # Вариант 2: Аутентификация через токен (альтернатива)
  # token = var.yc_token
  
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.yc_zone
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts-oslogin"
}
