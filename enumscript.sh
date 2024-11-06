#!/bin/bash

# Check if the environment variables are set
REQUIRED_VARS=("TARGET" "TARGET_IP" "BASEDIR" "RECON_DIR" "ENUM_DIR" "TGT_DOMAIN")
for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        echo "Error: Environment variable $var is not set. Please set it before running this script."
        exit 1
    fi
done

# Function to check if a command exists
command_exists() {
    type "$1" &> /dev/null
}

# Check if Nmap is installed
if ! command_exists nmap; then
    echo "Nmap is not installed. Please install it first."
    exit 1
fi

# Check if xmllint is installed (for XML parsing)
if ! command_exists xmllint; then
    echo "xmllint is not installed. Please install it (libxml2-utils)."
    exit 1
fi

# Create a log file in the enumeration directory
LOG_FILE="$ENUM_DIR/enumeration_log_$(date +%Y%m%d_%H%M%S).txt"
exec > >(tee -a "$LOG_FILE") 2>&1

# Function to run Nmap scans
do_nmap_scan() {
    local scan_type="$1"
    local options="$2"
    local output_name="$3"
    echo "[+] Performing $scan_type scan..."
    nmap $options "$TARGET_IP" -oA "$ENUM_DIR/$output_name"
}

# Start enumeration
echo "[+] Starting enumeration on $TARGET ($TARGET_IP)..."

# Perform initial Nmap scan
do_nmap_scan "initial" "-p- --open -sV -O -sC" "initial_scan"

# Debug: Display the XML output of the initial scan
echo "[DEBUG] Initial Nmap XML output:"
cat "$ENUM_DIR/initial_scan.xml"

# Parse the XML output to get open ports
OPEN_PORTS=$(xmllint --xpath "//port[@state='open']/@portid" "$ENUM_DIR/initial_scan.xml" 2>/dev/null | \
            sed -e 's/ portid=\"//g' -e 's/\"//g' | tr '\n' ',' | sed 's/,$//')

# Fallback parsing method if xmllint fails
if [ -z "$OPEN_PORTS" ]; then
    echo "[DEBUG] xmllint failed to extract open ports. Attempting fallback parsing with grep and awk."
    OPEN_PORTS=$(grep 'state="open"' "$ENUM_DIR/initial_scan.xml" | awk -F'portid="' '{for(i=2;i<=NF;i++){split($i,a,"\""); printf a[1]","}}' | sed 's/,$//')
fi

# Debug output to verify OPEN_PORTS
echo "[DEBUG] Open ports found: $OPEN_PORTS"

# Perform targeted scan on open ports if any were found
if [ -n "$OPEN_PORTS" ]; then
    do_nmap_scan "targeted" "-p$OPEN_PORTS -sV -sC --script=vuln" "targeted_scan"
else
    echo "No open ports found. Skipping targeted scan."
fi

# Perform UDP scan on top 100 ports
do_nmap_scan "UDP" "-sU --top-ports 100" "udp_scan"

# Display results
echo "[+] Scan results:"
for result_file in "$ENUM_DIR/targeted_scan.nmap" "$ENUM_DIR/udp_scan.nmap"; do
    if [ -f "$result_file" ]; then
        cat "$result_file"
    fi
done

echo "[+] Enumeration completed. Results saved in:"
echo "    - $LOG_FILE"
echo "    - $ENUM_DIR/initial_scan.*"
echo "    - $ENUM_DIR/targeted_scan.*"
echo "    - $ENUM_DIR/udp_scan.*"

echo "The following output formats are available for each scan:"
echo "    - .nmap (normal output)"
echo "    - .gnmap (grepable output)"
echo "    - .xml (XML output)"
echo "    - .html (HTML output)"

# Generate HTML reports from XML files if xsltproc is installed
if command_exists xsltproc; then
    for xml_file in "$ENUM_DIR"/*.xml; do
        [ -f "$xml_file" ] || continue
        xsltproc "$xml_file" -o "${xml_file%.xml}.html"
    done
    echo "HTML reports have been generated from XML files."
else
    echo "xsltproc not found. Skipping HTML report generation."
fi
