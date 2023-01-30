# System Enumeration Script

This script is a basic system enumeration script that is designed to gather information about a Linux system and store the results in a text file. The script will gather information about the system's hardware, users and groups, network information, installed packages, kernel information, cron jobs, and SUID/SGID files.

## Usage
1. Clone or download the script to your local machine.
2. Make the script executable with `chmod +x quick_enum.sh`
3. Run the script with `./quick_enum.sh`
4. The script will prompt you to confirm if you want to run the script and create the output file. Enter y to proceed or n to cancel.
5. The script will check if the user has permission to write to the output file. If the user does not have permission, the script will terminate.
6. The script will then proceed to gather information about the system and store the results in the output file named 'results_current_date_time.txt' on the users desktop.
7. Once the script has finished running, it will display a message indicating the location of the output file.

## Note
Please note that the script uses some commands that requre root permissions. As such the script should be run with root permissions or the user should have 'sudo' privileges.

## Disclaimer
This script is provided as is and is not intended to be used maliciously. The author is not responsible for any damage caused by the use of this script.