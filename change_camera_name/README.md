# Change Name
Scripts to automate the process of changing HardwareName or CameraName from Milestone Server of a camera's list in a CSV file.  <br />

## Requirements
- Powershell module: MilestonePSTools version 23.2.3
- User with admin permissions in the server
- CSV file with the HardwareId and new Hardware name

## How to use them
1. Download the scripts
2. Run a script from PowerShell
3. Enter the Milestone Server IP address
4. Select CSV file
5. Wait until the script finishes

## Change Hardware Name
Script to change HardwareName of a list of cameras on CSV file.  <br />

The CSV file that lists the cameras to change its name needs to include the HardwareId and the new HardwareName.  <br />  <br />
Example:  <br />
```"HardwareName","NewHardwareName"``` <br />
```"sg561-0ghb","Camera 1"``` <br />
```"sg561-0ghk","Camera 2"``` <br />
```"sg561-0gui","Camera 3"``` <br />
<br />
Where ```"HardwareName","NewHardwareName"``` is the header of the CSV file.  <br />
The following lines are the cameras to change its name.  <br />

## Change Camera Name
Script to change CameraName of a list of cameras on CSV file.  <br />

The CSV file that lists the cameras to change its name needs to include the camera's name and the new name.  <br />  <br />
Example:  <br />
```"CameraName","NewCameraName"``` <br />
```"sg561-0ghb","Camera 1"``` <br />
```"sg561-0ghk","Camera 2"``` <br />
```"sg561-0gui","Camera 3"``` <br />
<br />
Where ```"CameraName","NewCameraName"``` is the header of the CSV file.  <br />
The following lines are the cameras to change its name.  <br />
