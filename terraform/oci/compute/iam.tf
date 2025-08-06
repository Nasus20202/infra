# General IAM policies for the compute resources
resource "oci_identity_policy" "objectstorage_kms_policy" {
  name        = "${local.prefix}-allow-objectstorage-to-use-kms"
  description = "Allows Object Storage to use KMS key from vault"

  statements = [
    "allow service objectstorage-${var.region} to use keys in compartment ${oci_identity_compartment.compartment.name} where target.key.id='${oci_kms_key.longhorn_backup_encryption_key.id}'"
  ]

  compartment_id = oci_identity_compartment.compartment.id
  freeform_tags  = local.tags
}



# Longhorn backup IAM resources
resource "oci_identity_user" "longhorn_backup_user" {
  name        = "${local.prefix}-longhorn-backup-user"
  description = "Longhorn backup access to bucket"
  email       = "${local.prefix}-longhorn-backup-user@${var.region}.oraclecloud.com"

  compartment_id = var.tenancy_ocid
  freeform_tags  = local.tags
}

resource "oci_identity_customer_secret_key" "longhorn_backup_user_access_key" {
  display_name = "${oci_identity_user.longhorn_backup_user.name}-access-key"
  user_id      = oci_identity_user.longhorn_backup_user.id
}

resource "oci_identity_group" "longhorn_backup_group" {
  name        = "${local.prefix}-longhorn-bucket-group"
  description = "Group for Longhorn bucket access"

  compartment_id = var.tenancy_ocid
  freeform_tags  = local.tags
}

resource "oci_identity_user_group_membership" "longhorn_backup_group_membership" {
  user_id  = oci_identity_user.longhorn_backup_user.id
  group_id = oci_identity_group.longhorn_backup_group.id

  compartment_id = var.tenancy_ocid
}

resource "oci_identity_policy" "longhorn_backup_policy" {
  name        = "${local.prefix}-longhorn-backup"
  description = "Allow access to only the Longhorn backup bucket"

  statements = [
    "Allow group ${oci_identity_group.longhorn_backup_group.name} to manage object-family in compartment ${oci_identity_compartment.compartment.name} where target.bucket.name='${oci_objectstorage_bucket.longhorn_backup.name}'",
  ]

  compartment_id = oci_identity_compartment.compartment.id
  freeform_tags  = local.tags
}



# Grafana metrics IAM resources
resource "tls_private_key" "grafana_metrics_user_private_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "oci_identity_user" "grafana_metrics_user" {
  name        = "${local.prefix}-grafana-metrics-user"
  description = "Grafana OCI metrics plugin access"
  email       = "${local.prefix}-grafana-metrics-user@${var.region}.oraclecloud.com"

  compartment_id = var.tenancy_ocid
  freeform_tags  = local.tags
}

resource "oci_identity_api_key" "grafana_api_key" {
  user_id   = oci_identity_user.grafana_metrics_user.id
  key_value = tls_private_key.grafana_metrics_user_private_key.public_key_pem
}

resource "oci_identity_group" "grafana_metrics_group" {
  name        = "${local.prefix}-grafana-metrics-group"
  description = "Group for Grafana metrics plugin access"

  compartment_id = var.tenancy_ocid
  freeform_tags  = local.tags
}

resource "oci_identity_user_group_membership" "grafana_metrics_group_membership" {
  user_id  = oci_identity_user.grafana_metrics_user.id
  group_id = oci_identity_group.grafana_metrics_group.id

  compartment_id = var.tenancy_ocid
}

resource "oci_identity_policy" "grafana_metrics_policy" {
  name        = "${local.prefix}-grafana-metrics"
  description = "Allow access to metrics in the compartment"

  statements = [
    "Allow group ${oci_identity_group.grafana_metrics_group.name} to read metrics in compartment ${oci_identity_compartment.compartment.name}",
  ]

  compartment_id = oci_identity_compartment.compartment.id
  freeform_tags  = local.tags
}
