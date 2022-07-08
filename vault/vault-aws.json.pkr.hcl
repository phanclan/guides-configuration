
variable "aws_access_key_id" {
  type    = string
  default = "${env("AWS_ACCESS_KEY_ID")}"
}

variable "aws_region" {
  type    = string
  default = "${env("AWS_REGION")}"
}

variable "aws_secret_access_key" {
  type    = string
  default = "${env("AWS_SECRET_ACCESS_KEY")}"
}

variable "consul_comment" {
  type    = string
  default = "Consul"
}

variable "consul_ent_url" {
  type    = string
  default = "${env("CONSUL_ENT_URL")}"
}

variable "consul_group" {
  type    = string
  default = "consul"
}

variable "consul_home" {
  type    = string
  default = "/srv/consul"
}

variable "consul_user" {
  type    = string
  default = "consul"
}

variable "consul_version" {
  type    = string
  default = "${env("CONSUL_VERSION")}"
}

variable "release_version" {
  type    = string
  default = "${env("RELEASE_VERSION")}"
}

variable "vault_comment" {
  type    = string
  default = "Vault"
}

variable "vault_ent_url" {
  type    = string
  default = "${env("VAULT_ENT_URL")}"
}

variable "vault_group" {
  type    = string
  default = "vault"
}

variable "vault_home" {
  type    = string
  default = "/srv/vault"
}

variable "vault_user" {
  type    = string
  default = "vault"
}

variable "vault_version" {
  type    = string
  default = "${env("VAULT_VERSION")}"
}

variable "vcs_name" {
  type    = string
  default = "${env("VCS_NAME")}"
}

