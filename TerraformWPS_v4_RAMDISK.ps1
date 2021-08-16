#Load Assembly and Library
Add-Type -AssemblyName PresentationFramework

$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

#XAML form designed using Vistual Studio
[xml]$Form = @"
<Window 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="Terraform made easy by Clearmedia" Height="800  " Width="800">
    <Grid>
        <Button Name="BTNdwnTerraform" Content="Download Terraform" HorizontalAlignment="Left" Margin="10,42,0,0" VerticalAlignment="Top" Width="157" Height="20"/>
        <Button Name="BTNdwnNotepad" Content="Download Notepad++" HorizontalAlignment="Left" Margin="10,85,0,0" VerticalAlignment="Top" Width="157" Height="20"/>
        <GroupBox Name="Header" Header="First steps:" Margin="0,10,604,645"/>
        <ProgressBar Name="ProgressBar" HorizontalAlignment="Center" Height="19" Margin="0,739,0,0" VerticalAlignment="Top" Width="780"/>
        <TextBox Name="txtOrgname" HorizontalAlignment="Left" Margin="221,49,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="120" Height="18"/>
        <Label Name="lblOrgname" Content="Provide Org name:" HorizontalAlignment="Left" Margin="216,22,0,0" VerticalAlignment="Top"/>
        <TextBlock Name="textblock" HorizontalAlignment="Left" Margin="523,29,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Height="241" Width="243" FontSize="20"><Run Text="Before "/><Run Language="nl-be" Text="providing the needed information"/><LineBreak/><Run Language="nl-be" Text="make sure you have logged in to the vCloud Director to verify the information!!"/><LineBreak/><Run Language="nl-be"/><LineBreak/><Run Language="nl-be"/></TextBlock>
        <Label Name="lblClientname" Content="Enter client name:" HorizontalAlignment="Left" Margin="216,72,0,0" VerticalAlignment="Top" Height="24"/>
        <TextBox Name="txtClientname" HorizontalAlignment="Left" Margin="221,104,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="120"/>
        <Label Name="lblTerraformuser" Content="Terraform user name:" HorizontalAlignment="Left" Margin="216,126,0,0" VerticalAlignment="Top"/>
        <TextBox Name="txtTerraformusr" HorizontalAlignment="Left" Margin="221,157,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="120"/>
        <Label Name="lblTerrPass" Content="Terraform password:" HorizontalAlignment="Left" Margin="216,180,0,0" VerticalAlignment="Top"/>
        <PasswordBox Name="txtTerrPass" HorizontalAlignment="Left" Margin="221,208,0,0" VerticalAlignment="Top" Width="120"/>
        <ScrollViewer VerticalScrollBarVisibility="Auto" Margin="2,250,0,0" Height="380" Width="780"  HorizontalScrollBarVisibility="Disabled">
        <TextBlock Name="txtOutput" Background="#FF0800AE" Foreground="#FFF5EA04"/>
        </ScrollViewer>
        <Label Name="lblVDC" Content="Enter vDC name:" HorizontalAlignment="Left" Margin="216,229,0,0" VerticalAlignment="Top"/>
        <TextBox Name="txtVDC" HorizontalAlignment="Left" Margin="221,261,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="120"/>
        <Button Name="BTNok" Content="OK" HorizontalAlignment="Left" Margin="379,259,0,0" VerticalAlignment="Top" Width="96"/>
        <Button Name="BTNgenerate" Content="Generate!" HorizontalAlignment="Left" Margin="31,185,0,0" VerticalAlignment="Top" Height="63" Width="115" Background="#FF31E614" IsEnabled="False"/>
        <Label Name="lblOptional" Content="Optional:" HorizontalAlignment="Left" Margin="10,64,0,0" VerticalAlignment="Top"/>
        <Button Name="BTNcheckVer" Content="Check version" HorizontalAlignment="Left" Margin="184,710,0,0" VerticalAlignment="Top" IsEnabled="False"/>
        <Button Name="BTNplugin" Content="Download plugin" HorizontalAlignment="Left" Margin="282,710,0,0" VerticalAlignment="Top" IsEnabled="False"/>
        <Button Name="BTNplan" Content="Terraform plan" HorizontalAlignment="Left" Margin="396,710,0,0" VerticalAlignment="Top" IsEnabled="False"/>
        <Button Name="BTNdeploy" Content="DEPLOY !" HorizontalAlignment="Left" Margin="497,710,0,0" VerticalAlignment="Top" IsEnabled="False"/>
    </Grid>
