resource "oci_core_volume" "mastodon" {
  availability_domain = data.oci_identity_availability_domain.item.name
  compartment_id      = var.COMPARTMENT_OCID
  display_name        = "mastodon volume"
  size_in_gbs         = 150 # 200 total; auto 50gb for boot volume.
}

resource "oci_core_volume_attachment" "mastodon" {
  attachment_type = "paravirtualized"
  instance_id     = oci_core_instance.mastodon.id
  volume_id       = oci_core_volume.mastodon.id
  device          = var.mastodon_block_device
  display_name    = "mastodon attachment"
}
