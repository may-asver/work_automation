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
    IP_SERVERS = ast.literal_eval(os.getenv("IP_SERVERS"))
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
    PORT = os.getenv("PORT")
    wsman = WSMan(server, ssl=False, auth="negotiate", encryption="always", username=user.get_username(),
                  password=user.get_password(), port=PORT, cert_validation=False)
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


def response_to_xlsx(response, server):
    """Save the response to a xlsx file."""
    try:
        if not os.path.exists("cameras_not_responding.xlsx"):
            # Create a workbook
            workbook = openpyxl.Workbook()
            sheet = workbook.create_sheet(server)
            # Write data to the workbook
            for index in range(len(response)):
                sheet.cell(row=index + 1, column=1).value = response[index].__str__()
            # Save the workbook
            workbook.save("cameras_not_responding.xlsx")
            workbook.close()
        else:
            # Open the workbook
            workbook = openpyxl.load_workbook("cameras_not_responding.xlsx")
            # Select the sheet
            if not server in workbook.sheetnames:
                sheet = workbook.create_sheet(server)
            else:
                sheet = workbook[server]
            # Write data to the workbook
            for index in range(len(response)):
                sheet.cell(row=index + 1, column=1).value = response[index].__str__()
            # Save the workbook
            workbook.save("cameras_not_responding.xlsx")
            workbook.close()
        window_alert(f"The response for {server} was saved successfully")
    except Exception as e:
        window_alert(f"An error occurred saving the response: {e}")


def main():
    """Main function."""
    user = create_user()
    # Dictionary with the IP of the servers
    IP_SERVERS = ast.literal_eval(os.getenv("IP_SERVERS"))
    server = IP_SERVERS["Lagos"]
    # for server in IP_SERVERS.values():
    try:
        # Login to the server
        wsman = login(user, server)
        # Run scripts
        with wsman, RunspacePool(wsman) as pool:
            try:
                # Connect to the server
                ps = PowerShell(pool)
                connect_to_server(ps, server)
                # Get the cameras' id which are not responding
                ps.add_script(
                    "(Get-ItemState -CamerasOnly | Where-Object State -ne 'Responding').FQID.ObjectId | Get-VmsCamera")
                # Execute the script
                output = ps.invoke()
                for item in output:
                    print(item)
                response_to_xlsx(output, server)
            except Exception as e:
                window_alert(f"An error occurred: {e}")
                return
            finally:
                # Close the connection
                close_connection_powershell(ps)
                pool.close()
    except Exception as e:
        window_alert(f"An error occurred: {e}")


if __name__ == '__main__':
    main()
