variable "OrgName"	{
	type = string
	default = "orgn"
	}
variable "UserName" {
	type = string
	default = "tuser"
	}
variable "UserPassword" {
	type = string
	default = "tpwd"
	}
variable "OrgVdcName" {
	type = string
	default = "vdcname"
	}
variable "OrgVcdNetworkName" {
	type = string
	default = "OrgNet-direct-orgn"
	}
variable "VappName" {
	type = string
	default = "vApp-client"
	}
variable "VappNetworkName" {
	type = string
	default = "vAppNet-client"
	}
variable "Vm1Name" {
	type = string
	default = "DC"
	}
variable "Vm2Name" {
	type = string
	default = "RDS"
	}
variable "Vm3Name" {
	type = string
	default = "FireboxV"
	}
variable "TemplateWindows2016" {
	type = string
	default = "Win2016 Version 1.9"
	}
variable "TemplateWindows2019" {
	type = string
	default = "Win2019 Version 1.9"
	}
variable "TemplateFireboxV" {
	type = string
	default = "FireboxV v12.6.4U1 Template"
	}
