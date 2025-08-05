output "ssh_private_key" {
  description = "The private key to use to connect to the instances"
  value       = tls_private_key.ssh_key.private_key_pem
  sensitive   = true
}

output "arm_ips" {
  description = "ARM machines IPs"
  value = {
    for instance in oci_core_instance.arm
    : instance.display_name => instance.public_ip
  }
}

output "longhorn_backup_target" {
  description = "The S3 target for Longhorn backups"
  value       = "s3://${oci_objectstorage_bucket.longhorn_backup.name}@${var.region}/"
}

output "longhorn_backup_s3_endpoint" {
  description = "The S3 endpoint for Longhorn backups"
  value       = "https://${oci_objectstorage_bucket.longhorn_backup.namespace}.compat.objectstorage.${var.region}.oraclecloud.com"
}

output "longhorn_backup_access_key_id" {
  description = "The Longhorn backup user access key ID"
  value       = oci_identity_customer_secret_key.longhorn_backup_user_access_key.id
}

output "longhorn_backup_secret_access_key" {
  description = "The Longhorn backup user secret access key"
  value       = oci_identity_customer_secret_key.longhorn_backup_user_access_key.key
  sensitive   = true
}
