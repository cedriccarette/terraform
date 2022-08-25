﻿#Load Assembly and Library
Add-Type -AssemblyName PresentationFramework

#Check if PowerCLI module exists
if (Get-Module -ListAvailable -Name VMware.PowerCLI) {
    Write-Host "Module exists"
} 
else {
    Install-Module -Name VMware.PowerCLI
}

#Load Vcloud module
Import-Module -Name VMware.VimAutomation.Cloud

#Enable TLS1.2
[System.Net.ServicePointManager]::SecurityProtocol = 'Tls12'

[xml]$Form = @"
<Window
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="Terraform GUI V1.2 by ClearMedia NV a Proximus company" Height="770  " Width="800">
    <Grid>
        <GroupBox Name="Header" Header="First step:" Margin="10,12,604,665"/>
        <Button Name="BTNdwnTerraform" Content="Download Terraform" HorizontalAlignment="Left" Margin="16,35,0,0" VerticalAlignment="Top" Width="157" Height="20"/>
        
        <Label Name="Optional" Content="" HorizontalAlignment="Left" Margin="10,75,0,0" VerticalAlignment="Top" Height="24"/>
        <Label Name="AddPrefix" Content="Add a VM prefix: (Optional:)" HorizontalAlignment="Left" Margin="10,100,0,0" VerticalAlignment="Top" Height="24"/>
        <TextBox Name="prefix" HorizontalAlignment="Left" Margin="12,125,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="120"/>
        <Label Name="lblWinver" Content="Select Windows version:" HorizontalAlignment="Left" Margin="10,150,0,0" VerticalAlignment="Top"/>
        <ComboBox Name="Winver" HorizontalAlignment="Left" Margin="12,175,0,0" VerticalAlignment="Top" Width="120" SelectedIndex="2"/>
        
        <Label Name="lblOrgname" Content="Enter Org name:" HorizontalAlignment="Left" Margin="216,25,0,0" VerticalAlignment="Top"/>
        <TextBox Name="txtOrgname" HorizontalAlignment="Left" Margin="221,50,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="120" Height="18"/>
        <Button Name="BTNlogin" Content="Login" HorizontalAlignment="Left" Margin="379,50,0,0" VerticalAlignment="Top" Width="96"/>

        <Label Name="lblVappName" Content="Enter new vApp name:" HorizontalAlignment="Left" Margin="216,75,0,0" VerticalAlignment="Top" Height="24"/>
        <TextBox Name="txtVappName" HorizontalAlignment="Left" Margin="221,100,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="120"/>
        
        <Label Name="lblOrgNet" Content="Select OrgNet:" HorizontalAlignment="Left" Margin="216,125,0,0" VerticalAlignment="Top"/>
        <ComboBox Name="cmbOrgNet" HorizontalAlignment="Left" Margin="221,150,0,0" VerticalAlignment="Top" Width="120"/>
        
        <Label Name="lblVDC" Content="Select vDC:" HorizontalAlignment="Left" Margin="216,175,0,0" VerticalAlignment="Top"/>
        <ComboBox Name="cmbVDC" HorizontalAlignment="Left" Margin="221,200,0,0" VerticalAlignment="Top" Width="120"/>

        <Button Name="BTNok" Content="Check Info" HorizontalAlignment="Left" Margin="221,230,0,0" VerticalAlignment="Top" Width="120"/>

        <TextBlock Name="textblock" HorizontalAlignment="Left" Margin="523,29,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Height="241" Width="243" FontSize="20"><Run Text="Before "/><Run Language="nl-be" Text="providing the needed information"/><LineBreak/><Run Language="nl-be" Text="make sure you have logged in to the vCloud Director to verify the information!!."/><LineBreak/><Run Language="nl-be"/><LineBreak/><Run Language="nl-be"/></TextBlock>
        
        <Button Name="BTNdeploy" Content="DEPLOY !" HorizontalAlignment="Left" Margin="523,230,0,0" Background="#FF31E614" VerticalAlignment="Top" Width="96"/>
        
        <ScrollViewer VerticalScrollBarVisibility="Auto" Margin="2,250,0,0" Height="380" Width="780"  HorizontalScrollBarVisibility="Disabled">
        <TextBox Name="txtOutput" Text="{Binding Text, Mode=OneWay}" TextWrapping="Wrap" IsReadOnly="True" AcceptsReturn="True" Background="#FF0800AE" Foreground="#FFF5EA04"/>
        </ScrollViewer>

        <ProgressBar Name="ProgressBar" HorizontalAlignment="Center" Height="19" Margin="0,707,0,0" VerticalAlignment="Top" Width="780"/>
    </Grid>
