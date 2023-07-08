variable "vsphere_server" {
  description = "The vCenter server address without the protocol"
}

variable "vsphere_user" {
  description = "The vCenter user with the correct permissions to create VMs"
}
  
variable "vsphere_password" {
  description = "The vCenter user password"
  sensitive = true
}

variable "vsphere_insecure" {
    description = "Set to true if the vCenter server uses a self-signed certificate"
    default = true
}
