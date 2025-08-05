resource "oci_network_load_balancer_network_load_balancer" "nlb" {
  subnet_id  = oci_core_subnet.public_subnet.id
  is_private = false

  compartment_id = oci_identity_compartment.compartment.id
  display_name   = "${local.prefix}-nlb"
  freeform_tags  = local.tags
}

resource "oci_network_load_balancer_backend_set" "nlb_backend_set" {
  for_each = toset(local.nlb_ports)

  name                     = "${oci_network_load_balancer_network_load_balancer.nlb.display_name}-backend-set-port-${each.key}"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.nlb.id
  policy                   = "FIVE_TUPLE"
  is_preserve_source       = false

  health_checker {
    protocol = "TCP"
    port     = each.key
  }
}

resource "oci_network_load_balancer_backend" "nlb_backend" {
  for_each = {
    for combo in flatten([
      for port in local.nlb_ports : [
        for instance in oci_core_instance.arm : {
          key  = "${port}-${instance.private_ip}"
          port = port
          ip   = instance.private_ip
        }
      ]
    ]) : combo.key => combo
  }

  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.nlb.id
  backend_set_name         = oci_network_load_balancer_backend_set.nlb_backend_set[each.value.port].name

  ip_address = each.value.ip
  port       = each.value.port
}

resource "oci_network_load_balancer_listener" "nlb_listener" {
  for_each                 = toset(local.nlb_ports)
  name                     = "${oci_network_load_balancer_network_load_balancer.nlb.display_name}-listener-${each.key}"
  default_backend_set_name = oci_network_load_balancer_backend_set.nlb_backend_set[each.key].name
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.nlb.id
  port                     = each.key
  protocol                 = "TCP"
}
