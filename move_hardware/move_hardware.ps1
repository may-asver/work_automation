<#
# Script to move a list of hardware to another recording server in Milestone server from a CSV file.
  Input: IP address of the server, CSV file with the list of hardware to move.
  Output: Message of success, error message.
  Requirements: PowerShell, MilestonePSTools module v23.2.3, CSV file

  Author: Maya Aguirre
  Date: 2024-03-04
#>

# Get input for IP address
$ip = Read-Host "Enter the Milestone server IP address"

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
        # Get file
        $csv = Import-Csv -Path $path -Delimiter "," -Encoding "UTF8"
        # Connect to the server
        Connect-ManagementServer $ip
        # Change the driver of each camera from the CSV file
        foreach ($row in $csv)
        {
            $camera = Get-Hardware -Name $row.HardwareName
            $server = Get-RecordingServer -Name $row.RecordingServer
            $storage = Get-VmsStorage -RecordingServer $server
            if ($null -eq $camera)
            {
                Write-Host "Camera" $row.HardwareName "not found"
                exit
            }
            Move-VmsHardware -Hardware $camera -SkipDriverCheck -DestinationRecorder $row.RecordingServer -DestinationStorage $storage
        }

        Write-Host "Done"
        # Disconnect from the server
        Disconnect-ManagementServer
    }
    catch
    {
        Write-Host "Error:" $error
        if ($error -match "ServerNotFound") {
            Write-Host "Server with IP '$ip' not exists or is unreachable."
        }
    }

} else {
    Write-Host "Invalid IP address"
}