</Window>
"@

#Create a form
$XMLReader = (New-Object System.Xml.XmlNodeReader $Form)
$XMLForm = [Windows.Markup.XamlReader]::Load($XMLReader)

#Load buttons
$DwnNotepad = $XMLForm.FindName('BTNdwnNotepad')
$DwnTerraform = $XMLForm.FindName('BTNdwnTerraform')
$okButton = $XMLForm.FindName('BTNok')
$generate = $XMLForm.FindName('BTNgenerate')
$vercheck = $XMLForm.FindName('BTNcheckVer')
$plugin = $XMLForm.FindName('BTNplugin')
$plan = $XMLForm.FindName('BTNplan')
$deploy = $XMLForm.FindName('BTNdeploy')

#Load textbox
$Orgname = $XMLForm.FindName('txtOrgname')
$ClientName = $XMLForm.FindName('txtClientname')
$TerraformUser = $XMLForm.FindName('txtTerraformusr')
$TerraformPass = $XMLForm.FindName('txtTerrPass')
$vdc = $XMLForm.FindName('txtVDC')
$Output = $XMLForm.FindName('txtOutput')

#$DocumentsLocation = [Environment]::GetFolderPath("MyDocuments")

#Clear textbox
[string]$Orgname.Text = ""
[string]$ClientName.Text = ""
[string]$TerraformUser.Text = ""
[string]$TerraformPass.Password = ""
[string]$vdc.Text = ""

#Create array object for Result DataGrid
$RestartEventList = New-Object System.Collections.ArrayList

#Create Terraform log folder
$log = 'C:\terraform_log'
if (Test-Path -Path $log) {
     $Output.Text = "Terraform log folder already exists `n C:\terraform_log"
} else {
    mkdir c:\terraform_log
    $Output.Text = "Terraform log folder created `n C:\terraform_log"
}

#Button Action
$DwnTerraform.add_click({


#check if Chocolatey is installed
$Folder = 'C:\ProgramData\chocolatey'
if (Test-Path -Path $Folder) {
     Write-Host "Chocolaty already installed"
} else {
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')) 
}
$temp = $Env:temp
mkdir $temp\Terraform | Out-Null
#cmd install Imdisk + create temp RAMDRIVE
$DownloadFiles = Invoke-WebRequest -Uri https://github.com/cedriccarette/terraform/archive/refs/heads/main.zip -Outfile $temp\Terraform\main.zip | Out-Null
Expand-Archive -LiteralPath $temp\Terraform\main.zip -DestinationPath $temp\Terraform\ | Out-Null
Move-Item -Path $temp\Terraform\terraform-main\* -Destination $temp\Terraform\ | Out-Null
start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "/k","$temp\Terraform\InstallImdisk.cmd" -Verb RunAs -Wait | Out-Null
start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "/k","$temp\Terraform\createRAMDISK.cmd" -Verb RunAs -Wait | Out-Null
Start-Sleep -Seconds 2

$DocumentsLocation = X:
mkdir $DocumentsLocation\Terraform | Out-Null 
Move-Item -Path $temp\Terraform\* -Destination $DocumentsLocation\Terraform | Out-Null
Remove-Item $temp\Terraform -Recurse | Out-Null

#Sync Github + remove .zip
$DownloadTerraform = Invoke-WebRequest -Uri https://releases.hashicorp.com/terraform/0.13.5/terraform_0.13.5_windows_amd64.zip -Outfile $DocumentsLocation\Terraform\Terraform.zip
Expand-Archive -LiteralPath $DocumentsLocation\Terraform\Terraform.zip -DestinationPath $DocumentsLocation\Terraform\ | Out-Null
Remove-Item $DocumentsLocation\Terraform\Terraform.zip | Out-Null
Remove-Item $DocumentsLocation\Terraform\terraform-main -Recurse | Out-Null
Remove-Item $DownloadTerraform\Terraform\main.zip | Out-Null
$Output.Text = "Download Terraform complete" 
})

