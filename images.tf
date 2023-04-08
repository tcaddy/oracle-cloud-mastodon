data "oci_core_images" "item" {
  compartment_id           = var.COMPARTMENT_OCID
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "22.04 Minimal aarch64"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}
