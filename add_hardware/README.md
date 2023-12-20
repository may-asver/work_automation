# Add hardware
Script to add new hardware to a recording Milestone server from a CSV file.  <br />

## Requirements
- Powershell module: MilestonePSTools version 23.2.3
- User with admin permissions in the server
- CSV file with the CameraName, HardwareName, CameraGroup, Address, UserName, Password, Coordinates, DriverNumber, RecordingServer of new each camera  <br />

**NOTE:** DriverNumber is given in https://www.milestonesys.com/support/software/supported-devices/ doing a search by model.  <br />

The CSV file that lists the cameras to change its name needs to include the HardwareId and the new HardwareName.  <br />  <br />
Example:  <br />
```"CameraName","HardwareName","CameraGroup","Address","UserName","Password","Coordinates","DriverNumber","RecordingServer"``` <br />
```"Camara_1_F","Camara_1_F","/Group1","10.190.100.4","admin","password","20.69864628, -103.298597","676","QA-DF-NT-VMS"``` <br />
```"Camara_2_F","Camara_2_F","/Group1","10.190.100.5","admin","password","20.69868828, -103.298597","676","QA-DF-NT-VMS"``` <br />
```"Camara_3_F","Camara_3_F","/Group1","10.190.100.6","admin","password","20.69864628, -103.297797","676","QA-DF-NT-VMS"``` <br />
<br />
Where the first line is the header of the CSV file.  <br />
The following lines are the cameras to add <br />

## How to use
1. Download the script
2. Run the script from PowerShell
3. Enter the Milestone Server IP address
4. Select CSV file
5. Wait until the script finishes

