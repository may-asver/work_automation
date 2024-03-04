<#
# Script to change driver to a list of cameras in a recording server in Milestone from a CSV file.
  Input: IP address of the server, CSV file with the list of cameras to add and recording server name.
  Output: Message of success, error message.
  Requirements: PowerShell, MilestonePSTools module v23.2.3, CSV file

  Author: Maya Aguirre
  Date: 2024-03-04
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
        $driverID = Read-Host "Enter the driver ID"
        # Import the CSV file
        Write-Host "Select the CSV file"
        $path = Invoke-Command -ScriptBlock ${function:Select-File}
        if ($null -eq $path)
        {
            Write-Host "No file selected"
            exit
        }
        # Get file
        $csv = Import-Csv -Path $path -Delimiter "," -Encoding "UTF8"
        # Connect to the server
        Write-Host "Connecting to server" $ip
        Connect-ManagementServer $ip
        # Change the driver of each camera from the CSV file
        foreach ($row in $csv)
        {
            $camera = Get-Hardware -Name $row.HardwareName
            if ($null -eq $camera)
            {
                Write-Host "Camera" $row.HardwareName "not found"
                exit
            }
            Write-Host "Changing driver name of camera '$camera.Name'"
            Set-VmsHardwareDriver -Driver $driverID
        }

        Write-Host "Done"
        # Disconnect from the server
        Disconnect-ManagementServer
    }
    catch
    {
        Write-Host "Error:" $error
        if ($error -match "ServerNotFound") {
            Write-Host "Server with IP '$ip' not exists"
        }
    }

} else {
    Write-Host "Invalid IP address"
}
