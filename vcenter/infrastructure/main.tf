terraform {
	backend "remote" {
		organization = "dkoshkin-org"
		workspaces {
			name = "Homelab"
		}
	}
}

provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server

  allow_unverified_ssl = var.vsphere_insecure
}

# ==================== VMs ==================== #

locals {
  user = "ubuntu"


  direcotires = {
    kubernetes-bootstrapper = {
      source = "vms/kubernetes-bootstrapper",
      destination = "/home/${local.user}/kubernetes-bootstrapper",
    },
    kubernetes-image-builder = {
      source = "vms/kubernetes-image-builder",
      destination = "/home/${local.user}/kubernetes-image-builder",
    },
  }
}

# ========== kubernetes-image-builder ========== #
module "kubernetes-image-builder" {
  source          = "./vmclone"
  name            = "kubernetes-image-builder"
  vsphere_folder  = "Kubernetes/Management"
}

resource "null_resource" "kubernetes-image-builder" {
  connection {
    host      = module.kubernetes-image-builder.default_ip_address
    user      = local.user
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir ${local.direcotires.kubernetes-image-builder.destination}",
    ]
  }

  provisioner "file" {
    source      = "${local.direcotires.kubernetes-image-builder.source}/vsphere.json"
    destination = "${local.direcotires.kubernetes-image-builder.destination}/vsphere.json"
  }
  provisioner "file" {
    source      = "${local.direcotires.kubernetes-image-builder.source}/kubernetes-v1.26.6.json"
    destination = "${local.direcotires.kubernetes-image-builder.destination}/kubernetes-v1.26.6.json"
  }
  provisioner "file" {
    source      = "${local.direcotires.kubernetes-image-builder.source}/kubernetes-v1.27.3.json"
    destination = "${local.direcotires.kubernetes-image-builder.destination}/kubernetes-v1.27.3.json"
  }

  depends_on = [
    module.kubernetes-image-builder
  ]
}
# ========== kubernetes-image-builder ========== #

# ========== kubernetes-bootstrapper ========== #
module "kubernetes-bootstrapper" {
  source          = "./vmclone"
  name            = "kubernetes-bootstrapper"
  vsphere_folder  = "Kubernetes/Management"
  cpu             = 2
  memory          = 8192
  vsphere_datastore = "NVMe-1"
}

resource "null_resource" "kubernetes-bootstrapper" {
  connection {
    host      = module.kubernetes-bootstrapper.default_ip_address
    user      = local.user
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir ${local.direcotires.kubernetes-bootstrapper.destination}",
    ]
  }
  provisioner "file" {
    source      = "${local.direcotires.kubernetes-bootstrapper.source}/.envs"
    destination = "${local.direcotires.kubernetes-bootstrapper.destination}/.envs"
  }
  provisioner "file" {
    source      = "${local.direcotires.kubernetes-bootstrapper.source}/setup.sh"
    destination = "${local.direcotires.kubernetes-bootstrapper.destination}/setup.sh"
  }
  provisioner "file" {
    source      = "${local.direcotires.kubernetes-bootstrapper.source}/clusterclass-template.yaml"
    destination = "${local.direcotires.kubernetes-bootstrapper.destination}/clusterclass-template.yaml"
  }
  provisioner "file" {
    source      = "${local.direcotires.kubernetes-bootstrapper.source}/cluster-template.yaml"
    destination = "${local.direcotires.kubernetes-bootstrapper.destination}/cluster-template.yaml"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x ${local.direcotires.kubernetes-bootstrapper.destination}/setup.sh",
      "${local.direcotires.kubernetes-bootstrapper.destination}/setup.sh",
    ]
  }

  depends_on = [
    module.kubernetes-bootstrapper
  ]
}
# ========== kubernetes-bootstrapper ========== #
