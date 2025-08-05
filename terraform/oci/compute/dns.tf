locals {
  zones   = { for zone in data.cloudflare_zones.cf_zones.result : zone.name => zone if contains(var.domains, zone.name) }
  nlb_ip  = [for ip in oci_network_load_balancer_network_load_balancer.nlb.ip_addresses : ip.ip_address if ip.is_public][0]
  dns_ttl = 300
  proxied = false
}

resource "cloudflare_dns_record" "nlb_root_record" {
  for_each = local.zones

  zone_id = each.value.id
  name    = each.value.name
  content = local.nlb_ip
  type    = "A"
  ttl     = local.dns_ttl
  proxied = local.proxied

  comment = "OCI network load balancer '${oci_network_load_balancer_network_load_balancer.nlb.display_name}' root record"
}

resource "cloudflare_dns_record" "nlb_wildcard_record" {
  for_each = local.zones

  zone_id = each.value.id
  name    = "*.${each.value.name}"
  content = each.value.name
  type    = "CNAME"
  ttl     = local.dns_ttl
  proxied = local.proxied

  comment = "Subdomain wildcard record for OCI network load balancer '${oci_network_load_balancer_network_load_balancer.nlb.display_name}'"
}

resource "cloudflare_dns_record" "host_records" {
  for_each = {
    for combo in flatten([
      for zone in local.zones : [
        for instance in oci_core_instance.arm : {
          key      = "${instance.display_name}.k8s.${zone.name}"
          zone     = zone
          instance = instance
        }
      ]
    ]) : combo.key => combo
  }

  zone_id = each.value.zone.id
  name    = each.value.key
  content = each.value.instance.public_ip
  type    = "A"
  ttl     = local.dns_ttl
  proxied = local.proxied

  comment = "Host record for instance '${each.value.instance.display_name}' in zone '${each.value.zone.name}'"
}

resource "cloudflare_dns_record" "k8s_record" {
  for_each = local.zones

  zone_id = each.value.id
  name    = "k8s.${each.value.name}"
  content = "${oci_core_instance.arm[0].display_name}.k8s.${each.value.name}"
  type    = "CNAME"
  ttl     = local.dns_ttl
  proxied = local.proxied

  comment = "K8s record for instance '${oci_core_instance.arm[0].display_name}' in zone '${each.value.name}'"
}
