variable "vcd_org_user" {
  default     = "administrator"
  description = "vCD Tenant User"
}

variable "vcd_org_password" {
  default     = "password"
  description = "vCD Tenant Password"
}

variable "vcd_org_org" {
  default     = "def_org"
  description = "vCD Tenant Org"
}

variable "vcd_org_url" {
  default     = "https://vcd.vmcloud.reg.ru/api"
  description = "vCD Tenant URL"
}

variable "vcd_org_vdc" {
  default     = "def_org_vdc"
  description = "vCD Tenant VDC"
}

variable "vcd_org_max_retry_timeout" {
  description = "Retry Timeout"
  default     = "240"
}

variable "vcd_org_allow_unverified_ssl" {
  description = "vCD allow unverified SSL"
  default     = "true"
}

variable "vcd_org_edge_name" {
  description = "vCD edge name"
  default     = "def_edge"
}

variable "vcd_org_catalog" {
  description = "vCD Catalog Name"
}

variable "template_vm" {
  description = "template vm"
  default = "CentOS-7.6-x86_64-Minimal-1810_en"
}
