resource "oci_core_volume_backup_policy" "arm_backup_policy" {
  # Weekly backup with 2 weeks retention
  schedules {
    backup_type = "INCREMENTAL"
    period = "ONE_WEEK"
    retention_seconds = 13.5 * 24 * 60 * 60 # Delete the backup before creating a new one to avoid billing issues
    hour_of_day = 0
    day_of_week = "SUNDAY"
  }

  compartment_id = oci_identity_compartment.compartment.id
  display_name   = "${local.prefix}-arm-backup-policy"
  freeform_tags = local.tags
}

resource "oci_core_volume_backup_policy_assignment" "arm_backup_policy_assignment" {
  count = length(oci_core_instance.arm)
  
  asset_id = oci_core_instance.arm[count.index].boot_volume_id
  policy_id = oci_core_volume_backup_policy.arm_backup_policy.id
}
