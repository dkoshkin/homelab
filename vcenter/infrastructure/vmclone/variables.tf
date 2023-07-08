variable "name" {
  description = "Name of the VM"
}

# Optional variables
variable "domain" {
  description = "Domain of the VM"
  default     = "lab.dimitrikoshkin.com"
}

variable "vsphere_datacenter" {
  description = "Name of the vSphere Datacenter"
  default     = "Garage"
}

variable "vsphere_cluster" {
  description = "Name of the vSphere Cluster"
  default     = "Cluster"
}

variable "vsphere_network" {
  description = "Name of the vSphere Network"
  default     = "VM Network"
}

variable "vsphere_datastore" {
  description = "Name of the datastore to use for the VM"
  default     = "HDD-1"
}

variable "vsphere_folder" {
  description = "Path to the vSphere folder where the VM will be created"
  default     = "/Management"
}

variable "vm_template_name" {
  description = "Name of the vSphere Template to use for the VM"
  default     = "ubuntu-22.04-docker-base"
}

variable "linked_clone" {
  description = "Controls whether the VM should be a linked clone or not. Linked clones require less storage space but may be slower."
  default     = false
}

variable "cpu" {
  description = "Number of CPUs to allocate to the VM"
  default     = 1
}

variable "memory" {
  description = "Memory in MB to allocate to the VM"
  default     = 4096
}

variable "disk_size" {
  description = "Root volume size in GB to allocate to the VM. Must be equal or greater than the template size"
  default     = 40
}

variable "disk_thin_provisioned" {
  description = "Controls whether the root volume should be thin provisioned or not"
  default     = true
}

variable "ipv4_address" {
  description = "IPv4 address to assign to the VM. If empty, DHCP will be used"
  default     = ""
}

variable "ipv4_netmask" {
  description = "IPv4 netmask to assign to the VM when using a static IP address"
  default     = "24"
}

variable "wait_for_guest_ip_timeout" {
  description = "The amount of time, in minutes, to wait for an available guest IP address on the virtual machine."
  default = 5
}
variable "wait_for_guest_net_timeout" {
  description = "The amount of time, in minutes, to wait for an available routable guest IP address on the virtual machine"
  default = 0
}
