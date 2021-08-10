#Visual Basic module importeren
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic")

#Output form 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")  

$Form = New-Object System.Windows.Forms.Form    
$Form.Size = New-Object System.Drawing.Size(800,400)
$Form.BackColor = "#FFFFFF"
$Form.Text = "Create Terraform files"  

############################################## Start functions

#Download Terraform + Github bestanden
function Download {
$DocumentsLocation = [Environment]::GetFolderPath("MyDocuments")
mkdir $DocumentsLocation\Terraform
#replace by Choco- https://community.chocolatey.org/packages/terraform/0.13.5
$DownloadTerraform = Invoke-WebRequest -Uri https://releases.hashicorp.com/terraform/0.13.5/terraform_0.13.5_windows_amd64.zip -Outfile $DocumentsLocation\Terraform\Terraform.zip
#$DownloadFiles = Invoke-WebRequest -Uri <Github URL> -Outfile $DocumentsLocation\Terraform\TerraformFiles.zip
Expand-Archive -LiteralPath $DocumentsLocation\Terraform\Terraform.zip -DestinationPath $DocumentsLocation\Terraform\ | Out-Null
#Expand-Archive -LiteralPath $DocumentsLocation\Terraform\TerraformFiles.zip -DestinationPath $DocumentsLocation\Terraform\ | Out-Null
Start-Sleep -Seconds 2
Remove-Item $DocumentsLocation\Terraform\Terraform.zip | Out-Null
#Remove-Item $DocumentsLocation\Terraform\TerraformFiles.zip | Out-Null
Invoke-Item $DocumentsLocation\Terraform
                     }

#Download & install Notepad++
function Notepad {
$DocumentsLocation = [Environment]::GetFolderPath("MyDocuments")
mkdir $DocumentsLocation\Notepad++
#Replace with Choco
$DownloadNotepad = Invoke-WebRequest https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.1.2/npp.8.1.2.Installer.exe -OutFile $DocumentsLocation\Notepad++\notepad.exe
Invoke-Item $DocumentsLocation\Notepad++\notepad.exe
                     }

#Verify passwd
function verify {

    $Passwd = $MaskedTextBox.Text
    $Passwd
    $outputBox.text = $Passwd
                     }

#OK function: make generate button available
function ok {   

    $generate.Visible = $true 
}

############################################## Start knoppen

#Download label Terraform
$label0 = New-Object System.Windows.Forms.Label
$label0.Location = New-Object System.Drawing.Point(10,15)
$label0.Size = New-Object System.Drawing.Size(150,20)
$label0.Text = 'Download Terraform'
$form.Controls.Add($label0)

#knop Download Terraform 
$Button0 = New-Object System.Windows.Forms.Button 
$Button0.Location = New-Object System.Drawing.Size(10,35) 
$Button0.Size = New-Object System.Drawing.Size(110,50) 
$Button0.Text = "Download" 
$Button0.Add_Click({Download}) 
$Form.Controls.Add($Button0) 

#Download label Notepad++
$label1 = New-Object System.Windows.Forms.Label
$label1.Location = New-Object System.Drawing.Point(10,95)
$label1.Size = New-Object System.Drawing.Size(180,20)
$label1.Text = 'Download and install Notepad++'
$form.Controls.Add($label1)

#knop Download Notepad++ 
$Button1 = New-Object System.Windows.Forms.Button 
$Button1.Location = New-Object System.Drawing.Size(10,115) 
$Button1.Size = New-Object System.Drawing.Size(110,50) 
$Button1.Text = "Download" 
$Button1.Add_Click({Notepad}) 
$Form.Controls.Add($Button1) 

#knop OK 
$okButton = New-Object System.Windows.Forms.Button 
$okButton.Location = New-Object System.Drawing.Size(210,300) 
$okButton.Size = New-Object System.Drawing.Size(75,23) 
$okButton.Text = "OK" 
$okButton.Add_Click({ok}) 
$Form.Controls.Add($okButton)

#Verify button
$VerButton = New-Object System.Windows.Forms.Button 
$VerButton.Location = New-Object System.Drawing.Size(590,209) 
$VerButton.Size = New-Object System.Drawing.Size(75,23) 
$VerButton.Text = "Verify pass" 
$VerButton.Add_Click({verify}) 
$Form.Controls.Add($VerButton)

############################################# Einde knoppen
############################################# Begin input box

#Organisation
$labelOrg = New-Object System.Windows.Forms.Label
$labelOrg.Location = New-Object System.Drawing.Point(210,15)
$labelOrg.Size = New-Object System.Drawing.Size(180,20)
$labelOrg.Text = 'Enter Organisation name:'
$form.Controls.Add($labelOrg)

$textBoxOrg = New-Object System.Windows.Forms.TextBox
$textBoxOrg.Location = New-Object System.Drawing.Point(210,40)
$textBoxOrg.Size = New-Object System.Drawing.Size(180,20)
$form.Controls.Add($textBoxOrg)
$Orgname = $textBoxOrg.Text
$Orgname

