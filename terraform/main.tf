provider "esxi" {
  esxi_hostname = var.esxi_hostname
  esxi_hostport = var.esxi_hostport
  esxi_hostssl  = var.esxi_hostssl
  esxi_username = var.esxi_username
  esxi_password = var.esxi_password
}

# Network Configuration
resource "esxi_vswitch" "k3s_network" {
  name = "Kubernetes Network Switch"
  uplink {
    name = "vusb0"  # Uncomment and adjust based on your ESXi host's network interface (vmnic1)
  }
  
  mtu        = 9000   # Jumbo frames for better network performance
}

resource "esxi_portgroup" "k3s_portgroup" {
  name    = "Kubernetes Network"
  vswitch = esxi_vswitch.k3s_network.name
  #vlan    = 4040     # Adjust VLAN ID as needed
}

# Master Node Configuration
resource "esxi_guest" "k8s_master" {
  guest_name    = "k8s-master"
  disk_store    = var.datastore
  ovf_source    = "https://cloud-images.ubuntu.com/trusty/current/trusty-server-cloudimg-amd64.ova"
  #clone_from_vm     = "ubuntu-20.04-template"
  guestos       = "ubuntu-64"
  boot_firmware = "efi"

  memsize   = "4096"
  numvcpus  = "2"
  power     = "on"
  virthwver = "19"  # Hardware version compatible with ESXi

  network_interfaces {
    virtual_network = esxi_portgroup.k3s_portgroup.name
    nic_type       = "vmxnet3"  # High performance network adapter
  }

  guest_startup_timeout  = 180
  guest_shutdown_timeout = 60
  ovf_properties_timer   = 180

  provisioner "local-exec" {
    command = "echo 'Master node ${self.guest_name} has been created with IP: ${self.ip_address}'"
  }
}
