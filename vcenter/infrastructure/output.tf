output "VMs" {
  value = {
    "kubernetes-image-builder"  = module.kubernetes-image-builder.default_ip_address
    "kubernetes-bootstrapper"   = module.kubernetes-bootstrapper.default_ip_address
  }  
}
