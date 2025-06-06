# Get cameras
Script to get cameras report from a list of Milestone servers and save it in a CSV file.

## Requirements
- MilestonePSTools PowerShell Module on version 24.2.1 or above.
- User with admin privileges on Milestone servers
- User with permissions to run scripts

**NOTE**: You can install the MilestonePSTools module  with `Install-Module -Name MilestonePSTools -RequiredVersion 24.2.1` command.
If you have some problems, try to install for all user as the following link https://www.milestonepstools.com/installation/#quick-install.

## How to use
1. Download the .ps1 file
2. Set execution policies to run the script
3. Initialize `$servers` variable as a hashtable array.
4. Save changes.
5. Run script.
6. Select a folder to save the csv files.
7. Wait to done message.

