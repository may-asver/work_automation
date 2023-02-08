"""
    Script to make a consult to camera servers and download the result.
    Compare result with a cvs file and list cameras' id which need a ticket to report.

    Author: Maya Aguirre
    Date: 2023-02-02
"""

import ast
from pypsrp.wsman import WSMan
from pypsrp.powershell import PowerShell, RunspacePool
import os
from dotenv import load_dotenv
import pysimplegui as sg


# Load environment variables
load_dotenv()
USER = os.getenv("USER")
PASSWORD = os.getenv("PASSWD")
COMPUTER_NAME = os.getenv("COMPUTER_NAME")
PORT = os.getenv("PORT")


# Dictionary with the IP of the servers
IP_SERVERS = ast.literal_eval(os.getenv("IP_SERVERS"))


def connect_to_server(pool, server):
    """Connect to the server."""
    ps = PowerShell(pool)
    try:
        ps.add_script(f"Connect-ManagementServer {server} -AcceptEula")
    except Exception as e:
        print(f"An error occurred: {e}")


def close_connection(pool):
    """Close the connection to the server."""
    ps = PowerShell(pool)
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
    wsman = WSMan(IP_SERVERS["C5"], ssl=False, auth="negotiate", encryption="always", username=USER, password=PASSWORD,
                  port=PORT, cert_validation=False)
    with wsman, RunspacePool(wsman) as pool:
        # Connect to the server
        ps = PowerShell(pool)
        try:
            connect_to_server(ps, IP_SERVERS["C5"])
            # ps.add_script("Connect-ManagementServer 10.0.131.125 -AcceptEula")
            ps.add_statement()
            ps.add_script(
                "(Get-ItemState -CamerasOnly | Where-Object State -ne 'Responding').FQID.ObjectId | Get-VmsCamera")
            output = ps.invoke()
            print(output)
        except Exception as e:
            print(f"An error occurred: {e}")
        finally:
            ps.add_statement()
            close_connection(ps)
            wsman.close()




    # uri = "http://{}:5985/wsman".format(IP_SERVERS["C5"])
    # wsman = WSMan(IP_SERVERS['C5'], ssl=False, auth="negotiate", username=USER, password=PASSWORD, port=3389,
    #               encryption="never", connection_timeout=30)
    # wsman.close()
    # with wsman, WinRS(wsman) as shell:
    #     print(wsman)
    #     process = Process(shell, "dir")
    #     process.invoke()
    #     process.signal(SignalCode.CTRL_C)
    #
    #     # execute a process with arguments in the background
    #     process = Process(shell, "powershell", ["gci", "$pwd"])
    #     process.begin_invoke()  # start the invocation and return immediately
    #     process.poll_invoke()  # update the output stream
    #     process.end_invoke()  # finally wait until the process is finished
    #     process.signal(SignalCode.CTRL_C)
    #     wsman.close()
    # commands = ["Connect-ManagementServer 10.0.131.125 (Get-Credential)", "(Get-ItemState -CamerasOnly | Where-Object State -ne 'Responding').FQID.ObjectId | Get-VmsCamera | " \
    #           "Out-Gridview", "Disconnect-ManagementServer"]
    # for command in commands:
    #     subprocess.run(["powershell.exe", "-Command", command], shell=True, check=True)

if __name__ == '__main__':
    main()
