"""
    Script to automate the process of creating tickets of the cameras which are not responding.

    Author: Maya Aguirre
    Date: 2023-02-02
"""

# Import libraries
import ast
from getpass_asterisk.getpass_asterisk import getpass_asterisk as getpass_
from pypsrp.wsman import WSMan
import winrm
from pypsrp.powershell import PowerShell, RunspacePool
import os
from dotenv import load_dotenv
import PySimpleGUI as sg

# Load environment variables
load_dotenv()
PORT = os.getenv("PORT")

# Dictionary with the IP of the servers
IP_SERVERS = ast.literal_eval(os.getenv("IP_SERVERS"))


def get_username():
    """Get the username."""
    try:
        user = os.getlogin()
        return user
    except Exception as e:
        print(f"An error occurred: {e}")


def login(user, passwd, server):
    """Login to the server."""
    try:
        session = winrm.Session(server, auth=(user, passwd), transport='ntlm')
        response = session.run_cmd("ipconfig")
        if response.status_code != 0:
            raise LoginError(f"Failed to run command. Response: {response.std_err}")
        wsman = WSMan(server, ssl=True, auth="negotiate", encryption="auto", username=user,
                      password=passwd, port=PORT, cert_validation=False, read_timeout=50)
        return wsman
    except Exception as e:
        raise LoginError(f"Failed to establish session. Error: {e}")


def connect_to_server(ps, server):
    """Connect to the server."""
    ps.add_script(f"Connect-ManagementServer {server} -AcceptEula")
    ps.add_statement()


def close_connection_powershell(ps):
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
    try:
        # Get user credentials
        user = get_username()
        # password = getpass_()
        # Login to the server
        wsman = login(user, "password", IP_SERVERS["C5"])
        # Run scripts
        with wsman, RunspacePool(wsman) as pool:
            try:
                # Connect to the server
                ps = PowerShell(pool)
                connect_to_server(ps, IP_SERVERS["C5"])
                # Get the cameras' id which are not responding
                ps.add_script(
                    "(Get-ItemState -CamerasOnly | Where-Object State -ne 'Responding').FQID.ObjectId")
                # Execute the script
                output = ps.invoke()
                print(output)
            except Exception as e:
                print(f"An error occurred 3: {e}")
                return
            finally:
                # Close the connection
                close_connection_powershell(ps)
                pool.close()
    except Exception as e:
        print(f"An error occurred 4: {e}")


class LoginError(Exception):
    pass


if __name__ == '__main__':
    main()
