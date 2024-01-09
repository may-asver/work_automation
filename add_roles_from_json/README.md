# Export and Import roles and profiles
Script to export existing roles and profiles on a server and import them on another recording server.  <br />

## Requirements
- Powershell module: MilestonePSTools version 23.2.3
- User with admin permissions in the servers

## Usage
You can run it from a PowerShell terminal with admin privileges.  <br />
Command:  <br />
`./add_roles.ps1`  <br />
Once it is running, it will require two IP addresses:  <br />
- First address: is the server where the export will be executed.
- Second address: is the server where the import action will be done.

Then, you need to select a folder where the JSON file will be saved, the first selection is for the roles file and the 
next one is for profiles.  <br />
The execution time may vary on the size of the exported data.  <br />