</Window>
"@

$XMLReader = (New-Object System.Xml.XmlNodeReader $Form)
$XMLForm = [Windows.Markup.XamlReader]::Load($XMLReader)

#Load buttons
$DwnTerraform = $XMLForm.FindName('BTNdwnTerraform')
$okButton = $XMLForm.FindName('BTNok')
$login = $XMLForm.FindName('BTNlogin')
$deploy = $XMLForm.FindName('BTNdeploy')
$okButton.IsEnabled = $false
$deploy.IsEnabled = $false

#Load textbox
$Orgname = $XMLForm.FindName('txtOrgname')
$vapp = $XMLForm.FindName('txtVappName')
$TerraformUser = $XMLForm.FindName('txtTerraformusr')
$TerraformPass = $XMLForm.FindName('txtTerrPass')
$vdc = $XMLForm.FindName('cmbVDC')
$network = $XMLForm.FindName('cmbOrgNet')
$Output = $XMLForm.FindName('txtOutput')
$prefix = $XMLForm.FindName('prefix')
$winver = $XMLForm.FindName('Winver')

#Clear textbox
[string]$Orgname.Text = ""
[string]$vdc.Text = ""
$Orgname.IsReadOnly = $true
$vapp.IsReadOnly = $true
$login.IsEnabled = $false

#Load progressbar
$progress = $XMLForm.FindName('ProgressBar')
$progress.Minimum = 0
$progress.Maximum = 100
$progress.Value = 0

#Run as Admin check
$admincheck = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($admincheck -eq $true){
} else {
powershell -WindowStyle hidden -Command "& {[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms'); [System.Windows.Forms.MessageBox]::Show('Script is not running as ADMINISTRATOR','WARNING')}"
exit
}

$Output.Text = "Dear $env:UserName,

Thank you for choosing the Terraform GUI created by ClearMedia NV.
Before you can deploy a new environment, you need to create the user 'terraform' in your Bizzcloud portal which you will need in a later stage.
If this is done, you can proceed and click the button 'Download Terraform'.

If you have any questions, please contact support@clearmedia.be"

#Button functions:
$DwnTerraform.add_click({
$Folder = 'C:\ProgramData\chocolatey'
if (Test-Path -Path $Folder) {
     $Output.Text = "Chocolaty already installed"
} else {
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')) 
}
choco install imdisk-toolkit -y 
imdisk -a -s 512M -m X: -p "/fs:ntfs /v:RAMDISK /q /c /y" 
Start-Sleep -Seconds 2
mkdir X:\Terraform
Push-Location x:\Terraform | Out-Null
choco install terraform --version=0.13.5 -force -y | Out-Null
Move-Item -Path C:\ProgramData\chocolatey\lib\terraform\tools\terraform.exe -Destination X:\Terraform\ | Out-Null
Invoke-WebRequest -Uri https://github.com/cedriccarette/terraform/archive/refs/heads/main.zip -Outfile X:\Terraform\main.zip | Out-Null
Expand-Archive -LiteralPath x:\Terraform\main.zip -DestinationPath X:\Terraform\ | Out-Null
Move-Item -Path X:\Terraform\terraform-main\* -Destination X:\Terraform\ | Out-Null
Remove-Item -Path X:\Terraform\terraform-main -Recurse | Out-Null
Remove-Item -Path X:\Terraform\main.zip -Recurse | Out-Null
Start-Sleep -Seconds 2

$Log = 'C:\Windows\Logs\Terraform_log'
if (Test-Path -Path $Log) { 
} else {
    New-Item -path "C:\Windows\Logs\" -Name "Terraform_log" -ItemType "directory"
}
$progress.Value = 25
$Output.Text = "Terraform is ready to use... `nFill in the needed information."
$login.IsEnabled = $true
$Orgname.IsReadOnly = $false
$DwnTerraform.IsEnabled = $false
})