$DwnNotepad.add_click({
$Output.Text = "Download Notepad++ complete"
$DocumentsLocation = [Environment]::GetFolderPath("MyDocuments")
mkdir $DocumentsLocation\Notepad++
$DownloadNotepad = Invoke-WebRequest https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.1.2/npp.8.1.2.Installer.exe -OutFile $DocumentsLocation\Notepad++\notepad.exe
Invoke-Item $DocumentsLocation\Notepad++\notepad.exe
})

$okButton.add_click({

$OutputOrg = $Orgname.Text
$OutputClt = $ClientName.Text
$OutputTusr = $TerraformUser.Text
$OutputTpwd = $TerraformPass.Password
$OutputVDC = $vdc.Text


$array = ""
$array = $OutputOrg,$OutputClt,$OutputTusr,$OutputTpwd,$OutputVDC  

#Error handling check empty values
Foreach ($item in $array) {
 if ( [string]::IsNullOrEmpty($item)){
         $Output.Text = "Empty field(s)"
         $generate.IsEnabled = $false
        Return
 } else {
        $Output.Text = "Great Job, now generate the variable.tf file."
        $generate.IsEnabled = $true
        }
}
})

$generate.add_Click({

$OutputOrg = $Orgname.Text
$OutputClt = $ClientName.Text
$OutputTusr = $TerraformUser.Text
$OutputTpwd = $TerraformPass.Password
$OutputVDC = $vdc.Text 

$original_file = 'X:Terraform\Dummy.txt'
$destination_file =  'X:Terraform\variables.tf'
(Get-Content $original_file) | Foreach-Object {
    $_ -replace 'obj1', $OutputOrg `
       -replace 'obj2', $OutputTusr `
       -replace 'obj3', $OutputTpwd `
       -replace 'obj5', $OutputClt `
       -replace 'obj4', $OutputVDC `
    } | Set-Content $destination_file

#$filevariable | Out-File X:\Terraform\variables.tf -Encoding utf8
$Output.Text = $destination_file
$vercheck.IsEnabled = $true
})

$vercheck.add_Click({
start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "/k","$DocumentsLocation\Terraform\version.cmd" -Verb RunAs -Wait | Out-Null
$getversion = Get-Content $temp\Terraform\versioncheck.txt -First 1 
Copy-Item "X:\Terraform\versioncheck.txt" "C:\terraform_log\versionCheck$(get-date -uformat %d-%m-%Y-%H.%M.%S).txt"
$Output.Text = $getversion
$plugin.IsEnabled = $true
})

$plugin.add_Click({
start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "/k","$DocumentsLocation\Terraform\init.cmd" -Verb RunAs -Wait | Out-Null
$Output.Text = "Terraform provider plugin has been downloaded `nTerraform state file is created"
#Check if files are created
$state = 'X:\Terraform\terraform.tfstate'
if (Test-Path -Path $state) {
     $Output.Text =  "All good, please continue"
     $plan.IsEnabled = $true
} else {
    $Output.Text = "Something went wrong. Please check the log files or configuration"
        }
})

$plan.add_Click({
start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "/k","$temp\Terraform\plan.cmd" -Verb RunAs -Wait | Out-Null
Copy-Item "X:\Terraform\plan.txt" "C:\terraform_log\plan$(get-date -uformat %d-%m-%Y-%H.%M.%S).txt"
})

#Show XMLform
$XMLForm.ShowDialog() | Out-Null
imdisk -D -m X: