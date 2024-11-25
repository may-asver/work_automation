<# Script to change the hardware and camera name of cameras from a CSV file.
#
#  Input: CSV file
#  Output: Message of success
#  Requirements: PowerShell, MilestonePSTools module v23.2.3
#  Author: Maya Aguirre
#  Date: 2024-04-19
#>

# Set action preference to handle the errors in catch
$ErrorActionPreference = "Stop"

# Function to validate if MilestonePSTools module is installed
function Validate-Tools
{
    if ($null -eq (Get-Module -Name 'MilestonePSTools'))
    {
        return $null
    }
    else
    {
        Import-Module -Name 'MilestonePSTools'
        return 'installed'
    }
}

# Function to install MilestonPSTools
function Install-MilestoneModule
{
    Write-Host 'Setting SecurityProtocol to TLS 1.2 and greater' -ForegroundColor Green
    $protocol = [Net.SecurityProtocolType]::SystemDefault
    [enum]::GetNames([Net.SecurityProtocolType]) | Where-Object {
        # Match any TLS version greater than 1.1
                ($_ -match 'Tls(\d)(\d+)?') -and ([version]("$($Matches[1]).$([int]$Matches[2])")) -gt 1.1
    } | Foreach-Object { $protocol = $protocol -bor [Net.SecurityProtocolType]::$_ }
    [Net.ServicePointManager]::SecurityProtocol = $protocol

    if ($null -eq (Get-PackageSource -Name NuGet -ErrorAction Ignore)) {
        Write-Host 'Registering NuGet package source' -ForegroundColor Green
        $null = Register-PackageSource -Name NuGet -Location https://www.nuget.org/api/v2 -ProviderName NuGet -Trusted -Force
    }

    $nugetProvider = Get-PackageProvider -Name NuGet -ErrorAction Ignore
    $requiredVersion = [Microsoft.PackageManagement.Internal.Utility.Versions.FourPartVersion]::Parse('2.8.5.201')
    if ($null -eq $nugetProvider -or $nugetProvider.Version -lt $requiredVersion) {
        Write-Host 'Installing NuGet package provider' -ForegroundColor Green
        $null = Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    }

    if ($null -eq (Get-Module -ListAvailable PowerShellGet | Where-Object Version -ge 2.2.5)) {
        Write-Host 'Installing PowerShellGet 2.2.5 or greater' -ForegroundColor Green
        $null = Install-Module PowerShellGet -MinimumVersion 2.2.5 -Scope CurrentUser -AllowClobber -Force -ErrorAction Stop
    }

    Write-Host 'Installing MilestonePSTools' -ForegroundColor Green
    Install-Module MilestonePSTools -RequiredVersion 23.3.1 -Scope CurrentUser -Force -ErrorAction Stop -SkipPublisherCheck -AllowClobber
    Import-Module 'MilestonePSTools'
}

# Function that opens a file dialog to select a CSV file
function Select-File
{
    # Load the Windows Forms assembly
    Add-Type -AssemblyName System.Windows.Forms

    # Create OpenFileDialog object
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Title = "Select a file"
    $openFileDialog.Filter = "CSV files (*.csv)|*.csv|All Files (*.*)|*.*"

    # Show the dialog and check if the user clicked OK
    if ($openFileDialog.ShowDialog() -eq 'OK')
    {
        # Get the selected file's path
        $selectedFilePath = $openFileDialog.FileName
        return $selectedFilePath
    }
    return $null
}

# Main processes to change hardware name and camera name
try
{
    # Validate if MilestonePSTools module is installed
    if ($null -eq (Validate-Tools))
    {
        Install-MilestoneModule
    }
    # Import the CSV file
    Write-Host "Select the CSV file"
    $path = Select-File
    if ($null -eq $path) # Validate if value is null
    {
        Write-Error "No se ha seleccionado un archivo"
    }
    $csv = Import-Csv -Path $path -Delimiter "," -Encoding "Default"

    # Get the file number line where is running
    $number_line = 1

    # Change the name of each camera from the CSV file
    foreach ($row in $csv)
    {
        # Sum 1 to number line
        $number_line ++
        # Validate that parameters are not null
        if ('' -eq $row.HardwareName -or '' -eq $row.CameraName -or '' -eq $row.NewHardwareName -or '' -eq $row.NewCameraName -or '' -eq $row.ServerIP)
        {
            Write-Error "Alguno o todos los valores de la linea $number_line en el archivo estan vacios"
        }
        else
        {
            # Connect to the server
            Connect-ManagementServer $row.ServerIP
            $hardware = Get-Hardware -Name $row.HardwareName
            # Change camera and hardware name
            Write-Host "Changing name of camera $($hardware.HardwareName)" # Displays a message to user
            $camera = Get-VmsCamera -Hardware $hardware # Get camera using hardware parameter
            Set-VmsHardware -Hardware $hardware -Name $row.NewHardwareName # Change Hardware name
            Set-VmsCamera -Camera $camera -Name $row.NewCameraName # Change camera name
            # Disconnect from the server
            Disconnect-ManagementServer
        }
    }
    Write-Host "Done"
}
catch
{
    if ($_ -match "Modulo de Milestone no instalado")
    {

    }
    else
    {
        Write-Output "Ocurrio un error: $_"
    }
}

# Set pause to read errors before close the main window
Read-Host -Prompt "Presione Enter para cerrar la ventana"
