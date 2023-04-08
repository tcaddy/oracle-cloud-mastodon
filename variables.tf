variable "TENANCY_OCID" {
  type        = string
  description = "Tenancy's OCID"
}

variable "USER_OCID" {
  type        = string
  description = "User's OCID"
}

variable "FINGERPRINT" {
  description = "Fingerprint of the API private key for oci provider"
  type        = string
}

variable "PRIVATE_KEY_B64" {
  type        = string
  description = "Base64 encoded API private key for oci provider"
  sensitive   = true
}

variable "REGION" {
  type        = string
  description = "OCI Cloud Region"
}

variable "COMPARTMENT_OCID" {
  type        = string
  description = <<EOT
  Go to https://cloud.oracle.com/identity/compartments and copy the OCID
  EOT
}

variable "SSH_PUBLIC_KEY_B64" {
  type        = string
  description = <<EOT
  Base64-encoded SSH public key. It should decode to a single line of text (no line breaks). This should be your SSH public key so you can SSH to the machine after it is created.
  EOT
}

variable "SSH_INGRESS_SOURCE" {
  type        = string
  description = "See https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_security_list#source"
  default     = "192.168.1.1/32"
}

variable "LOCAL_DOMAIN" {
  type        = string
  description = "Domain of your Mastodon instance"
  default     = "example.com"
}

variable "ADMIN_EMAIL_ADDRESS" {
  type        = string
  description = "Email address associated with admin Mastodon account"
  default     = "user@example.com"
}

variable "ADMIN_USERNAME" {
  type        = string
  description = "Username associated with the admin Mastodon account"
  default     = "admin"
}

variable "AVAILABILITY_DOMAIN_NUMBER" {
  default     = 1
  type        = number
  description = "See `ad_number` at https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/identity_availability_domain"

  validation {
    condition     = var.AVAILABILITY_DOMAIN_NUMBER >= 1
    error_message = "The AVAILABILITY_DOMAIN_NUMBER must be greater than or equal to 1."
  }
}

variable "instance_shape" {
  type        = string
  description = "See https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_instance#shape"
  default     = "VM.Standard.A1.Flex"
}

variable "instance_ocpus" {
  description = "The total number of OCPUs available to the instance. See https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_instance#shape_config"
  default     = 4
  type        = number

  validation {
    condition     = var.instance_ocpus >= 1
    error_message = "The instance_ocpus must be greater than or equal to 1."
  }
}

variable "instance_shape_config_memory_in_gbs" {
  description = "The total amount of memory available to the instance, in gigabytes. See https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_instance#shape_config"
  default     = 24
  type        = number

  validation {
    condition     = var.instance_shape_config_memory_in_gbs >= 1
    error_message = "The instance_shape_config_memory_in_gbs must be greater than or equal to 1."
  }
}

variable "mastodon_block_device" {
  type        = string
  description = "Need to use a consistent volume name.  See https://docs.oracle.com/en-us/iaas/Content/Block/References/consistentdevicepaths.htm"
  default     = "/dev/oracleoci/oraclevdb"
}

variable "mastodon_version" {
  type        = string
  description = "Mastodon version"
  default     = "v4.1.2"
}

variable "mastodon_subnet_cidr_block" {
  type        = string
  description = "See https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_subnet#cidr_block"
  default     = "10.1.20.0/24"
}
