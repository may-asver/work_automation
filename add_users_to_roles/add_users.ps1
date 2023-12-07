<# Script to add a list of users to a role in Milestone from a CSV file.
#  Input: IP address of the server, CSV file with the list of users
#  Output: Message of success
#  Requirements: PowerShell, MilestonePSTools module v23.2.3
#  Usage: ./add_users.ps1 <IP address>
#  CSV file format: "NombreUsuarioAD";"NombreRolMilestone"
#
#  Author: Maya Aguirre
#  Date: 2023-12-07
#>


# Import the required modules
Import-Module ActiveDirectory
Import-Module Milestone

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
        $csv = Import-Csv -Path $path -Delimiter ";" -Encoding "UTF8"
        # Connect to the server
        Write-Host "Connecting to server" $ip
        Connect-ManagementServer $ip
        # Add each user to the role from the CSV file
        foreach ($row in $csv)
        {
            $usuarioAD = $row.NombreUsuarioAD
            $rolMilestone = $row.NombreRolMilestone
            # Obtener el objeto de usuario de AD
            $usuarioADObj = Get-ADUser -Identity $usuarioAD
            # Verificar si el usuario de AD existe
            if ($usuarioADObj) {
                # Obtener el objeto de rol en Milestone
                $rolMilestoneObj = Get-VmsRole -Name $rolMilestone
                # Verificar si el rol en Milestone existe
                if ($rolMilestoneObj) {
                    # Agregar el usuario al rol en Milestone
                    Add-VmsRoleMember -AccountName $usuarioADObj -Role $rolMilestoneObj
                    Write-Host "The user '$usuarioAD' was added to the role '$rolMilestone' in the server"
                } else {
                    Write-Host "Error: The role '$rolMilestone' was not found in the server"
                }
            } else {
                Write-Host "Error: The AD user '$usuarioAD' was not found"
            }
        }
        Write-Host "Done"
    }
    catch
    {
        Write-Host "Error: $_"
    }
}
else
{
    Write-Host "Error: Invalid IP address"
}
