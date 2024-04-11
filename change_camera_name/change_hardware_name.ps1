<# Script to change the hardware name of cameras from a CSV file.
#  Input: IP address of the server
#  Output: Message of success
#  Requirements: PowerShell, MilestonePSTools module v23.2.3
#  Author: Maya Aguirre
#  Date: 2023-11-23
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
            $camera = Get-Hardware -Name $row.HardwareName
            if ($null -eq $camera)
            {
                Write-Host "Camera" $row.HardwareName "not found"
                exit
            }
            Write-Host "Changing hardware name of camera" $camera.HardwareName "to" $row.NewHardwareName
            Set-VmsHardware -Hardware $camera -Name $row.NewHardwareName
        }
        Write-Host "Done"
        # Disconnect from the server
        Disconnect-ManagementServer
    }
    catch
    {
        Write-Host "Error:" $error
    }

} else {
    Write-Host "Invalid IP address"
}

