#!/bin/bash
# Define ANSI escape codes for red color
RED='\033[0;31m'
GREEN='\033[32m'
NC='\033[0m' # No Color

# Function: Check and install curl if missing
install_curl() {
    if ! command -v curl &> /dev/null; then
        echo "Installing curl..."
        if [ -f /etc/os-release ]; then
            if grep -q "Ubuntu" /etc/os-release; then
                sudo apt update
                sudo apt install -y curl
            elif grep -q "CentOS" /etc/os-release; then
                sudo yum update
                sudo yum install -y curl
            else
                echo "Unsupported operating system."
                exit 1
            fi
        else
            echo "Could not determine the operating system."
            exit 1
        fi
    else
        echo "curl is already installed."
    fi
}

# Function: Check and install jq if missing
install_jq() {
    if ! command -v jq &> /dev/null; then
        echo "Installing jq..."
        if [ -f /etc/os-release ]; then
            if grep -q "Ubuntu" /etc/os-release; then
                sudo apt update
                sudo apt install -y jq
            elif grep -q "CentOS" /etc/os-release; then
                sudo yum update
                sudo yum install -y jq
            else
                echo "Unsupported operating system."
                exit 1
            fi
        else
            echo "Could not determine the operating system."
            exit 1
        fi
    else
        echo "jq is already installed."
    fi
}

# Perform installation of curl and jq
install_curl
install_jq

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
rm get-docker.sh

docker run -d -p 8080:8080 reacherhq/backend:latest

# Define the content of the mailchecker.sh script
MAILCHECKER_SCRIPT="#!/bin/bash

API_URL=\"http://localhost:8080/v0/check_email\"
OUTPUT_FILE=\"test_results.csv\"

echo \"email,status\" > \"\$OUTPUT_FILE\"

while IFS= read -r email; do
    response=\$(curl -s -X POST -H \"Content-Type: application/json\" -d \"{\\\"to_email\\\": \\\"\$email\\\"}\" \"\$API_URL\")

    is_reachable=\$(echo \"\$response\" | jq -r '.is_reachable')

    if [ \"\$is_reachable\" = \"safe\" ]; then
        status=\"valid\"
    else
        status=\"invalid\"
    fi

    echo \"\$email,\$status\" >> \"\$OUTPUT_FILE\"
done < emails.txt

echo \"Tests completed. Results saved to \$OUTPUT_FILE.\"
"

# Create mailchecker.sh file with the content
echo "$MAILCHECKER_SCRIPT" > mailchecker.sh
chmod +x mailchecker.sh

# Display usage instructions in red color
echo -e "${GREEN}Installation Completed.${NC}"
echo -e "${GREEN}Usage:${NC}"
echo -e "${GREEN}1. Create a file named emails.txt. Paste all the email addresses you want to check into this file.${NC}"
echo -e "${GREEN}2. Run the command ./mailchecker.sh.${NC}"
echo -e "${GREEN}3. All emails will be automatically checked and the results will be saved to the test_results.csv file.${NC}"

echo "mailchecker.sh script created and made executable."



