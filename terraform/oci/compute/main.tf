resource "tls_private_key" "ssh_key" {
  algorithm = "ED25519"
}

resource "oci_identity_compartment" "compartment" {
  name        = "${local.prefix}-compartment"
  description = "All general-purpose compute instances"
}

data "oci_identity_availability_domain" "ad" {
  compartment_id = oci_identity_compartment.compartment.id
  ad_number      = var.availability_domain
}

data "oci_core_images" "oracle_linux" {
  compartment_id   = data.oci_identity_availability_domain.ad.compartment_id
  operating_system = "Oracle Linux"
  sort_by          = "TIMECREATED"
  sort_order       = "DESC"
}

resource "oci_core_instance" "arm" {
  count               = 2
  availability_domain = data.oci_identity_availability_domain.ad.name

  shape = "VM.Standard.A1.Flex"
  shape_config {
    memory_in_gbs = 12
    ocpus         = 2
  }

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_images.oracle_linux.images[0].id
    boot_volume_size_in_gbs = 100
    boot_volume_vpus_per_gb = 10
  }

  create_vnic_details {
    subnet_id                 = oci_core_subnet.public_subnet.id
    assign_public_ip          = true
    assign_private_dns_record = true
    display_name              = "${local.prefix}-arm-${count.index}-vnic"
    hostname_label            = "${local.prefix}-arm-${count.index}"
  }

  metadata = {
    ssh_authorized_keys = tls_private_key.ssh_key.public_key_openssh
  }

  compartment_id = oci_identity_compartment.compartment.id
  display_name   = "${local.prefix}-arm-${count.index}"
  freeform_tags  = local.tags
}
