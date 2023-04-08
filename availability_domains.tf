data "oci_identity_availability_domain" "item" {
  compartment_id = var.TENANCY_OCID
  ad_number      = var.AVAILABILITY_DOMAIN_NUMBER
}

data "oci_identity_availability_domains" "item" {
  compartment_id = var.TENANCY_OCID
}