data "amazon-ami" "autogenerated_1" {
  access_key = "${var.aws_access_key_id}"
  filters = {
    name                = "*RHEL-7.3_HVM_GA-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["309956199498"]
  region      = "${var.aws_region}"
  secret_key  = "${var.aws_secret_access_key}"
}

data "amazon-ami" "autogenerated_2" {
  access_key = "${var.aws_access_key_id}"
  filters = {
    name                = "*ubuntu-focal-20.04-amd64-server-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["099720109477"]
  region      = "${var.aws_region}"
  secret_key  = "${var.aws_secret_access_key}"
}

source "amazon-ebs" "amazon-ebs-rhel-7.3-systemd" {
  access_key                  = "${var.aws_access_key_id}"
  ami_description             = "HashiCorp Vault Image ${var.release_version}"
  ami_name                    = "vault-image_${var.release_version}_vault_${var.vault_version}_consul_${var.consul_version}_rhel_7.3"
  ami_virtualization_type     = "hvm"
  associate_public_ip_address = true
  force_delete_snapshot       = true
  force_deregister            = true
  instance_type               = "t2.medium"
  region                      = "${var.aws_region}"
  secret_key                  = "${var.aws_secret_access_key}"
  source_ami                  = "${data.amazon-ami.autogenerated_1.id}"
  ssh_pty                     = true
  ssh_timeout                 = "5m"
  ssh_username                = "ec2-user"
  tags = {
    Built-By        = "${var.vcs_name}"
    Consul-Version  = "${var.consul_version}"
    Name            = "Vault RHEL 7.3 Image ${var.release_version}: Vault v${var.vault_version} Consul v${var.consul_version}"
    Nomad-Version   = "nil"
    OS              = "rhel"
    OS-Version      = "7.3"
    Product         = "Vault"
    Release-Version = "${var.release_version}"
    System          = "Vault"
    Vault-Version   = "${var.vault_version}"
  }
}

source "amazon-ebs" "amazon-ebs-ubuntu-20.04-systemd" {
  access_key                  = "${var.aws_access_key_id}"
  ami_description             = "HashiCorp Vault Image ${var.release_version}"
  ami_name                    = "vault-image_${var.release_version}_vault_${var.vault_version}_consul_${var.consul_version}_ubuntu_20.04"
  ami_virtualization_type     = "hvm"
  associate_public_ip_address = true
  force_delete_snapshot       = true
  force_deregister            = true
  instance_type               = "t2.medium"
  region                      = "${var.aws_region}"
  secret_key                  = "${var.aws_secret_access_key}"
  source_ami                  = "${data.amazon-ami.autogenerated_2.id}"
  ssh_pty                     = true
  ssh_timeout                 = "10m"
  ssh_username                = "ubuntu"
  tags = {
    Built-By        = "${var.vcs_name}"
    Consul-Version  = "${var.consul_version}"
    Name            = "Vault Ubuntu 20.04 Image ${var.release_version}: Vault v${var.vault_version} Consul v${var.consul_version}"
    Nomad-Version   = "nil"
    OS              = "ubuntu"
    OS-Version      = "20.04"
    Product         = "Vault"
    Release-Version = "${var.release_version}"
    System          = "Vault"
    Vault-Version   = "${var.vault_version}"
  }
}

build {
  sources = ["source.amazon-ebs.amazon-ebs-rhel-7.3-systemd", "source.amazon-ebs.amazon-ebs-ubuntu-20.04-systemd"]

  provisioner "file" {
    destination = "/tmp"
    source      = "../"
  }

  provisioner "shell" {
    inline = ["bash /tmp/shared/scripts/base.sh"]
  }

  provisioner "shell" {
    inline = ["bash /tmp/shared/scripts/base-aws.sh"]
    only   = ["amazon-ebs-rhel-7.3-systemd", "amazon-ebs-ubuntu-20.04-systemd"]
  }

  provisioner "shell" {
    environment_vars = ["GROUP=${var.consul_group}", "USER=${var.consul_user}", "COMMENT=${var.consul_comment}", "HOME=${var.consul_home}"]
    inline           = ["bash /tmp/shared/scripts/setup-user.sh"]
  }

  provisioner "shell" {
    environment_vars = ["VERSION=${var.consul_version}", "URL=${var.consul_ent_url}", "USER=${var.consul_user}", "GROUP=${var.consul_group}"]
    inline           = ["bash /tmp/consul/scripts/install-consul.sh"]
  }

  provisioner "shell" {
    inline = ["bash /tmp/consul/scripts/install-consul-systemd.sh"]
    only   = ["amazon-ebs-rhel-7.3-systemd", "amazon-ebs-ubuntu-20.04-systemd"]
  }

  provisioner "shell" {
    environment_vars = ["GROUP=${var.vault_group}", "USER=${var.vault_user}", "COMMENT=${var.vault_comment}", "HOME=${var.vault_home}"]
    inline           = ["bash /tmp/shared/scripts/setup-user.sh"]
  }

  provisioner "shell" {
    environment_vars = ["VERSION=${var.vault_version}", "URL=${var.vault_ent_url}", "USER=${var.vault_user}", "GROUP=${var.vault_group}"]
    inline           = ["bash /tmp/vault/scripts/install-vault.sh"]
  }

  provisioner "shell" {
    inline = ["bash /tmp/vault/scripts/install-vault-systemd.sh"]
    only   = ["amazon-ebs-rhel-7.3-systemd", "amazon-ebs-ubuntu-20.04-systemd"]
  }

  provisioner "shell" {
    inline = ["cd /tmp/shared/scripts && bash /tmp/shared/scripts/setup-testing.sh", "cd /tmp && rake vault:spec"]
    only   = ["amazon-ebs-rhel-7.3-systemd", "amazon-ebs-ubuntu-20.04-systemd"]
  }

  provisioner "shell" {
    inline = ["bash /tmp/shared/scripts/cleanup-aws.sh"]
    only   = ["amazon-ebs-rhel-7.3-systemd", "amazon-ebs-ubuntu-20.04-systemd"]
  }

  provisioner "shell" {
    inline = ["bash /tmp/shared/scripts/cleanup.sh"]
  }

}
