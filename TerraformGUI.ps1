#Load Assembly and Library
Add-Type -AssemblyName PresentationFramework

[xml]$Form = @"
<Window 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="Terraform made easy by ClearMedia" Height="800  " Width="800">
    <Grid>
        <Button Name="BTNdwnTerraform" Content="Download Terraform" HorizontalAlignment="Left" Margin="10,42,0,0" VerticalAlignment="Top" Width="157" Height="20"/>
        <GroupBox Name="Header" Header="First step:" Margin="0,10,604,645"/>
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
        <TextBox Name="txtOutput" Text="{Binding Text, Mode=OneWay}" TextWrapping="Wrap" IsReadOnly="True" AcceptsReturn="True" Background="#FF0800AE" Foreground="#FFF5EA04"/>
        </ScrollViewer>
        <Label Name="lblVDC" Content="Enter vDC name:" HorizontalAlignment="Left" Margin="216,229,0,0" VerticalAlignment="Top"/>
        <TextBox Name="txtVDC" HorizontalAlignment="Left" Margin="221,261,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="120"/>
        <Button Name="BTNok" Content="OK" HorizontalAlignment="Left" Margin="379,259,0,0" VerticalAlignment="Top" Width="96"/>
        <Button Name="BTNgenerate" Content="Generate!" HorizontalAlignment="Left" Margin="31,185,0,0" VerticalAlignment="Top" Height="63" Width="115" Background="#FF31E614" IsEnabled="False"/>
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
$DwnTerraform = $XMLForm.FindName('BTNdwnTerraform')
$okButton = $XMLForm.FindName('BTNok')
$generate = $XMLForm.FindName('BTNgenerate')
$vercheck = $XMLForm.FindName('BTNcheckVer')
$plugin = $XMLForm.FindName('BTNplugin')
$plan = $XMLForm.FindName('BTNplan')
$deploy = $XMLForm.FindName('BTNdeploy')
$okButton.IsEnabled = $false

#Load textbox
$Orgname = $XMLForm.FindName('txtOrgname')
$ClientName = $XMLForm.FindName('txtClientname')
$TerraformUser = $XMLForm.FindName('txtTerraformusr')
$TerraformPass = $XMLForm.FindName('txtTerrPass')
$vdc = $XMLForm.FindName('txtVDC')
$Output = $XMLForm.FindName('txtOutput')

#Load progressbar
$progress = $XMLForm.FindName('ProgressBar')
$progress.Minimum = 0
$progress.Maximum = 100
$progress.Value =0

#Clear textbox
[string]$Orgname.Text = ""
[string]$ClientName.Text = ""
[string]$TerraformUser.Text = ""
[string]$TerraformPass.Password = ""
[string]$vdc.Text = ""
$Orgname.IsReadOnly = $true
$ClientName.IsReadOnly = $true
$TerraformUser.IsReadOnly = $true
$TerraformPass.IsReadOnly = $true
$vdc.IsReadOnly = $true

#Create array object for Result DataGrid
$RestartEventList = New-Object System.Collections.ArrayList

#Create Terraform log folder
$log = 'C:\terraform_log'
if (Test-Path -Path $log) {
     $Output.Text = "Terraform log folder already exists `nC:\terraform_log"
} else {
    mkdir c:\terraform_log
    $Output.Text = "Terraform log folder created `nC:\terraform_log"
}

#Button Action
$DwnTerraform.add_click({
$Output.Text = "Downloading Terraform..."
#check if Chocolatey is installed
$Folder = 'C:\ProgramData\chocolatey'
if (Test-Path -Path $Folder) {
     $Output.Text = "Chocolaty already installed"
} else {
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')) 
}

#install imdisk + create ramdisk
choco install imdisk-toolkit -y
imdisk -a -s 512M -m X: -p "/fs:ntfs /v:RAMDISK /q /c /y" 
Start-Sleep -Seconds 2
#Change location
mkdir X:\Terraform
choco install terraform --version=0.13.5 -force -y | Out-Null
Move-Item -Path C:\ProgramData\chocolatey\lib\terraform\tools\terraform.exe -Destination X:\Terraform\ | Out-Null
Invoke-WebRequest -Uri https://github.com/cedriccarette/terraform/archive/refs/heads/main.zip -Outfile X:\Terraform\main.zip | Out-Null
Expand-Archive -LiteralPath x:\Terraform\main.zip -DestinationPath X:\Terraform\ | Out-Null
Move-Item -Path X:\Terraform\terraform-main\* -Destination X:\Terraform\ | Out-Null
Remove-Item -Path X:\Terraform\terraform-main -Recurse
Remove-Item -Path X:\Terraform\main.zip -Recurse
Start-Sleep -Seconds 2
Push-Location x:\Terraform
$progress.Value = 25
$Output.Text = "Terraform is ready to use... `nFill in the needed information. `nPlease verify everything in the Bizzcloud portal!!!"

$Orgname.IsReadOnly = $false
$ClientName.IsReadOnly = $false
$TerraformUser.IsReadOnly = $false
$TerraformPass.IsReadOnly = $false
$vdc.IsReadOnly = $false
$okButton.IsEnabled = $true
})

