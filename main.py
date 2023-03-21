"""
    Script to automate the process of creating tickets of the cameras which are not responding.

    Author: Maya Aguirre
    Date: 2023-02-02
"""

# Import libraries
import sys
import ast
# import socket
from getpass_asterisk.getpass_asterisk import getpass_asterisk as getpass_
from pypsrp.wsman import WSMan
# from socket import gethostname
import winrm
import subprocess
# from pypsrp.powershell import PowerShell, RunspacePool
import os
from dotenv import load_dotenv
import PySimpleGUI as sg
import openpyxl
from cryptography.fernet import Fernet

# Load environment variables
load_dotenv()


class User(object):
    __key__ = Fernet.generate_key()

    def __init__(self, username: str, password: str):
        self.username = username
        User.__encrypt__(self, password)

    def get_username(self):
        return self.username

    def get_password(self):
        return User.__decrypt__(self)

    def __encrypt__(self, password):
        """Encrypt the password."""
        f = Fernet(User.__key__)
        self.password = f.encrypt(password.encode("utf-8"))

    def __decrypt__(self):
        """Decrypt the password."""
        f = Fernet(User.__key__)
        return f.decrypt(self.password).decode("utf-8")


def create_user():
    """Create user."""
    try:
        passwd = get_password(os.getlogin())
        user = User(os.getlogin(), passwd)
        return user
    except Exception as e:
        window_alert(f"An error occurred while getting username: {e}")


def get_password(user):
    """Get the password."""
    # Dictionary with the IP of the servers
    IP_SERVERS = ast.literal_eval(os.environ.get("IP_SERVERS"))
    while True:
        print(f"Enter the password for {user}: \n")
        password = getpass_()
        try:
            session = winrm.Session(IP_SERVERS["C5"], auth=(user, password), transport='ntlm')
            response = session.run_cmd("ipconfig")
            if response.status_code == 0:
                return password
        except Exception as e:
            window_alert(f"An error occurred while login: {e}")


def login(user, server):
    """Login to the server."""
    PORT = os.environ.get("PORT")
    dominio = os.environ.get("DOMAIN_2").__add__("\\")
    wsman = WSMan(server, username=user.get_username(), ssl=False,
                  password=user.get_password(), port=PORT, cert_validation=False)
    print(wsman.get_server_config())
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
    layout = [[sg.Text(message, size=(50, 4), justification="center")],
              [sg.Button("Ok", border_width=3, size=(7, 1))]]
    window = sg.Window("Alert", layout, element_justification="center")
    while True:
        event, values = window.read()
        if event == "Ok" or event == sg.WIN_CLOSED:
            break
    window.close()


def response_to_xlsx(response, server):
    """Save the response to a xlsx file."""
    try:
        if not os.path.exists("cameras_not_responding.xlsx"):
            # Create a workbook
            workbook = openpyxl.Workbook()
            sheet = workbook.active
            sheet.title = server
        else:
            # Open the workbook
            workbook = openpyxl.load_workbook("cameras_not_responding.xlsx")
            # Select the sheet
            if server in workbook.sheetnames:
                sheet = workbook[server]
            else:
                sheet = workbook.create_sheet(server)
        # Write data to the workbook
        for index in range(len(response)):
            sheet.cell(row=index + 1, column=1).value = response[index]
        # Save the workbook
        workbook.save("cameras_not_responding.xlsx")
        workbook.close()
        window_alert(f"The response for {server} was saved successfully")
    except Exception as e:
        window_alert(f"An error occurred saving the response: {e}")


def main():
    """Main function."""
    try:
        # Dictionary with the IP of the servers
        IP_SERVERS = ast.literal_eval(os.environ.get("IP_SERVERS"))
        # Run scritps in the servers
        for server in IP_SERVERS.values():
            command = os.environ.get("COMMAND").format(server)
            result = subprocess.run(["powershell", "-Command", command], capture_output=True, encoding="cp437")
            if result.stderr:
                window_alert(f"An error occurred: {result.stderr}")
                break
            response_to_xlsx(result.stdout.split('\n'), server)
        window_alert("Process finished successfully")
    except Exception as e:
        window_alert(f"An error occurred: {e}")


if __name__ == '__main__':
    main()
