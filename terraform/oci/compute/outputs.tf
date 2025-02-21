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
