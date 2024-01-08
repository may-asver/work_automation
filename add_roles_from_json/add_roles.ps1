<# Script to add a list of roles exported from a Milestone Server in a .json file
  Input: IP address of the server to get roles, IP address of the server to create the roles.
  Output: Message of success
  Requirements: PowerShell, MilestonePSTools module v23.2.3
  It should be run with an user with Administrator privileges from the Milestone Server.
  Usage: ./add_roles.ps1

  Author: Maya Aguirre
  Date: 2024-01-08
#>


# Function to select folder to save .json file
function Select-Folder
{
    Add-Type -AssemblyName System.Windows.Forms

    # Create a folder browser dialog
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "Select a folder to save the JSON file"

    # Show the dialog and check if the user clicked OK
    if ($folderBrowser.ShowDialog() -eq 'OK')
    {
        # Get the selected folder path
        $selectedFolderPath = $folderBrowser.SelectedPath

        $jsonFilePath = Join-Path -Path $selectedFolderPath -ChildPath "exported_roles.json"

        return $jsonFilePath
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

    $ipRegex = '^(\d{1,3}\.){3}\d{1,3}$'

    if ( $IPAddress -match $ipRegex )
    {
        $octets = $IPAddress -split '\.'
        $isValid = $true

        foreach ( $octet in $octets )
        {
            if ( $octet -lt 0 -or $octet -gt 255 )
            {
                $isValid = $false
                break
            }
        }

        if ( $isValid )
        {
            Write-Host "$IPAddress is a valid IP address."
            return $true
        }
    }

    Write-Host "$IPAddress is NOT a valid IP address."
    return $false
}

try
{
    # Get input for IP address server to export roles from
    $ip_export = Read-Host "IP del servidor para exportar roles: "
    $ip_import = Read-Host "IP del servidor para importar roles: "
    #  Check if the input is a valid IP address with a single IF statement
    if ( Test-IPAddress $ip_export -and Test-IPAddress $ip_import )
    {
        # Call the function to select folder to save .json file
        $path = Select-Folder
        # Connect to the Milestone Server to export roles
        Connect-ManagementServer -IPAddress $ip_export
        # Call the function to export roles from the Milestone Server
        Export-VmsRole -Path $path
        # Disconnect from the Milestone Server
        Disconnect-ManagementServer

    }
}
catch
{
    Write-Host "An error occurred."
}
