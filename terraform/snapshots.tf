data "yandex_compute_instance_group" "web_ig" {
  instance_group_id = yandex_compute_instance_group.web_ig.id
  depends_on        = [yandex_compute_instance_group.web_ig]
}

data "yandex_compute_instance" "web_instances" {
  for_each    = {
    for idx in range(var.web_server_count) :
    tostring(idx) => idx
  }
  instance_id = data.yandex_compute_instance_group.web_ig.instances[each.value].instance_id

  depends_on = [yandex_compute_instance_group.web_ig]
}

resource "yandex_compute_snapshot_schedule" "daily" {
  name        = "${local.project_prefix}-daily-snapshots"
  description = "Daily snapshots with 7-day retention"

  schedule_policy {
    expression = "0 1 * * *"
  }

  snapshot_count = 7

  disk_ids = concat(
    [
      yandex_compute_instance.bastion.boot_disk[0].disk_id,
      yandex_compute_instance.zabbix.boot_disk[0].disk_id,
      yandex_compute_instance.elasticsearch.boot_disk[0].disk_id,
      yandex_compute_instance.kibana.boot_disk[0].disk_id,
    ],
    [
      for inst in data.yandex_compute_instance.web_instances :
      inst.boot_disk[0].disk_id
    ]
  )

  labels     = local.common_tags
  depends_on = [yandex_compute_instance_group.web_ig]
}