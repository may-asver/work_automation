<# Script to import roles to a Milestone Server from a .json file
  Input: IP address of the server to get roles, IP address of the server to create the roles.
  Output: Message of success
  Requirements: PowerShell, MilestonePSTools module v23.2.3

  It should be run with an user with Administrator privileges into the Milestone Server where you want to import
  the roles.

  Usage: ./add_roles.ps1

  Author: Maya Aguirre
  Date: 2024-01-08
#>


# Function to select folder to save .json file
function Select-Folder
{
    param (
        [string] $Section
    )

    Add-Type -AssemblyName System.Windows.Forms
    # Create a folder browser dialog
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    switch ( $Section )
    {
        roles {
            $folderBrowser.Description = "Select a folder to save the JSON file for roles"

        }
        vmsprofiles {
            $folderBrowser.Description = "Select a folder to save the JSON file for profiles"

        }
        default {
            $folderBrowser.Description = "Select a folder to save the JSON file"

        }
    }
    # Show the dialog and check if the user clicked OK
    if ( $folderBrowser.ShowDialog( ) -eq 'OK' )
    {
        # Get the selected folder path
        $selectedFolderPath = $folderBrowser.SelectedPath
        switch ( $Section )
        {
            roles {
                $jsonFilePath = Join-Path -Path $selectedFolderPath -ChildPath "exported_roles.json"
                return $jsonFilePath
            }
            vmsprofiles {
                $jsonFilePath = Join-Path -Path $selectedFolderPath -ChildPath "exported_vmsprofiles.json"
                return $jsonFilePath
            }
            Default {
                $jsonFilePath = Join-Path -Path $selectedFolderPath -ChildPath "exported_info.json"
                return $jsonFilePath
            }
        }

    }
    else
    {
        Write-Host "No folder selected."
    }
}

# Function to validate IP Address
function Test-IPAddress
{
    param (
        [ string ]$IPAddress
    )

    $ipRegex = '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$'

    if ( $IPAddress -match $ipRegex )
    {
         return $true
    }

    return $false
}

try
{
    # Get input for IP address server to export roles from
    $ip_export = Read-Host "IP del servidor para exportar roles"
    $ip_import = Read-Host "IP del servidor para importar roles"
    #  Check if the input is a valid IP address
    if ( ({Test-IPAddress $ip_export}) -and ({Test-IPAddress $ip_import}) )
    {
        # Call the function to select folder to save .json files
        $path_roles = Select-Folder "roles"
        $path_profiles = Select-Folder "vmsprofiles"
        # Connect to the Milestone Server to export roles
        Connect-ManagementServer $ip_export
        # Call the function to export roles from the Milestone Server
        Export-VmsRole -Path $path_roles
        # Export vms profiles
        Export-VmsClientProfile -Path $path_profiles
        # Disconnect from the Milestone Server
        Disconnect-ManagementServer
        # Import roles from the .json file to the Milestone Server
        Connect-ManagementServer $ip_import
        Import-VmsClientProfile -Path $path_profiles -Force # Import profiles
        Import-VmsRole -Path $path_roles -Force # Import roles

        # Disconnect from the Milestone Server
        Disconnect-ManagementServer
    }
}
catch
{
    Write-Host "An error occurred. $_"
}
