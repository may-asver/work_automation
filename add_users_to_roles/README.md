# Add users to a role in Milestone Server
Get users and its role from a CSV file, validate if user is valid on Active Directory and add it to an existing role.  <br />

The CSV file must have the following format:  <br />
```"NombreUsuarioAD";"NombreRolMilestone"```: the first line is the header.  <br /> 
```"username";"role"```: the following lines are the users with its role.  <br />

Example:  <br />
```"NombreUsuarioAD";"NombreRolMilestone"``` <br />
```"username1";"role1"``` <br />
```"username2";"role2"``` <br />
```"username3";"role3"``` <br />

## Requirements
- PowerShell 3.0 or higher
- Powershell module: MilestonePSModule version 23.2.3
- User with admin permissions in the server
- CSV file with the users and its role
