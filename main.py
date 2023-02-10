"""
    Script to make a consult to camera servers and download the result.
    Compare result with a cvs file and list cameras' id which need a ticket to report.

    Author: Maya Aguirre
    Date: 2023-02-02
"""

import ast
import subprocess
from pypsrp.wsman import WSMan
from pypsrp.powershell import PowerShell, RunspacePool
import os
from dotenv import load_dotenv
import PySimpleGUI as sg


# Load environment variables
load_dotenv()
USER = os.getenv("USER")
PASSWORD = os.getenv("PASSWD")
PORT = os.getenv("PORT")


# Dictionary with the IP of the servers
IP_SERVERS = ast.literal_eval(os.getenv("IP_SERVERS"))


def connect_to_server(ps, server):
    """Connect to the server."""
    ps.add_script(f"Connect-ManagementServer {server} -AcceptEula")


def close_connection(ps):
    """Close the connection to the server."""
    try:
        ps.add_script("Disconnect-ManagementServer")
    except Exception as e:
        print(f"An error occurred: {e}")
    finally:
        window_alert("Connection closed")


def window_alert(message):
    """Create a window to alert the user."""
    layout = [[sg.Text(message)],
              [sg.Button("Ok")]]
    window = sg.Window("Alert", layout)
    while True:
        event, values = window.read()
        if event == "Ok" or event == sg.WIN_CLOSED:
            break
    window.close()


def main():
    """Main function."""
    # Create a new PowerShell session
    wsman = WSMan(IP_SERVERS['C5'], ssl=False, auth="negotiate", encryption="auto", username=USER, password=PASSWORD,
                  port=PORT, cert_validation=False, read_timeout=50)
    with wsman, RunspacePool(wsman) as pool:
        # Connect to the server
        ps = PowerShell(pool)
        # connect_to_server(ps, IP_SERVERS["C5"])
        # ps.add_script("Connect-ManagementServer " + server + " -AcceptEula")
        ps.add_script("Connect-ManagementServer 10.0.131.125 -AcceptEula")
        ps.add_statement()
        ps.add_script(
            "(Get-ItemState -CamerasOnly | Where-Object State -ne 'Responding').FQID.ObjectId")
        # close_connection(ps)
        output = ps.invoke()
        print(output)
        # try:
        #
        # except Exception as e:
        #     print(f"An error occurred: {e}")


if __name__ == '__main__':
    main()
