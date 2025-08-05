resource "oci_kms_vault" "vault" {
  vault_type = "DEFAULT"

  compartment_id = oci_identity_compartment.compartment.id
  display_name   = "${local.prefix}-vault"
  freeform_tags  = local.tags
}

resource "oci_kms_key" "secret_encryption_key" {
  key_shape {
    algorithm = "AES"
    length    = 32
  }
  management_endpoint = oci_kms_vault.vault.management_endpoint

  compartment_id = oci_identity_compartment.compartment.id
  display_name   = "${local.prefix}-vault-encryption-key"
  freeform_tags  = local.tags
}

resource "oci_vault_secret" "ssh_private_key_secret" {
  vault_id = oci_kms_vault.vault.id
  key_id   = oci_kms_key.secret_encryption_key.id

  secret_content {
    content_type = "BASE64"
    content      = base64encode(tls_private_key.ssh_key.private_key_pem)
    name         = "${local.prefix}-ssh-private-key"
  }

  compartment_id = oci_identity_compartment.compartment.id
  secret_name    = "${local.prefix}-ssh-private-key"
}

resource "oci_kms_key" "longhorn_backup_encryption_key" {
  key_shape {
    algorithm = "AES"
    length    = 32
  }
  management_endpoint = oci_kms_vault.vault.management_endpoint

  compartment_id = oci_identity_compartment.compartment.id
  display_name   = "${local.prefix}-longhorn-backup-encryption-key"
  freeform_tags  = local.tags
}

resource "oci_vault_secret" "longhorn_backup_user_access_key_secret" {
  vault_id = oci_kms_vault.vault.id
  key_id   = oci_kms_key.secret_encryption_key.id

  secret_content {
    content_type = "BASE64"
    content      = base64encode(oci_identity_customer_secret_key.longhorn_backup_user_access_key.key)
    name         = "${local.prefix}-longhorn-backup-user-access-key"
  }

  compartment_id = oci_identity_compartment.compartment.id
  secret_name    = "${local.prefix}-longhorn-backup-user-access-key"
}
