locals {
  ipv4_netmask = var.ipv4_address != "" ? var.ipv4_netmask : null
  ipv4_gateway = var.ipv4_address != "" ? cidrhost("${var.ipv4_address}/${var.ipv4_netmask}", 1) : null
}

resource "vsphere_virtual_machine" "vm" {
  name             = var.name
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  folder           = var.vsphere_folder
  datastore_id     = data.vsphere_datastore.datastore.id
  num_cpus         = var.cpu
  memory           = var.memory
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  scsi_type        = data.vsphere_virtual_machine.template.scsi_type

  wait_for_guest_ip_timeout  = var.wait_for_guest_ip_timeout
  wait_for_guest_net_timeout = var.wait_for_guest_net_timeout

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = var.disk_size
    thin_provisioned = var.disk_thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    linked_clone  = var.linked_clone
    
    customize {
      linux_options {
        host_name = var.name
        domain    = var.domain
      }

      network_interface {
        ipv4_address = var.ipv4_address
        ipv4_netmask = local.ipv4_netmask
      }
      ipv4_gateway = local.ipv4_gateway
    }
  }
}
