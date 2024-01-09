# Automation of Milestone tasks using MilestonePSTools
Tasks automated with PowerShell scripts using MilestonePSTools.  <br />

## General requirements
- Powershell module: MilestonePSTools version 23.2.3
- User with admin permissions in the server
- CSV file (in some scripts)

## Add hardware
Add new cameras from a CSV file to a Milestone Recording Server.  <br />
The CSV file should look something like this:  <br />
````
"CameraName","HardwareName","CameraGroup","Address","UserName","Password","Coordinates","DriverNumber","RecordingServer"
"Camara_1_F","Camara_1_F","/Group1","10.190.100.4","admin","password","20.69864628, -103.298597","676","QA-DF-NT-VMS"
"Camara_2_F","Camara_2_F","/Group1","10.190.100.5","admin","password","20.69868828, -103.298597","676","QA-DF-NT-VMS"
"Camara_3_F","Camara_3_F","/Group1","10.190.100.6","admin","password","20.69864628, -103.297797","676","QA-DF-NT-VMS"
````
<br />
Where the first line is the header of the CSV file.  <br />
The following lines are the cameras to add  <br />

## Export and Import roles and profiles
Export and import roles and profiles from a Milestone Server to another Milestone Server.  <br />
The script requires two IP addresses, the first one is the server where you want to export the roles and profiles, the next one is the server to import the exported data.  <br />

## Add users to roles
Get users and its role from a CSV file, validate if exists in AD to add it in the role in the Milestone recording server.  <br />
The CSV file should look like this:  <br />
````
"NombreUsuarioAD";"NombreRolMilestone"
"username1";"role1"
"username2";"role2"
"username3";"role3"
````
Where the first line is the header, and the following the users with the role where the user will be.  <br />

## Get cameras with not responding status
This script is coded in Python language, and makes consults to all Milestone servers to get cameras which are in _Not-Responding_ status.  <br />
The list is saved in an xlxs file and separated by server.  <br />
<br />
**Note**: You need an environment file with the sensitive variables (servers IP address, servers name, MilestonePSTools commands).

## Change hardware name
Script to automate the process of changing camera HardwareName from Milestone Server of a camera's list.  <br />
The script needs a CSV file, which indicates the hardware id and the new hardware name.  <br />
The CSV file should look like this:  <br />
````
"HardwareId";"HardwareName"
"sg561-0ghb";"Camera 1"
"sg561-0ghk";"Camera 2"
"sg561-0gui";"Camera 3"
````
**The first line must be written like in the example**, which indicates the header.  <br />
