resource "oci_core_virtual_network" "mastodon" {
  cidr_block     = "10.1.0.0/16"
  compartment_id = var.COMPARTMENT_OCID
  display_name   = "mastodon vcn"
  dns_label      = "mastodon"
}

resource "oci_core_security_list" "mastodon" {
  compartment_id = var.COMPARTMENT_OCID
  vcn_id         = oci_core_virtual_network.mastodon.id
  display_name   = "mastodon security list"

  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.SSH_INGRESS_SOURCE

    tcp_options {
      max = "22"
      min = "22"
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      max = "80"
      min = "80"
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      max = "443"
      min = "443"
    }
  }
}

resource "oci_core_internet_gateway" "mastodon" {
  compartment_id = var.COMPARTMENT_OCID
  display_name   = "mastodon gateway"
  vcn_id         = oci_core_virtual_network.mastodon.id
}

resource "oci_core_route_table" "mastodon" {
  compartment_id = var.COMPARTMENT_OCID
  vcn_id         = oci_core_virtual_network.mastodon.id
  display_name   = "mastodon route table"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.mastodon.id
  }
}

resource "oci_core_subnet" "mastodon" {
  cidr_block        = var.mastodon_subnet_cidr_block
  display_name      = "mastodon subnet"
  dns_label         = "mastodon"
  security_list_ids = [oci_core_security_list.mastodon.id]
  compartment_id    = var.COMPARTMENT_OCID
  vcn_id            = oci_core_virtual_network.mastodon.id
  route_table_id    = oci_core_route_table.mastodon.id
  dhcp_options_id   = oci_core_virtual_network.mastodon.default_dhcp_options_id
}

data "oci_core_vnic_attachments" "app_vnics" {
  compartment_id      = var.COMPARTMENT_OCID
  availability_domain = data.oci_identity_availability_domain.item.name
  instance_id         = oci_core_instance.mastodon.id
}

data "oci_core_vnic" "app_vnic" {
  vnic_id = data.oci_core_vnic_attachments.app_vnics.vnic_attachments[0]["vnic_id"]
}
