# Get cameras with status Not-Responding
This script is coded in Python language, and makes consults to all Milestone servers to get cameras which are in Not-Responding status.
The list is saved in a xlsx file and separated by server.  <br />

## Requirements
- Powershell module: MilestonePSTools version 23.2.3
- Python 3.7 or above.
- Python libraries: dotenv, PySimpleGUI, openpyxl.

## Usage
1. Download the script with the folder _resources_.
2. Make a .exe file using `pyinstaller` (`pyinstaller main.spec`) or install needed libraries to run it in Python.
3. Run script and wait for success message.
