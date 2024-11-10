# Active Directory Enumeration Script

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
