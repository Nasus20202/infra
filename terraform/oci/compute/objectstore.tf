resource "oci_objectstorage_bucket" "longhorn_backup" {
  name         = "${local.prefix}-longhorn-backup"
  namespace    = data.oci_objectstorage_namespace.ns.namespace
  storage_tier = "Standard"
  access_type  = "NoPublicAccess"
  kms_key_id   = oci_kms_key.longhorn_backup_encryption_key.id

  compartment_id = oci_identity_compartment.compartment.id
  freeform_tags  = local.tags
}
