# Active Directory Enumeration and Attack Scripts

This repository contains two scripts for Active Directory operations: ad-enum.sh for enumeration and ad-attack.sh for post-compromise attacks.

## AD Enumeration Script (ad-enum.sh)


This script automates the process of Active Directory enumeration using various tools including ldapdomaindump, BloodHound, and PlumHound.

## Prerequisites

Ensure you have the following tools installed:
- ldapdomaindump
- BloodHound
- BloodHound Python
- PlumHound
- neo4j

## Setup

1. Clone this repository or download the script.
2. Make the script executable:
   ```
   chmod +x ad_enum_script.sh
   ```

3. Set up the following environment variables:
   ```
   export DOMAIN="your_domain"
   export TARGET_IP="target_ip_address"
   export LDAPUSERNAME="your_domain_username"
   export PASSWORD="your_domain_password"
   export NEO4J_PASSWORD="your_neo4j_password"
   export PLUMHOUND_PATH="/path/to/plumhound"
   ```

## Usage

Run the script:
```
./ad_enum_script.sh
```

The script will:
1. Create a directory for output on your Desktop
2. Run ldapdomaindump
3. Start neo4j and run BloodHound Python collector
4. Execute PlumHound
5. Open the PlumHound report in Firefox

## Output

Results will be stored in `~/Desktop/ad_enum(DOMAIN_NAME)`.

## Notes

- The script will automatically stop neo4j upon completion or if interrupted.
- Ensure you have necessary permissions to run these tools in your environment.
- This script is intended for educational and authorized testing purposes only.

## AD Attack Script (ad-attack.sh)

This script automates various post-compromise Active Directory attacks, including Pass the Password, Pass the Hash, and running the lsassy module.

### Prerequisites

Ensure you have the following tools installed:
- CrackMapExec
- Impacket (for secretsdump.py)

### Setup

1. Make the script executable:
   ```
   chmod +x ad-attack.sh
   ```

2. Set up the following environment variables:
   
   ```
   export TARGET_SUBNET="10.70.100.0/24"
   export DC_IP="10.70.100.104"
   export TARGET_IP="10.70.100.105"
   export DOMAIN="MARVEL.local"
   export TARGET_USERNAME="f.castle"
   export LOCAL_ADMIN="administrator"
   export PASSWORD="Password1"
   export HASH="aad3b435b51404eeaad3b435b51404ee:7facdc498ed1680c4fd1448319a8c04f"
 
   ```

### Usage

Run the script:
```
./ad-attack.sh
```

The script will:
1. Perform Pass the Password attack
2. Perform Pass the Hash attack (if hash is provided)
3. Run the lsassy module

### Notes

- Ensure you have the necessary permissions to perform these actions in your environment.
- This script is intended for educational and authorized testing purposes only.
- Be cautious when using or storing credentials and hashes.

## General Notes

- Both scripts are intended for educational and authorized testing purposes only.
- Always ensure you have explicit permission to run these tools and scripts in the target environment.
- Handle any sensitive information (like passwords and hashes) with extreme caution.
```
