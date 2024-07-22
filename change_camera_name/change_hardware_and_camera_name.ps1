<# Script to change the hardware and camera name of cameras from a CSV file.
#
#  Input: CSV file
#  Output: Message of success
#  Requirements: PowerShell, MilestonePSTools module v23.2.3
#  Author: Maya Aguirre
#  Date: 2024-04-19
#>

# Set action preference to handle the errors in catch
$ErrorActionPreference = "Stop"

# Function that opens a file dialog to select a CSV file
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

# Main processes to change hardware name and camera name
try
{
    # Import the CSV file
    Write-Host "Select the CSV file"
    $path = Select-File
    if ($null -eq $path) # Validate if value is null
    {
        Write-Error "No se ha seleccionado un archivo"
    }
    $csv = Import-Csv -Path $path -Delimiter "," -Encoding "Default"

    # Get the file number line where is running
    $number_line = 1

    # Change the name of each camera from the CSV file
    foreach ($row in $csv)
    {
        # Validate that parameters are not null
        if ('' -eq $row.HardwareName -or '' -eq $row.CameraName -or '' -eq $row.NewHardwareName -or '' -eq $row.NewCameraName -or '' -eq $row.ServerIP)
        {
            Write-Error "Alguno o todos los valores de la linea $number_line en el archivo estan vacios"
        }
        else
        {
            # Connect to the server
            Connect-ManagementServer $row.ServerIP
            $hardware = Get-Hardware -Name $row.HardwareName
            # Change camera and hardware name
            Write-Host "Changing name of camera $($hardware.HardwareName)" # Displays a message to user
            $camera = Get-VmsCamera -Hardware $hardware # Get camera using hardware parameter
            Set-VmsHardware -Hardware $hardware -Name $row.NewHardwareName # Change Hardware name
            Set-VmsCamera -Camera $camera -Name $row.NewCameraName # Change camera name
            # Disconnect from the server
            Disconnect-ManagementServer
        }
        # Sum 1 to number line
        $number_line ++
    }
    Write-Host "Done"
}
catch
{
    Write-Output "Ocurrio un error: $_"
}

# Set pause to read errors before close the main window
Read-Host -Prompt "Presione Enter para cerrar la ventana"