#Get client name
$labelClt = New-Object System.Windows.Forms.Label
$labelClt.Location = New-Object System.Drawing.Point(210,70)
$labelClt.Size = New-Object System.Drawing.Size(180,20)
$labelClt.Text = 'Enter client name:'
$form.Controls.Add($labelClt)

$textBoxClient = New-Object System.Windows.Forms.TextBox
$textBoxClient.Location = New-Object System.Drawing.Point(210,90)
$textBoxClient.Size = New-Object System.Drawing.Size(180,20)
$form.Controls.Add($textBoxClient)
$ClientName = $textBoxClient.Text
$ClientName

#Get Password + Verify
$labelPWD = New-Object System.Windows.Forms.Label
$labelPWD.Location = New-Object System.Drawing.Point(210,190) 
$labelPWD.Size = New-Object System.Drawing.Size(180,20)
$labelPWD.Text = 'Enter Terraform password:'
$form.Controls.Add($labelPWD)

$MaskedTextBox = New-Object System.Windows.Forms.MaskedTextBox
$MaskedTextBox.Location = New-Object System.Drawing.Point(210,210)
$MaskedTextBox.Size = New-Object System.Drawing.Size(180,20)
$MaskedTextBox.PasswordChar = '*'
$Form.Controls.Add($MaskedTextBox)
$Passwd = $MaskedTextBox.Text
$Passwd

$labelCon = New-Object System.Windows.Forms.Label
$labelCon.Location = New-Object System.Drawing.Point(410,190)
$labelCon.Size = New-Object System.Drawing.Size(180,20)
$labelCon.Text = 'Controle:'
$form.Controls.Add($labelCon)

$outputBox = New-Object System.Windows.Forms.TextBox 
$outputBox.Location = New-Object System.Drawing.Size(410,210)
$outputBox.Size = New-Object System.Drawing.Size(180,20) 
$outputBox.MultiLine = $true;
$outputBox.ScrollBars = "Vertical, horizontal"
$outputBox.font = "lucida console,10" 
$outputBox.WordWrap = $false;
$outputbox.readonly = $True;
$Form.Controls.Add($outputBox)

#Get Terraform user name
$labelTerr = New-Object System.Windows.Forms.Label
$labelTerr.Location = New-Object System.Drawing.Point(210,130)
$labelTerr.Size = New-Object System.Drawing.Size(280,20)
$labelTerr.Text = 'Enter Terraform username (default Terraform):'
$form.Controls.Add($labelTerr)

$TerrUser = New-Object System.Windows.Forms.TextBox
$TerrUser.Location = New-Object System.Drawing.Point(210,150)
$TerrUser.Size = New-Object System.Drawing.Size(180,20)
$form.Controls.Add($TerrUser)
$TerraformUser = $TerrUser.Text
$TerraformUser 

#Get VDC name
$labelVdc = New-Object System.Windows.Forms.Label
$labelVdc.Location = New-Object System.Drawing.Point(210,240)
$labelVdc.Size = New-Object System.Drawing.Size(180,20)
$labelVdc.Text = 'Enter Vdc name:'
$form.Controls.Add($labelVdc)

$VDCnameIn = New-Object System.Windows.Forms.TextBox
$VDCnameIn.Location = New-Object System.Drawing.Point(210,260)
$VDCnameIn.Size = New-Object System.Drawing.Size(180,20)
$form.Controls.Add($VDCnameIn)
$VDCname = $VDCnameIn.Text
$VDCname

############################################# einde input/controle

############################################# Generate variable file

#knop Generate 
$generate = New-Object System.Windows.Forms.Button 
$generate.Location = New-Object System.Drawing.Size(10,300) 
$generate.Size = New-Object System.Drawing.Size(110,50)
$generate.Font = New-Object System.Drawing.Font("Lucida Console",12,[System.Drawing.FontStyle]::Regular) 
$generate.Text = "Generate!" 
$generate.Add_Click({generate})
$generate.Visible = $false
$generate.ForeColor = 'Red'
$generate.BackColor = 'Green'
$Form.Controls.Add($generate)

