resource "yandex_compute_snapshot_schedule" "daily" {
  name        = "${local.project_prefix}-daily-snapshots"
  description = "Daily snapshots with 7-day retention"
  
  schedule_policy {
    expression = "0 1 * * *"  # Ежедневно в 1:00
  }
  
  snapshot_count   = 7
  retention_period = "168h"  # 7 дней
  
  # Диски ВМ, кроме веб-серверов (они теперь в Instance Group)
  disk_ids = [
    yandex_compute_instance.bastion.boot_disk[0].disk_id,
    yandex_compute_instance.zabbix.boot_disk[0].disk_id,
    yandex_compute_instance.elasticsearch.boot_disk[0].disk_id,
    yandex_compute_instance.kibana.boot_disk[0].disk_id
  ]
  
  labels = local.common_tags
}

# Отдельный снапшот-шедулер для Instance Group (опционально)
resource "yandex_compute_snapshot_schedule" "instance_group_disks" {
  name        = "${local.project_prefix}-ig-disks-snapshots"
  description = "Snapshots for instance group disks"
  
  schedule_policy {
    expression = "0 2 * * *"  # Ежедневно в 2:00
  }
  
  snapshot_count   = 7
  retention_period = "168h"
  
  labels = local.common_tags
}