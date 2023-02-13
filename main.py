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
        window_alert(f"An error occurred while getting username: {e}")


def get_password(user):
    """Get the password."""
    while True:
        password = getpass_()
        try:
            session = winrm.Session(IP_SERVERS["C5"], auth=(user, password), transport='ntlm')
            response = session.run_cmd("ipconfig")
            if response.status_code == 0:
                break
            return password
        except Exception as e:
            window_alert(f"An error occurred while login: {e}")


def login(server):
    """Login to the server."""
    user = get_username()
    passwd = get_password(user)
    wsman = WSMan(server, ssl=False, auth="negotiate", encryption="auto", username=user,
                  password=passwd, port=PORT, cert_validation=False, read_timeout=50)
    return wsman


def connect_to_server(ps, server):
    """Connect to the server."""
    ps.add_script(f"Connect-ManagementServer {server} -AcceptEula")
    ps.add_statement()


def close_connection_powershell(ps):
    """Close the connection to the server."""
    try:
        ps.add_script("Disconnect-ManagementServer")
    except Exception as e:
        print(f"An error occurred trying close the connection with server: {e}")
    finally:
        window_alert("Connection closed")


def window_alert(message):
    """Create a window to alert the user."""
    layout = [[sg.Text(message, size=(30, 4), justification="center")],
              [sg.Button("Ok", border_width=3, size=(7, 1))]]
    window = sg.Window("Alert", layout, element_justification="center")
    while True:
        event, values = window.read()
        if event == "Ok" or event == sg.WIN_CLOSED:
            break
    window.close()


def main():
    """Main function."""
    try:
        # Login to the server
        wsman = login(IP_SERVERS["C5"])
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
                window_alert(f"An error occurred running the script: {e}")
                return
            finally:
                # Close the connection
                close_connection_powershell(ps)
                pool.close()
    except Exception as e:
        window_alert(f"An error occurred: {e}")


if __name__ == '__main__':
    main()
