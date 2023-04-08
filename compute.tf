resource "oci_core_instance" "mastodon" {
  availability_domain = data.oci_identity_availability_domain.item.name
  compartment_id      = var.COMPARTMENT_OCID
  display_name        = "mastodon vm"
  shape               = var.instance_shape

  shape_config {
    ocpus         = var.instance_ocpus
    memory_in_gbs = var.instance_shape_config_memory_in_gbs
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.mastodon.id
    display_name     = "mastodon vnic"
    assign_public_ip = true
    hostname_label   = "mastodon"
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.item.images[0].id
  }

  metadata = {
    user_data = base64encode(data.template_file.cloud_init.rendered)
  }
}
