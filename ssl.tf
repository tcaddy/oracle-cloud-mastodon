resource "tls_private_key" "item" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "item" {
  private_key_pem = tls_private_key.item.private_key_pem

  subject {
    common_name  = var.LOCAL_DOMAIN
    organization = var.LOCAL_DOMAIN
  }

  validity_period_hours = 12

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth"
  ]
}
