output "ssh_private_key" {
  description = "The private key to use to connect to the instances"
  value       = tls_private_key.ssh_key.private_key_pem
  sensitive   = true
}
