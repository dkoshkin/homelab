data "vsphere_datacenter" "vsphere_datacenter" {
  name = var.vsphere_datacenter
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.vsphere_cluster
  datacenter_id = data.vsphere_datacenter.vsphere_datacenter.id
}

data "vsphere_network" "network" {
  name          = var.vsphere_network
  datacenter_id = data.vsphere_datacenter.vsphere_datacenter.id
}

data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.vsphere_datacenter.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.vm_template_name
  datacenter_id = data.vsphere_datacenter.vsphere_datacenter.id
}
