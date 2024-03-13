# Add users to a role in Milestone Server
Get users and its role from a CSV file, validate if user exists on Active Directory and add it to an existing role.  <br />

## Requirements
- PowerShell 3.0 or higher
- Powershell module: MilestonePSModule version 23.2.3
- User with admin permissions or necessary to run the task in the server
- CSV file with the users and its role

## Description

The CSV file must have the following format:  <br />

Example:  <br />
```"NombreUsuarioAD","NombreRolMilestone"``` <br />
```"username1","role1"``` <br />
```"username2","role2"``` <br />
```"username3","role3"``` <br />

Where the first line is the header and the following lines are the users with its role.  <br />
<br />
**The delimiter should be a comma (,)**. <br />

## How to use
1. Download the script
2. Run the script from PowerShell
3. Enter the Milestone Server IP address
4. Select CSV file
5. Wait until the script finishes