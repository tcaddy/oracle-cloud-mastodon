# oracle-cloud-mastodon
Terraform managed infrastructure for Oracle Cloud Always Free tier for
self hosting Mastodon.  Runs Mastodon services in containers, using an Ubuntu
host to run Docker.

Inspired by:
  * https://github.com/Fitzsimmons/oracle-always-free-vps
  * https://github.com/l3ib/mastodon-ansible
  * https://github.com/faevourite/mastodon-oracle-cloud-free-tier

# Setup
  * Create an account with Oracle Cloud to get access to the Always Free tier
  * Have a domain name (or subdomain) for which you can update/create an `A`
    record
    * Be ready to enter the DNS entry immediately after running
      `terraform apply`
  * Fill out [environment variables](#environment-variables)
  * Run `terraform plan` and `terraform apply`
  * The output of `terraform apply` will include:
    * Public IP address
      * Update the `A` record DNS entry ASAP with this IP address
      * If this step is not done in time, certbot will fail to setup a SSL
        certificate out-of-the-box
      * If you end up getting the DNS entry done late, you can manually re-run
        the part of the setup that does the certbot SSL setup by running:
        ```bash
        sudo /root/bin/certbot_setup
        ```
    * Admin password
      * Use this for the initial login and reset the password after first login

# About
For reasons, I decided to not use Ansible to stand up the host.
  * I've already used Ansible to stand up Ruby on Rails servers in my day job
  * I don't want to more of this in my free time

As a bit of a challenge, I wanted to see if I could limit myself to using
cloud-init.  That was a painful experience.  I've mostly relagated cloud-init
to writing files and shell scripts to be executed later.

I wanted to use the "off-the-shelf" `docker-compose.yml` file from the Mastodon
repo, but that actually didn't work, so I have to use a
[slightly modified file](#docker-composeyml-changes).

# Details
The system will reboot twice as part of setup.  If you try to login during this
time, you may get a timeout or an SSH pubkey denied auth error.  Wait about 5
minutes after server creation before losing hope.

## `docker-compose.yml` changes
Cloud-init will create a `docker-compose-alt.yml` file that is used instead of
the "off-the-shelf" `docker-compose.yml` file.  The differences are:
  * Download image, tagged with `var.mastodon_version`, instead of building
    container images from scratch
  * Pass in some environment variables needed for creating the admin account

## Special note about first boot
The creation of the cloud block storage volume attachment takes place
asynchronously after the creation of the virtual machine.  That means that when
cloud-init runs on first boot, the block storage volume isn't present to be
formatted and mounted.  To work around this, cloud-init will reboot after a 60
second timeout.  On the second boot, the cloud block storage volume is available
to be formatted and mounted.

Things that cloud init does during first boot:
  * Update/install packages
  * Setup SSH pubkey login for `ubuntu` user
  * Setup the mount for the volume attachment, create filesystem, `/etc/fstab`
    entry
  * Copy various files:
    * Setup `/etc/rc.local` to continue setup on the second boot
    * `/root/bin/setup` - the setup script run on the second boot
    * Other various files

You can see the logs with:
```bash
cat /var/log/cloud-init-output.log
```

## Special note about second boot
`/etc/rc.local` is used to call `/root/bin/setup`.  You can see the logs with:
```bash
sudo journalctl -f -u rc-local.service
```

The `/root/bin/setup` script does the following:
  * add `ubuntu` user to the `docker` group
  * delete any files that may exist on the cloud block storage volume
    * (mounted at `/mnt/mastodon`)
  * clone the mastodon repo to `/mnt/mastodon/mastodon`
  * move files to proper places:
    * `.env.production`
    * `docker-compose-alt.yml`
    * SSL cert files
    * other various files
  * run `rake db:setup` and `rails assets:precompile`
  * generate vapid key environment variables for `.env.production`
  * make a backup copy of `.env.production` at `/root/env.production`
  * fix ownership issue for with `public/system` folder of Rails app
  * execute a Rails runner to create an admin account
  * enable `mastodon.service` and `nginx.service` via systemd
  * setup iptables
  * setup certbot (`/root/bin/certbot_setup`)
    * if this fails it'll try again at next boot
    * remove `/etc/rc.local` if this succeeds
  * reboot

# Environment Variables
## Terraform run from CLI
### Create a `.tfvars` file with values for:
  * `ADMIN_EMAIL_ADDRESS`
  * `ADMIN_USERNAME`
  * `AVAILABILITY_DOMAIN_NUMBER`
  * `COMPARTMENT_OCID`
  * `FINGERPRINT`
  * `LOCAL_DOMAIN`
  * `PRIVATE_KEY_B64`
  * `REGION`
  * `SSH_INGRESS_SOURCE`
  * `SSH_PUBLIC_KEY_B64`
  * `TENANCY_OCID`
  * `USER_OCID`

## Terraform Cloud
### Update Variables for Terraform Cloud Workspace
  * `TF_VAR_TENANCY_OCID`
    * Tenancy's OCID
  * `TF_VAR_USER_OCID `
    * User's OCID
  * `TF_VAR_REGION `
    * OCI Cloud Region
  * `TF_VAR_PRIVATE_KEY_B64 `
    * **Sensitive**
    * Base64 encoded API private key for oci provider
  * `TF_VAR_FINGERPRINT `
    * Fingerprint of the API private key for oci provider
  * `TF_VAR_COMPARTMENT_OCID`
    * Go to https://cloud.oracle.com/identity/compartments and copy the OCID
  * `TF_VAR_SSH_PUBLIC_KEY_B64`
    * Base64-encoded SSH public key
    * It should decode to a single line of text (no line breaks)
    * This should be your SSH public key so you can SSH to the machine after it
      is created.
  * `TF_VAR_SSH_INGRESS_SOURCE`
    * See https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_security_list#source
  * `TF_VAR_VAPID_PRIVATE_KEY`
    * **Sensitive**
    * Private key for Vapid
  * `TF_VAR_VAPID_PUBLIC_KEY`
    * Public key for Vapid
  * `TF_VAR_LOCAL_DOMAIN`
    * Domain of your Mastodon instance
  * `TF_VAR_ADMIN_EMAIL_ADDRESS`
    * Email address associated with admin Mastodon account
  * `TF_VAR_ADMIN_USERNAME`
    * Username associated with the admin Mastodon account
    * Defaults to `admin`
  * `TF_VAR_AVAILABILITY_DOMAIN_NUMBER`
    * Availibility Domain Number in OCI cloud to use
    * Choose a value of `1`, `2`, or `3`
    * Defaults to `1`