#generate file function
function generate {
$DocumentsLocation = [Environment]::GetFolderPath("MyDocuments")
$fileMain = @'
# Terraform Block
terraform {
  required_version = "0.13.5"
  required_providers {
    vcd = {
      source = "vmware/vcd"
      version = "3.0.0"
    }
  }
}

# Provider Block
provider "vcd" {
  user = var.UserName
  password = var.UserPassword
  auth_type = "integrated"
  org = var.OrgName
  vdc = var.OrgVdcName 
  url = "https://my.bizzcloud.be/api"
}

# Resource Blocks
resource "vcd_vapp" "Vapp" {
  name = var.VappName
}

resource "vcd_vapp_network" "vAppNet" {
  name  = var.VappNetworkName
  vapp_name = vcd_vapp.Vapp.name
  gateway = "192.168.13.1"
  netmask = "255.255.255.0"
  dns1 = "195.238.2.21"
  dns2 = "8.8.8.8"
  static_ip_pool {
    start_address = "192.168.13.100"
    end_address = "192.168.13.199"
  }
}

resource "vcd_vapp_org_network" "vappOrgNet" {
  vapp_name = vcd_vapp.Vapp.name
  org_network_name  = var.OrgVcdNetworkName
}

resource "vcd_vapp_vm" "vm1" {
  name = var.Vm1Name
  computer_name = var.Vm1Name
  vapp_name = vcd_vapp.Vapp.name
  power_on = false
  cpu_hot_add_enabled = true
  memory_hot_add_enabled = true
  catalog_name = "Public_Catalog"
  template_name = var.TemplateWindows2019
#  storage_profile = var.Tier0
  memory = 4096
  cpus = 1
  cpu_cores = 1
  network {
    name = vcd_vapp_network.vAppNet.name
    type = "vapp"
    ip_allocation_mode = "MANUAL"
    ip = "192.168.13.100"
    adapter_type = "VMXNET3"
    is_primary = true
  }
}

resource "vcd_vapp_vm" "vm2" {
  name = var.Vm2Name
  computer_name = var.Vm2Name
  vapp_name = vcd_vapp.Vapp.name
  power_on = false
  cpu_hot_add_enabled = true
  memory_hot_add_enabled = true
  catalog_name  = "Public_Catalog"
  template_name = var.TemplateWindows2019
#  storage_profile = var.Tier0
  memory = 6144
  cpus = 2
  cpu_cores = 1
  network {
    name = vcd_vapp_network.vAppNet.name
    type = "vapp"
    ip_allocation_mode = "MANUAL"
    ip = "192.168.13.101"
    adapter_type = "VMXNET3"
    is_primary = true
  }
}

resource "vcd_vm_internal_disk" "vm2_disk1" {
  vapp_name = vcd_vapp.Vapp.name
  vm_name         = vcd_vapp_vm.vm2.name
  bus_type        = "paravirtual"
  size_in_mb      = "5120"
  bus_number      = 1
  unit_number     = 1
}

resource "vcd_vm_internal_disk" "vm2_disk2" {
  vapp_name = vcd_vapp.Vapp.name
  vm_name         = vcd_vapp_vm.vm2.name
  bus_type        = "paravirtual"
  size_in_mb      = "5120"
  bus_number      = 1
  unit_number     = 2
  depends_on      = [ vcd_vm_internal_disk.vm2_disk1 ]
}

resource "vcd_vapp_vm" "vm3" {
  name = var.Vm3Name
  computer_name = var.Vm3Name
  vapp_name = vcd_vapp.Vapp.name
  power_on = false
  cpu_hot_add_enabled = true
  memory_hot_add_enabled = true
  catalog_name = "Public_Catalog"
  template_name = var.TemplateFireboxV
  memory = 1024
  cpus = 1
  cpu_cores = 1
  network {
    name = var.OrgVcdNetworkName
    type = "org"
    ip_allocation_mode = "POOL"
    adapter_type = "VMXNET3"
    is_primary = true
  }
  network {
    name = vcd_vapp_network.vAppNet.name
    type = "vapp"
    ip_allocation_mode = "MANUAL"
    ip = "192.168.13.254"
    adapter_type = "VMXNET3"
    is_primary = false
  }
}
'@

$Orgname = $textBoxOrg.Text
$Orgname
$ClientName = $textBoxClient.Text
$ClientName
$Passwd = $MaskedTextBox.Text
$Passwd
$TerraformUser = $TerrUser.Text
$TerraformUser
$VDCname = $VDCnameIn.Text
$VDCname


$filevariable = @"
variable "OrgName"	{
	type = string
	default = "$Orgname"
	}
variable "UserName" {
	type = string
	default = "$TerraformUser"
	}
variable "UserPassword" {
	type = string
	default = "$Passwd"
	}
variable "OrgVdcName" {
	type = string
	default = "$VDCname"
	}
variable "OrgVcdNetworkName" {
	type = string
	default = "OrgNet-direct-$ClientName"
	} 
variable "VappName" {
	type = string
	default = "vApp_$ClientName"
    }
variable "VappNetworkName" {
	type = string
	default = "vAppNet-$ClientName"
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
"@

#$test = $ClientName + $Passwd + $TerraformUser + $VDCname

$fileMain | Out-File $DocumentsLocation\Terraform\main.tf
$filevariable | Out-File $DocumentsLocation\Terraform\variables.tf
#$test | Out-File $DocumentsLocation\Terraform\test.txt
#Remove-Item $DocumentsLocation\Terraform\test.txt | Out-Null
Invoke-Item $DocumentsLocation\Terraform
start-Process notepad++ $DocumentsLocation\Terraform\variables.tf

                     }

$Form.Add_Shown({$Form.Activate()})
[void] $Form.ShowDialog()