<# Script to add a list of users to a role in Milestone from a CSV file.
  Input: IP address of the server, CSV file with the list of users
  Output: Message of success
  Requirements: PowerShell, MilestonePSTools module v23.2.3
  It should be run with Administrator privileges and from the Milestone Server.
  Usage: ./add_users.ps1
  CSV file format: "NombreUsuarioAD";"NombreRolMilestone"

  Author: Maya Aguirre
  Date: 2023-12-07
#>


# Validate if exists the module ActiveDirectory
if ($null -eq  (Get-Module -ListAvailable -Name ActiveDirectory))
{
    # Install the module ActiveDirectory
    Add-WindowsFeature RSAT-AD-PowerShell
}

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
    $csv = Import-Csv -Path $path -Delimiter ";" -Encoding "UTF8"
    # Add each user to the role from the CSV file
    foreach ($row in $csv)
    {
        $usuarioAD = $row.NombreUsuarioAD
        Write-Host "Adding user '$usuarioAD'"
        $rolMilestone = $row.NombreRolMilestone
        # Obtener el objeto de usuario de AD
        $usuarioADObj = Get-ADUser -Identity $usuarioAD | Select-Object UserPrincipalName -ErrorAction Stop
        # Verificar si el usuario de AD existe
        if ($usuarioADObj)
        {
            # Obtener el objeto de rol en Milestone
            $rolMilestoneObj = Get-VmsRole -Name $rolMilestone
            # Verificar si el rol en Milestone existe
            if ($rolMilestoneObj)
            {
                # Agregar el usuario al rol en Milestone
                Add-VmsRoleMember -AccountName $usuarioADObj.UserPrincipalName -Role $rolMilestoneObj
                Write-Host "The user '$usuarioAD' was added to the role '$rolMilestone' in the server"
            }
            else
            {
                Write-Host "Error: The role '$rolMilestone' was not found in the server"
            }
        }
        else
        {
            Write-Host "Error: The AD user '$usuarioAD' was not found"
        }
    }
    # Disable the RSAT-AD-PowerShell feature
    Remove-WindowsFeature -Name RSAT-AD-PowerShell
    # Finish the script
    Write-Host "Done"
}
catch
{
    Write-Host "Error: $_"
}
