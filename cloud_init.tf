data "template_file" "cloud_init" {
  template = file("./files/cloud_init.yaml.tpl")
  vars = {
    block_device                   = var.mastodon_block_device
    ssh_pubkey                     = base64decode(var.SSH_PUBLIC_KEY_B64)
    dot_file_contents_gz_b64       = base64gzip(data.template_file.dot_file.rendered)
    systemd_unit_contents_gz_b64   = base64gzip(data.template_file.systemd_unit.rendered)
    nginx_conf_contents_gz_b64     = base64gzip(data.template_file.nginx_conf.rendered)
    setup_contents_gz_b64          = base64gzip(data.template_file.setup.rendered)
    certbot_setup_contents_gz_b64  = base64gzip(data.template_file.certbot_setup.rendered)
    admin_runner_contents_gz_b64   = base64gzip(file("./files/admin_runner.rb"))
    docker_compose_contents_gz_b64 = base64gzip(data.template_file.docker_compose.rendered)
    ssl_private_contents_gz_b64    = base64gzip(tls_private_key.item.private_key_pem)
    ssl_cert_contents_gz_b64       = base64gzip(tls_self_signed_cert.item.cert_pem)
  }
}

data "template_file" "dot_file" {
  template = file("./files/dot_file.tpl")
  vars = {
    local_domain    = var.LOCAL_DOMAIN
    secret_key_base = random_password.secret_key_base.result
    otp_secret      = random_password.otp_secret.result
  }
}

data "template_file" "systemd_unit" {
  template = file("./files/mastodon.service.tpl")
}

data "template_file" "nginx_conf" {
  template = file("./files/nginx.conf.tpl")
  vars = {
    local_domain = var.LOCAL_DOMAIN
  }
}

data "template_file" "setup" {
  template = file("./files/setup.sh.tpl")
  vars = {
    admin_password   = random_string.admin_password.result
    admin_username   = var.ADMIN_USERNAME
    admin_email      = var.ADMIN_EMAIL_ADDRESS
    mastodon_version = var.mastodon_version
    local_domain     = var.LOCAL_DOMAIN
  }
}

data "template_file" "certbot_setup" {
  template = file("./files/certbot_setup.sh.tpl")
  vars = {
    admin_email  = var.ADMIN_EMAIL_ADDRESS
    local_domain = var.LOCAL_DOMAIN
  }
}

data "template_file" "docker_compose" {
  template = file("./files/docker-compose.yml.tpl")
  vars = {
    mastodon_image_tag = local.mastodon_image_tag
  }
}

resource "random_password" "secret_key_base" {
  length           = 128
  lower            = false
  numeric          = true
  override_special = "abcdef"
  special          = true
  upper            = false
}

resource "random_password" "otp_secret" {
  length           = 128
  lower            = false
  numeric          = true
  override_special = "abcdef"
  special          = true
  upper            = false
}

resource "random_string" "admin_password" {
  length           = 32
  lower            = false
  numeric          = true
  override_special = "abcdef"
  special          = true
  upper            = false
}
