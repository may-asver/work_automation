<# Script to change the hardware and camera name of cameras from a CSV file.
#  Input: CSV file
#  Output: Message of success
#  Requirements: PowerShell, MilestonePSTools module v23.2.3
#  Author: Maya Aguirre
#  Date: 2024-04-19
#>


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

    # Change the name of each camera from the CSV file
    foreach ($row in $csv)
    {
        # Connect to the server
        Connect-ManagementServer $row.ServerIP
        $hardware = Get-Hardware -Name $row.HardwareName
        if ($null -eq $hardware)
        {
            Write-Host "Camera $row.HardwareName not found"
            exit
        }
        Write-Host "Changing name of camera $hardware.HardwareName"
        $camera = Get-VmsCamera -Hardware $hardware
        Set-VmsHardware -Hardware $hardware -Name $row.NewHardwareName
        Set-VmsCamera -Camera $camera -Name $row.NewCameraName
        # Disconnect from the server
        Disconnect-ManagementServer
    }
    Write-Host "Done"

}
catch
{
    Write-Host "Error:" $error
}

