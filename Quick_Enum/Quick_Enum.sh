#!/bin/bash
clear
echo """

 ██████  ██    ██ ██  ██████ ██   ██     ███████ ███    ██ ██    ██ ███    ███ 
██    ██ ██    ██ ██ ██      ██  ██      ██      ████   ██ ██    ██ ████  ████ 
██    ██ ██    ██ ██ ██      █████       █████   ██ ██  ██ ██    ██ ██ ████ ██ 
██ ▄▄ ██ ██    ██ ██ ██      ██  ██      ██      ██  ██ ██ ██    ██ ██  ██  ██ 
 ██████   ██████  ██  ██████ ██   ██     ███████ ██   ████  ██████  ██      ██ 

"""
# Get current date and time
now=$(date +"%Y-%m-%d_%H-%M-%S")

# Create a file to store the results of the enumeration
touch "/home/$USER/Desktop/results_$now.txt"
output_file="/home/$USER/Desktop/results_$now.txt"

# Confirm if user wants to run the script
read -p "Do you want to run the script and create the output file (y/n)? " choice

if [[ $choice =~ ^[Yy]$ ]]; then
    # Check if user has permission to write to the output file
    if [ -w $output_file ]; then
        # Enumerate system information
        echo "Enumerating system information..."
        echo -e "\n\nSystem Information\n-----------------" >> $output_file
        sudo lshw >> $output_file

        # Enumerate users and groups
        echo "Enumerating users and groups..."
        echo -e "\n\nUsers and Groups\n----------------" >> $output_file
        cat /etc/passwd | cut -d: -f1,3,4 >> $output_file
        cat /etc/group >> $output_file

        # Enumerate network information
        echo "Enumerating network information..."
        echo -e "\n\nNetwork Information\n------------------" >> $output_file
        ip addr show >> $output_file

        # Enumerate installed packages
        echo "Enumerating installed packages..."
        echo -e "\n\nInstalled Packages\n-----------------" >> $output_file
        dpkg -l >> $output_file

        # Enumerate kernel information
        echo "Enumerating kernel information..."
        echo -e "\n\nKernel Information\n-----------------" >> $output_file
        cat /proc/version >> $output_file

        # Enumerate cron jobs
        echo "Enumerating cron jobs..."
        echo -e "\n\nCron Jobs\n----------" >> $output_file
        crontab -l >> $output_file

        # Enumerate SUID/SGID files
        echo "Enumerating SUID/SGID files..."
        echo -e "\n\nSUID/SGID Files\n--------------" >> $output_file
        find / -perm -u+s -type f 2>/dev/null >> $output_file
        find / -perm -g+s -type f 2>/dev/null >> $output_file

        echo "Script finished! Output file is located at $output_file"
    else
        echo "You do not have permission to write to the output file. Please check the file path and try again."
    fi
else
    echo "Script terminated."
fi
