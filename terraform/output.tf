output "ip" {
  value = [esxi_guest.k8s_master.ip_address]
}