$login.add_click({ 
$progress.Value = 0
$OutputOrg = $Orgname.Text
$cred = Get-Credential
$cred.UserName | Out-File X:\Terraform\cred.txt
$cred.GetNetworkCredential().Password | Add-Content X:\Terraform\cred.txt
(Get-Item –Path X:\Terraform\cred.txt).Encrypt()
if (([string]::IsNullOrEmpty($OutputOrg)))
{
        $Output.Text = "Org name can't be empty"
        Return
 } else {
        $Org = $Orgname.Text
        # Connect to vCloudDirector
        [STRING]$CIServer = 'my.bizzcloud.be'
        Connect-CIServer -Server $CIServer -org $Org -Credential $cred -ErrorAction SilentlyContinue -ErrorVariable err
            if (([string]::IsNullOrEmpty($err)))
             {     
                $vapp.IsReadOnly = $false
                $vdcname = (Get-OrgVdc).Name
                $orgNet = (Get-OrgVdcNetwork).Name
                $progress.Value = 30
                $vdc = $vdcname | Foreach {$vdc.Items.Add($_)}
                $network = $orgNet | Foreach {$network.Items.Add($_)}
                $okButton.IsEnabled = $true
                $Output.Text = "Login succesful"
                $login.IsEnabled = $false
                $WindowsVersions = Get-CIVAppTemplate | Where-Object {$PSItem -like '*win20*' }
                $winver = $WindowsVersions | foreach {$winver.Items.Add($_)} 
                      
               }
           else 
               {
                $Output.Text = "Login Failed. Check username or password"
                Return
                }
        }
})

$okButton.add_click({
$progress.Value = 0 
$OutputOrg = $Orgname.Text
$Outputvapp = $vapp.Text
$OutputVDC = $vdc.Text
$OutputNet = $network.Text
$OutputPrefix = $prefix.Text
$OutputWinver = $winver.Text
$array = ""
$array = $OutputOrg,$Outputvapp,$OutputVDC
$progress.Value = 25
#Error handling check empty values
Foreach ($item in $array) {
 if ( [string]::IsNullOrEmpty($item)){
         $Output.Text = "Empty field(s)"
        Return
 } else {
        $Output.Text = "Generating the variable.tf file....."
        $progress.Value = 30
        }
}
$Orgname.IsReadOnly = $true
#Compile variable file
$OutputOrg = $Orgname.Text
$Outputvapp = $vapp.Text
$checkvapp = (Get-PIVApp).Name
ForEach($vapps in $checkvapp)
{
    if($Outputvapp -eq $vapps){
        $output.Text = "Vapp Already Exists"
        Return
    }    
}
(Get-Item –Path X:\Terraform\cred.txt).Decrypt()
$OutputTusr = (Get-Content -Path X:\Terraform\cred.txt)[0]
$OutputTpwd = (Get-Content -Path X:\Terraform\cred.txt)[-1]
$OutputVDC = $vdc.Text
$OutputNet = $network.Text
$OutputPrefix = $prefix.Text
$OutputWinver = $winver.Text
$original_file = 'X:\Terraform\Dummy.txt'
$destination_file =  'X:\Terraform\variables.tf'
(Get-Content $original_file) | Foreach-Object {
    $_ -replace 'obj1', $OutputOrg `
       -replace 'obj2', $OutputTusr `
       -replace 'obj3', $OutputTpwd `
       -replace 'obj4', $OutputVDC `
       -replace 'obj5', $Outputvapp `
       -replace 'obj6', $OutputNet `
       -replace 'obj7', $OutputPrefix `
       -replace 'obj8', $OutputWinver
    } | Set-Content $destination_file
$progress.Value = 40
Invoke-Expression -command "& .\terraform.exe version" | Out-File version.txt
Copy-Item "X:\Terraform\version.txt" "C:\Windows\Logs\terraform_log\versionCheck$(get-date -uformat %d-%m-%Y-%H.%M.%S).txt"
Invoke-Expression -command "& .\terraform.exe init" 
$progress.Value = 50      
Remove-Item -Path X:\Terraform\cred.txt -Recurse | Out-Null
Invoke-Expression -Command "& .\terraform.exe plan -out=X:\Terraform\output.plan -no-color" | Out-File plan.txt
Copy-Item "X:\Terraform\plan.txt" "C:\Windows\Logs\terraform_log\plan$(get-date -uformat %d-%m-%Y-%H.%M.%S).txt"
$Output.Text = Get-Content -Raw -LiteralPath X:\Terraform\plan.txt
$deploy.IsEnabled = $true
$okButton.IsEnabled = $false
$progress.Value = 75
})

$deploy.add_Click({
Invoke-Expression -Command "& .\terraform.exe apply X:\\Terraform\\output.plan" | Out-File apply.txt
Copy-Item "X:\Terraform\apply.txt" "C:\Windows\Logs\terraform_log\apply$(get-date -uformat %d-%m-%Y-%H.%M.%S).txt"
$Output.Text = Get-Content -Raw -LiteralPath X:\Terraform\apply.txt | select -Last 10
$progress.Value = 100
$deploy.IsEnabled = $false
})

#Show XMLform
$XMLForm.ShowDialog() | Out-Null
imdisk -D -m X: