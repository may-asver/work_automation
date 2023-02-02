"""
    Script to make a consult to camera servers and download the result.
    Compare result with a cvs file and list cameras' id which need a ticket.

    Author: Maya Aguirre
    Date: 2023-02-02
"""

import pypsrp


def main():
    """Main function."""
    # Create a new PowerShell session
    session = "yep"