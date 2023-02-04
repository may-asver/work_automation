"""
    Script to make a consult to camera servers and download the result.
    Compare result with a cvs file and list cameras' id which need a ticket to report.

    Author: Maya Aguirre
    Date: 2023-02-02
"""

# import pypsrp
# from pypsrp.client import Client
# from pypsrp.wsman import WSMan
# from pypsrp.shell import Process, SignalCode, WinRS
import subprocess
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()
USER = os.getenv("USER")
PASSWORD = os.getenv("PASSWD")
COMPUTER_NAME = os.getenv("COMPUTER_NAME")


# Dictionary with the IP of the servers
IP_SERVERS = {'C5': "10.0.131.125", 'Libertad': "10.0.126.137", 'Vallarta': "172.16.8.3", 'Lagos': "172.17.52.235",
              'GDL': "172.17.2.245.4"}


def create_session(server):
    """Create a new PowerShell session."""
    session = pypsrp.client.Client(server)
    return session


def close_session(session):
    """Close the PowerShell session."""
    session.close()


def connect_to_server(session):
    """Connect to the server and return the result."""
    result = session.run_script(r"Connect-ManagementServer 10.0.131.125 (Get-Credential) -AcceptEula")
    return result


def close_connection_server(session):
    """Close the connection to the server."""
    session.run_script(r"Disconnect-ManagementServer")


def main():
    """Main function."""
    # Create a new PowerShell session
    """session = create_session(IP_SERVERS["C5"])
    print(IP_SERVERS["C5"])
    connect_to_server(session)
    result = session.run_script(r"(Get-ItemState -CamerasOnly | Where-Object State -ne 'Responding').FQID.ObjectId | "
                                r"Get-VmsCamera | Out-Gridview CORONA SERVIDOR Get-VmsCamera -Name "" | Out-GridView")
    print(result)
    # Close the PowerShell session
    close_connection_server(session)"""
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
    command_1 = "Connect-ManagementServer 10.0.131.125 (Get-Credential)"
    command = "(Get-ItemState -CamerasOnly | Where-Object State -ne 'Responding').FQID.ObjectId | Get-VmsCamera | " \
              "Out-Gridview"
    subprocess.run(["powershell.exe", command_1])
    subprocess.run(["powershell.exe", command])
    #print(result)


if __name__ == '__main__':
    main()