$okButton.add_click({
$progress.Value = 0 
$OutputOrg = $Orgname.Text
$OutputClt = $ClientName.Text
$OutputTusr = $TerraformUser.Text
$OutputTpwd = $TerraformPass.Password
$OutputVDC = $vdc.Text
$array = ""
$array = $OutputOrg,$OutputClt,$OutputTusr,$OutputTpwd,$OutputVDC  
$progress.Value = 25
#Error handling check empty values
Foreach ($item in $array) {
 if ( [string]::IsNullOrEmpty($item)){
         $Output.Text = "Empty field(s)"
         $generate.IsEnabled = $false
        Return
 } else {
        $Output.Text = "Great Job, now generate the variable.tf file."
        $generate.IsEnabled = $true
        $progress.Value = 30
        }
}
$Orgname.IsReadOnly = $true
$ClientName.IsReadOnly = $true
$TerraformUser.IsReadOnly = $true
$TerraformPass.IsReadOnly = $true
$vdc.IsReadOnly = $true
})

$generate.add_Click({

$OutputOrg = $Orgname.Text
$OutputClt = $ClientName.Text
$OutputTusr = $TerraformUser.Text
$OutputTpwd = $TerraformPass.Password
$OutputVDC = $vdc.Text 

$original_file = 'X:\Terraform\Dummy.txt'
$destination_file =  'X:\Terraform\variables.tf'
(Get-Content $original_file) | Foreach-Object {
    $_ -replace 'obj1', $OutputOrg `
       -replace 'obj2', $OutputTusr `
       -replace 'obj3', $OutputTpwd `
       -replace 'obj5', $OutputClt `
       -replace 'obj4', $OutputVDC `
    } | Set-Content $destination_file
$Output.Text = "Variable.tf file has been created. `nPlease continue and download the plugin..."
$plugin.IsEnabled = $true
$progress.Value = 40
})

$plugin.add_Click({
Invoke-Expression -command "& .\terraform.exe version" | Out-File version.txt
Copy-Item "X:\Terraform\version.txt" "C:\terraform_log\versionCheck$(get-date -uformat %d-%m-%Y-%H.%M.%S).txt"
Invoke-Expression -command "& .\terraform.exe init" 
$Output.Text = "Terraform provider plugin has been downloaded `nTerraform state file is created"
#Check if files are created
$state = 'X:\Terraform\terraform.tfstate'
if (Test-Path $state) {
    if((Get-Item $state).Length -lt 2kb) {
    $Output.Text = "Something went wrong. Please check the log files or configuration"
     }
} else {
     $Output.Text =  "Plugin succesfuly downloaded. `nPlease continue with the next step."
     $plan.IsEnabled = $true
     $progress.Value = 50 
        }
})

$plan.add_Click({
Invoke-Expression -Command "& .\terraform.exe plan -out=X:\Terraform\output.plan -no-color" | Tee-Object plan.txt
Copy-Item "X:\Terraform\plan.txt" "C:\terraform_log\plan$(get-date -uformat %d-%m-%Y-%H.%M.%S).txt"
$Output.Text = Get-Content -Raw -LiteralPath X:\Terraform\plan.txt
$deploy.IsEnabled = $true
$progress.Value = 75
})

$deploy.add_Click({
Invoke-Expression -Command "& .\terraform.exe apply X:\\Terraform\\output.plan" | Tee-Object apply.txt
Copy-Item "X:\Terraform\apply.txt" "C:\terraform_log\apply$(get-date -uformat %d-%m-%Y-%H.%M.%S).txt"
$Output.Text = Get-Content -Raw -LiteralPath X:\Terraform\apply.txt | select -Last 10
$progress.Value = 100
})

#Show XMLform
$XMLForm.ShowDialog() | Out-Null
imdisk -D -m X: