<#
# Script to add a list of cameras to a recording server in Milestone from a CSV file.
  Input: IP address of the server, CSV file with the list of cameras to add.
  Output: Message of success
  Requirements: PowerShell, MilestonePSTools module v23.2.3, CSV file

  Author: Maya Aguirre
  Date: 2023-12-14
#>

# Set action preference to handle the errors in catch
$ErrorActionPreference = "Stop"

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
        $path = Select-File
        if ($null -eq $path)
        {
            Write-Error "No file selected"
        }
        # Connect to the server
        Write-Host "Connecting to server" $ip
        Connect-ManagementServer $ip
        # Validate that required parameters are not empty
        $csv = Import-Csv -Path $path -Delimiter "," -Encoding "Default"
        $number_line = 1
        foreach ($row in $csv)
        {
            $number_line ++
            if ($row.Address -eq "" -or $row.UserName -eq "" -or $row.Password -eq "" -or $row.RecordingServer -eq "")
            {
                Write-Error "Alguno de los parametros requeridos esta vacio en la linea $number_line"
            }
        }
        # Add the cameras to the recording server
        Import-VmsHardware -Path $path
        # Advise to user that process has finished
        Write-Host "Done"
        # Disconnect from the server
        Disconnect-ManagementServer
    }
    catch
    {
        Write-Output "Error during the process: $_"
    }

} else {
    Write-Output "Invalid IP address"
}

# Set pause to read errors before close the main window
Read-Host -Prompt "Presione Enter para cerrar la ventana"