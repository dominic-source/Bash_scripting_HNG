## User Management Script

This script automates the process of creating users and groups on a Linux system. It reads user information from a CSV file and performs the following actions:

* Creates any necessary groups specified in the file.
* Checks if the user already exists.
* Creates the user if they don't exist.
* Adds the user to the specified groups.
* Generates a random password for the user and stores it securely.

**Requirements:**

* Bash shell
* `sudo` privileges
* `openssl` command

**How to Use:**

1. **Create a CSV File:**

   Create a CSV file with the following format:
   username;group1,group2,...


* The first column should contain the username.
* The second column should contain a comma-separated list of groups the user should belong to.

2. **Save the CSV File:**

Save your created CSV file.

3. **Run the Script:**

Run the script with the CSV file path as an argument:

bash user_management.sh /path/to/your/user_file.csv


**Log File:**

The script creates a log file at `/var/log/user_management.log` to track its actions. This file will contain information about:

* Script execution
* Created groups
* User creation status
* Password setting status (success or failure)

**Password File:**

The script stores usernames and their randomly generated passwords in a secure file with restricted permissions at `/var/secure/user_passwords.csv`.

**Important Notes:**

* This script requires sudo privileges to run.
* The script generates random passwords for new users. It's recommended to inform users about the generated passwords or provide a mechanism for them to change it.
* This script is for educational purposes only. Make sure to understand the security implications before using it in a production environment.