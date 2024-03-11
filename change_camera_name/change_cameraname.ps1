<# Script to change the camera name of cameras from a CSV file.
#  Input: IP address of the server
#  Output: Message of success, Error message
#  Requirements: PowerShell, MilestonePSTools module v23.2.3
#  Author: Maya Aguirre
#  Date: 2024-03-11
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
        $csv = Import-Csv -Path $path -Delimiter "," -Encoding "UTF8"
        # Connect to the server
        Write-Host "Connecting to server" $ip
        Connect-ManagementServer $ip
        # Change the name of each camera from the CSV file
        foreach ($row in $csv)
        {
            $camera = Get-VmsCamera -Name $row.CameraName
            if ($null -eq $camera)
            {
                Write-Host "Camera" $row.CameraName "not found"
                exit
            }
            Write-Host "Changing camera name of camera" $camera.CameraName "to" $row.NewCameraName
            Set-VmsCamera -Camera $camera -Name $row.NewCameraName -EV error
        }
        Write-Host "Done"
        # Disconnect from the server
        Disconnect-ManagementServer
    }
    catch
    {
        Write-Host 'Error: $error'
    }

} else {
    Write-Host "Invalid IP address"
}
