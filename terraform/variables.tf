variable "esxi_hostname" {
  description = "ESXi host address"
  type        = string
}

variable "esxi_hostport" {
  description = "ESXi host SSH port"
  type        = number
  default     = 22
}

variable "esxi_hostssl" {
  description = "ESXi host SSL"
  type        = number
  default     = 443
}

variable "esxi_username" {
  description = "ESXi host username"
  type        = string
}

variable "esxi_password" {
  description = "ESXi host password"
  type        = string
  sensitive   = true
}

variable "datastore" {
  description = "Name of the datastore to use"
  type        = string
  default     = "datastore1"
}

#variable "network_name" {
#  description = "Name of the network to use"
#  type        = string
#  default     = "VM Network"
#}

variable "template_name" {
  description = "Name of the template VM to clone from"
  type        = string
  default     = "ubuntu-20.04-template"
}