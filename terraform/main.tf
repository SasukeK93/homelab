terraform {
  required_providers {
    esxi = {
      source  = "registry.terraform.io/josenk/esxi"
      version = "~> 1.10.3"
    }
  }
}

provider "esxi" {
  esxi_hostname = var.esxi_hostname
  esxi_hostport = var.esxi_hostport
  esxi_hostssl  = var.esxi_hostssl
  esxi_username = var.esxi_username
  esxi_password = var.esxi_password
}

# Cloud Init Configuration
data "template_file" "Master" {
  template = file("userdata-master.tpl")
  vars = {
    HOSTNAME = var.vm_hostname
    HELLO    = "Hello World!"
  }
}

# Master Node Configuration
resource "esxi_guest" "k8s_master" {
  guest_name    = "k8s-master"
  disk_store    = var.datastore
  ovf_source    = "~/homelab/ubuntu-fresh/ubuntu-20.04-template.ovf"
  #clone_from_vm     = "ubuntu-20.04-template"
  guestos       = "ubuntu-64"
  boot_firmware = "efi"

  memsize   = "4096"
  numvcpus  = "2"
  power     = "on"
  virthwver = "19"  # Hardware version compatible with ESXi

  network_interfaces {
    virtual_network = "VM Network" #esxi_portgroup.k3s_portgroup.name
    nic_type       = "vmxnet3"  # High performance network adapter
  }

  guest_startup_timeout  = 180
  guest_shutdown_timeout = 60
  ovf_properties_timer   = 180

  guestinfo = {
    "userdata.encoding" = "gzip+base64"
    "userdata"         = base64gzip(data.template_file.Master.rendered)
  }

  provisioner "local-exec" {
    command = "echo 'Master node ${self.guest_name} has been created with IP: ${self.ip_address}'"
  }
}
