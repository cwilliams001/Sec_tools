#!/bin/bash


# Function to stop neo4j
stop_neo4j() {
    echo "[+] Stopping neo4j..."
    sudo neo4j stop
    # Kill any remaining neo4j processes
    sudo pkill -f neo4j
}

# Set up trap to stop neo4j on script exit
trap stop_neo4j EXIT

# Create target directory
TARGET_DIR="$HOME/Desktop/ad_enum($DOMAIN)"
mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR"

# Domain Enumeration with ldapdomaindump
echo "[+] Running ldapdomaindump..."
mkdir outputdir
ldapdomaindump ldaps://"$TARGET_IP" -u "$DOMAIN\\$LDAPUSERNAME" -p "$PASSWORD" -o outputdir

# BloodHound
echo "[+] Starting neo4j..."
sudo neo4j start

echo "[+] Running BloodHound Python collector..."
mkdir bloodhound
cd bloodhound
bloodhound-python -d "$DOMAIN" -u "$LDAPUSERNAME" -p "$PASSWORD" -ns "$TARGET_IP" -c all

# PlumHound
echo "[+] Running PlumHound..."
cd "$PLUMHOUND_PATH"
sudo python3 PlumHound.py --easy -p "$NEO4J_PASSWORD"
sudo python3 PlumHound.py -x tasks/default.tasks -p "$NEO4J_PASSWORD"

# Open report
echo "[+] Opening PlumHound report..."
firefox "$PLUMHOUND_PATH/reports/index.html" &

echo "[+] Enumeration complete. Results are in $TARGET_DIR"
