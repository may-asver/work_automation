<#
    Script to get all cameras on Milestone Recording servers.

    Requirements: MilestonePSTools 22.3.0
    Ouput: Error message, Success message, verbose message.

    Author: Maya Aguirre
    Date: 06/08/2024
#>

# GLOBAL VARIABLES
$module_name = "MilestonePSTools"

# Set action preference to handle the errors in catch
$ErrorActionPreference = "Continue"



# Function to select the folder to save the file
function Select-FolderDialog
{
    Add-Type -AssemblyName System.Windows.Forms
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "Seleccione la carpeta donde desea guardar los CSV"
    $folderBrowser.ShowDialog() | Out-Null

    return $folderBrowser.SelectedPath
}



# Main process to get the list of cameras and save it on csv file
try
{
    # Validate if the version needed is installed
    $versions = Get-InstalledModule -Name $module_name -AllVersions
    if ($versions.Version[0] -notlike "22.*")
    {
        throw "La version del modulo no es compatible."
    }

    # Import minimum version installed
    Import-Module $module_name -RequiredVersion $versions.Version[0]
    
    # Select folder to save the file
    $folder_path = Select-FolderDialog

    # Get date
    $date = (Get-Date).ToString('dd-MM-yyyy')

    # List of servers with IP
    $servers = @(
        @{ Nombre = "SERVER1"; IP = "2.2.2.2" },
        @{ Nombre = "SERVER2"; IP = "1.1.1.3" }
        @{ Nombre = "SERVER3"; IP = "1.1.1.4" },
        @{ Nombre = "SERVER4"; IP = "1.1.1.5" }
    )
    # Get list of cameras of each server
    foreach ($server in $servers)
    {
        $serverName = $server.Nombre
        $serverIP = $server.IP

        # Create file and name
        $fileName = "$date-$($serverName)"
        $csvFile = Join-Path -Path $folder_path -ChildPath "$fileName.csv"
         
        # Connect to server
        Write-Output "$($serverName) $($serverIP)" # Message to know which server is
        Connect-ManagementServer $serverIP

        # Advise to user in which server is working
        Write-Output "Obteniendo la lista del servidor $($serverName)"
        
        # Get list of cameras
        Get-VmsCameraReport -IncludePlainTextPasswords | Export-csv -Path $csvFile -Encoding "Default"

        # Disconnect from server
        Disconnect-ManagementServer
    }
    # Advise to user that process is done
    Write-Output "Proceso finalizado"
}
catch
{
    # Manage errors
    Write-Output "Occurrio un error: $_"
    
    # Close session
    Disconnect-ManagementServer
}

# Set pause to read errors before close the main window
Read-Host -Prompt "Presione Enter para cerrar la ventana"