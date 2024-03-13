# Move hardware
Script to move a cameras list in a CSV file to another recording server.  <br />

## Requirements
- Powershell module: MilestonePSTools version 23.2.3
- Milestone Management v.23.1 or later
- User with admin permissions in the server
- CSV file with the HardwareName, recording server name and storage  <br />

## How to use
1. Download the script
2. Run the script from PowerShell
3. Enter the Milestone Server IP address to add users
4. Select CSV file
5. Wait until the script finishes

## Description
The CSV file that lists the cameras to move, needs to include the HardwareName, Recording server name to relocate the cameras and the storage name to save recordings.  <br />  <br />
Example:  <br />
```HardwareName,RecordingServer,Storage``` <br />
```TZ_3_F,MILREC21.local,Local default``` <br />
```TZ_2_F,MILREC21.local,Local default``` <br />
```TZ_1_F,MILREC21.local,Local default``` <br />
<br />
Where the first line is the header of the CSV file.  <br />
The following lines are the hardware to move from a recording server to another <br />
**The delimiter should be a comma (,)**  <br />

**NOTE:** The new recording server should be in the same main server as the current one.  <br /> <br />
The storage should exists in the new recording server.