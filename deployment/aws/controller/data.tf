data "aws_ami" "appgate_ami" {
  owners = ["679593333241"] # Appgate

  filter {
    name   = "name"
    values = ["*${var.appgate_version}*"]
  }

  # Product Codes
  # BYOL      2t5itl5x43ar3tljs7s2mu3rw
  # PAID      cbse92jrh5o5yi82s7eub483b
  # METERED   6prv7in80dxul9esf60znqimb

  filter {
    name   = "product-code"
    values = [lookup(var.product_codes, lower(var.licensing_type))]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

locals {
  controller_user_data = <<-EOF
#!/bin/bash
PUBLIC_HOSTNAME=`curl --silent http://169.254.169.254/latest/meta-data/public-hostname`
# seed the first controller, and enable admin interface on :8443
cz-seed \
    --password cz cz \
    --dhcp-ipv4 eth0 \
    --enable-logserver \
    --no-registration \
    --hostname "$PUBLIC_HOSTNAME" \
    --admin-password ${var.admin_login_password} \
    | jq '.remote.adminInterface.hostname = .remote.peerInterface.hostname | .remote.adminInterface.allowSources = .remote.peerInterface.allowSources' >> /home/cz/seed.json
EOF
}