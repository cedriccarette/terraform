variable "OrgName"	{
	type = string
	default = "obj1"
	}
variable "UserName" {
	type = string
	default = "obj2"
	}
variable "UserPassword" {
	type = string
	default = "obj3"
	}
variable "OrgVdcName" {
	type = string
	default = "obj4"
	}
variable "OrgVcdNetworkName" {
	type = string
	default = "OrgNet-direct-obj1"
	}
variable "VappName" {
	type = string
	default = "vApp-obj5"
	}
variable "VappNetworkName" {
	type = string
	default = "vAppNet-obj5"
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
