output "public_ip" {
  value       = data.oci_core_vnic.app_vnic.public_ip_address
  description = "Public IP address of `oci_core_instance.mastodon` virtual machine"
}

output "README" {
  value = <<EOT
  Update the DNS settings for LOCAL_DOMAIN to point to public_ip.  If you do not
  do this immediately, the `certbot` command will fail to setup the SSL
  certificate.  If SSL setup fails initially, you can run
  `/root/bin/certbot_setup` later complete the setup once the DNS settings are
  in place.
  EOT
}

output "admin_password" {
  value = random_string.admin_password.result
}

output "oci_identity_availability_domains" {
  value = data.oci_identity_availability_domains.item
}
