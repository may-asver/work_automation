# change_camera_name

Script to automate the process of changing camera HardwareName from Milestone Server of a camera's list.  <br />

## Requirements
- Powershell module: MilestonePSTools version 23.2.3
- User with admin permissions in the server
- CSV file with the HardwareId and new Hardware name

The CSV file that lists the cameras to change its name needs to include the HardwareId and the new HardwareName.  <br />  <br />
Example:  <br />
```"HardwareId";"HardwareName"``` <br />
```"sg561-0ghb";"Camera 1"``` <br />
```"sg561-0ghk";"Camera 2"``` <br />
```"sg561-0gui";"Camera 3"``` <br />
<br />
Where ```"HardwareId";"HardwareName"``` is the header of the CSV file.  <br />
The following lines are the cameras to change its name.  <br />

## How to use
1. Download the script
2. Run the script from PowerShell
3. Enter the Milestone Server IP address
4. Select CSV file
5. Wait until the script finishes
