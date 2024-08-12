# Automation of Milestone tasks using MilestonePSTools
Tasks automated with PowerShell for Milestone (VMS) servers.  <br />

## General requirements
- Powershell module: MilestonePSTools version 23.2.3
- User with admin privilege or necessary permissions to run the tasks in the server and/or PC
- CSV file (in some scripts)

## Add hardware
Add new cameras from a CSV file to a Recording Server.  <br />
The CSV file should look something like this:  <br />
```
"CameraName","HardwareName","CameraGroup","Address","UserName","Password","Coordinates","DriverNumber","RecordingServer"
"Camara_1_F","Camara_1_F","/Group1","10.190.100.4","admin","password","20.69864628, -103.298597","676","QA-DF-NT-VMS"
"Camara_2_F","Camara_2_F","/Group1","10.190.100.5","admin","password","20.69868828, -103.298597","676","QA-DF-NT-VMS"
"Camara_3_F","Camara_3_F","/Group1","10.190.100.6","admin","password","20.69864628, -103.297797","676","QA-DF-NT-VMS"
```
<br />
Where the first line is the header of the CSV file.  <br />
The following lines are the cameras to add  <br />

**The first line must be written like in the example**, which indicates the header.  <br />
**NOTE:** The delimiter should be a comma (,).  <br />

## Export and Import roles and profiles
Export and import roles and profiles from a Milestone Server to another Milestone Server.  <br />
<br />
The script requires two IP addresses, the first one is the server where you want to export the roles and profiles, the next one is the server to import the exported data.  <br />

## Add users to roles
Get users and its role from a CSV file, validate if exists in AD to add it in the role in the Milestone recording server.  <br />
The CSV file should look like this:  <br />
```
"NombreUsuarioAD","NombreRolMilestone"
"username1","role1"
"username2","role2"
"username3","role3"
```
Where the first line is the header, and the following the users with the role where the user will be.  <br />

**The first line must be written like in the example**, which indicates the header.  <br />
**NOTE:** The delimiter should be a comma (,).  <br />

## Get cameras with not responding status
This script is coded in Python language, and makes consults to all Milestone servers to get cameras which are in _Not-Responding_ status.  <br />
The list is saved in a xlsx file and separated by server.  <br />
<br />

**NOTE**: You need an environment file with the sensitive variables (servers IP address, servers name, MilestonePSTools commands).

## Change hardware or camera name, or both
Script to automate the process of changing camera HardwareName or CameraName, or both from Milestone Server of a camera's list.  <br />
The script needs a CSV file, which indicates the hardware id and the new hardware name.  <br />
The CSV file should look like this to change _HardwareName_:
```
"HardwareName","HardwareNewName"
"sg561-0ghb","Camera 1"
"sg561-0ghk","Camera 2"
"sg561-0gui","Camera 3"
```
<br />

The CSV file should look like this to change _CameraName_:
```
"CameraName","CameraNewName"
"sg561-0ghb","Camera 1"
"sg561-0ghk","Camera 2"
"sg561-0gui","Camera 3"
```
The CSV file should look like this to change both parameters:
```
"HardwareName","CameraName","NewHardwareName","NewCameraName","ServerIP"
"sg561-0ghb","Camera 1","Camera1-0ghb","Camera-01","10.0.1.1"
"sg561-0ghk","Camera 2","Camera2-0ghb","Camera-02","10.0.1.1"
"sg561-0gui","Camera 3","Camera3-0ghb","Camera-03","10.0.1.1"
```
<br />

**The first line must be written like in the example**, which indicates the header.  <br />
**NOTE:** The delimiter should be a comma (,).  <br />

## Change driver
Script to change driver id to a cameras from a CSV file.  <br />

The CSV file that lists the cameras to change its driver id needs to include the HardwareName and the new ID.  <br />  <br />
Example:
```
"HardwareName","DriverNumber"
"Camara_1_F","676"
"Camara_2_F","676"
"Camara_3_F","676"
```
<br />

**The first line must be written like in the example**, which indicates the header.  <br />
**NOTE:** The delimiter should be a comma (,), and the DriverNumber is given in https://www.milestonesys.com/support/software/supported-devices/ doing a search by model.  <br />

## Move hardware to another recording server
Script to move cameras in a CSV file to another recording server.  <br />

The CSV file that lists the cameras to move, needs to include the HardwareName, Recording server name to relocate the cameras and the storage name to save recordings.  <br />  <br />
Example:  <br />
```
HardwareName,RecordingServer,Storage
TZ_3_F,MILREC21.local,Local default
TZ_2_F,MILREC21.local,Local default
TZ_1_F,MILREC21.local,Local default
```
The following lines are the hardware to move from a recording server to another <br />

**The first line must be written like in the example**, which indicates the header.  <br />
**NOTE:** The delimiter should be a comma (,). Also, the new recording server should be in the same main server as the current one.  <br /> <br />
**The storage must to exists in the new recording server.**

## Get cameras
Script to get cameras report from a list of Milestone servers and save it in a CSV file for each server.

### How to use
1. Download the .ps1 file
2. Set execution policies to run the script
3. Initialize `$servers` variable as a hashtable array.
4. Save changes.
5. Run script.
6. Select a folder to save the csv files.
7. Wait to done message.