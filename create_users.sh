#!/bin/bash

# Check if the input is provided in the correct format
if [ $# -ne 1 ]; then
    echo "Usage: create_user.sh <name-of-text-file>"
    exit 1
fi

# redirect all errors to /dev/null
exec 2>> /dev/null 

# Directory for logs and password file
user_management_log="/var/log/user_management.log"
user_passwords="/var/secure/user_passwords.csv"

# Check if the log file exists
if [ ! -e $user_management_log ]; then
    # Create user management log file
    sudo mkdir -p /var/log && sudo touch $user_management_log && echo "User management log file created!" | sudo tee -a $user_management_log > /dev/null
fi

# Set the permissions for the log file
sudo chmod 644 $user_management_log && echo "Permissions set for user management log file!" | sudo tee -a $user_management_log > /dev/null

# Check if the user password file exists
if [ ! -e $user_passwords ]; then
    # create user password log file
    sudo mkdir -p /var/secure && sudo touch $user_passwords && echo "User password log file created!" | sudo tee -a $user_management_log > /dev/null
fi

# Set the permissions for the password file so that only the owner can read and write to it
sudo chmod 600 $user_passwords && echo "Permissions set for user password log file!" | sudo tee -a $user_management_log > /dev/null

# get filename from command line
file_name=$1

# check if file exists
if [ ! -f $file_name ]; then
    echo "File not found!" | sudo tee -a $user_management_log > /dev/null
    exit 1
fi

# read file line by line
while read user; do
    
    # split the user into user and groups
    IFS=';' read -r -a list <<< "$user"
    username=${list[0]}
    groups=${list[1]}

    # remove white spaces from the groups
    groups=$(echo $groups | tr -d ' ')

    # Split the groups into an array and create the groups
    IFS=',' read -r -a createGroups <<< "$groups"
    for i in "${createGroups[@]}"; do
        sudo groupadd $i
        if [ $? -eq 0 ]; then
            echo "Group $i created!" | sudo tee -a $user_management_log > /dev/null
        else
            echo "Group $i already exists!" | sudo tee -a $user_management_log > /dev/null
        fi
    done
    
    # check if user exists
    if id -u $username &>/dev/null; then
        echo "User $username already exists!" | sudo tee -a $user_management_log > /dev/null
    else
        # create a user
        sudo groupadd $username && echo "Group $username created!" | sudo tee -a $user_management_log > /dev/null
        sudo useradd -m -g $username $username && echo "User $username created!" | sudo tee -a $user_management_log > /dev/null
        sudo usermod -aG ${groups//,/ } $username && echo "User $username added to groups $groups" | sudo tee -a $user_management_log > /dev/null

         # Set the user's password using openssl rand command
        password=$(openssl rand -base64 12)
        echo "$username,$password" | sudo tee -a $user_passwords > /dev/null
        echo "$username:$password" | sudo chpasswd
        if [ $? -eq 0 ]; then
            echo "Password for $username set successfully" | sudo tee -a $user_management_log > /dev/null
        else
            echo "Failed to set password for $username" | sudo tee -a $user_management_log > /dev/null
        fi
    fi
done < $file_name
