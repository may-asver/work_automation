<#
# Script to add a list of cameras to a recording server in Milestone from a CSV file.
  Input: IP address of the server, CSV file with the list of cameras to add and recording server name.
  Output: Message of success
  Requirements: PowerShell, MilestonePSTools module v23.2.3, CSV file

  Author: Maya Aguirre
  Date: 2023-12-14
#>

# Get input for IP address
$ip = Read-Host "Enter the server IP address"

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

# Validate IP address
if ($ip -match '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$')
{
    try
    {
        # Import the CSV file
        Write-Host "Select the CSV file"
        $path = Invoke-Command -ScriptBlock ${function:Select-File}
        if ($null -eq $path)
        {
            Write-Host "No file selected"
            exit
        }
        # Connect to the server
        Write-Host "Connecting to server" $ip
        Connect-ManagementServer $ip
        # Add the cameras to the recording server
        Import-VmsHardware -Path $path
        Write-Host "Done"
        # Disconnect from the server
        Disconnect-ManagementServer
    }
    catch
    {
        $errorMessage = $_.Exception.Message
        if ($errorMessage -match "ServerNotFound") {
            Write-Error -Message "Server with IP $ip not exists or server unreachable"
        }
        elif ($errorMessage -match "The hardware is already defined") {
            Write-Error -Message "Some Hardware already exists. Verify the list."
        }
        else {
            Write-Error -Message "Error during the process: $errorMessage"
        }
    }

} else {
    Write-Host "Invalid IP address"
}

Read-Host -Prompt "Presiona Enter para salir"