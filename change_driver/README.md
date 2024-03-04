# Change Driver ID
Script to change driver id to a cameras from a CSV file.  <br />

## Requirements
- Powershell module: MilestonePSTools version 23.2.3
- Milestone Management v.23.1 or later
- User with admin permissions in the server
- CSV file with the HardwareName and DriverNumber of new each camera  <br />

**NOTE:** DriverNumber is given in https://www.milestonesys.com/support/software/supported-devices/ doing a search by model.  <br />

The CSV file that lists the cameras to change its driver id needs to include the HardwareName and the new ID.  <br />  <br />
Example:  <br />
```"HardwareName","DriverNumber"``` <br />
```"Camara_1_F","676"``` <br />
```"Camara_2_F","676"``` <br />
```"Camara_3_F","676"``` <br />
<br />
Where the first line is the header of the CSV file.  <br />
The following lines are the cameras to update <br />
**The delimiter should be a comma (,)**  <br />

## How to use
1. Download the script
2. Run the script from PowerShell
3. Enter the Milestone Server IP address
4. Select CSV file
5. Wait until the script finishes

