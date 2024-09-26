#!/bin/bash

# Kismet API credentials
KISMET_USER="a"
KISMET_PASS="a"

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to lock channel
lock_channel() {
    local source_uuid=$1
    local channel=$2
    
    response=$(curl -s -X POST \
         -d "json={\"channel\": \"$channel\"}" \
         "http://$KISMET_USER:$KISMET_PASS@localhost:2501/datasource/by-uuid/$source_uuid/set_channel.cmd")
    
    if [[ $response == *"\"kismet.datasource.channel\": \"$channel\""* ]]; then
        echo -e "${GREEN}Successfully locked channel $channel on device $3${NC}"
    else
        echo -e "${RED}Failed to lock channel $channel on device $3${NC}"
    fi
}

# Function to get current channel
get_current_channel() {
    local source_uuid=$1
    local json_response=$(curl -s "http://$KISMET_USER:$KISMET_PASS@localhost:2501/datasource/by-uuid/$source_uuid/source.json")
    echo $json_response | grep -oP '"kismet.datasource.channel": "\K[^"]+' || echo "Unknown"
}

# Function to get datasource information
get_datasources() {
    echo -e "${CYAN}Fetching available datasources...${NC}"
    local json_response=$(curl -s "http://$KISMET_USER:$KISMET_PASS@localhost:2501/datasource/all_sources.json")
    
    mapfile -t uuids < <(echo "$json_response" | grep -oP '"kismet.datasource.uuid": "\K[^"]+')
    mapfile -t names < <(echo "$json_response" | grep -oP '"kismet.datasource.name": "\K[^"]+')
    mapfile -t interfaces < <(echo "$json_response" | grep -oP '"kismet.datasource.interface": "\K[^"]+')
    
    echo -e "${YELLOW}Found datasources:${NC}"
    for i in "${!uuids[@]}"; do
        current_channel=$(get_current_channel "${uuids[$i]}")
        echo -e "${MAGENTA}$((i+1)). ${BLUE}${interfaces[$i]}${NC} (${CYAN}${names[$i]}${NC})"
        echo -e "   Current Channel: ${GREEN}$current_channel${NC}"
        echo -e "   UUID: ${YELLOW}${uuids[$i]}${NC}"
    done
}

# Main loop
while true; do
    echo -e "\n${CYAN}======================================${NC}"
    get_datasources
    echo -e "${CYAN}======================================${NC}"
    
    echo -e "\n${YELLOW}Choose an action:${NC}"
    echo -e "${MAGENTA}1. ${NC}Lock channel for a device"
    echo -e "${MAGENTA}2. ${NC}Exit"
    read -p "$(echo -e ${YELLOW}"Enter your choice (1 or 2): "${NC})" choice
    
    case $choice in
        1)
            read -p "$(echo -e ${YELLOW}"Enter the device number to lock channel: "${NC})" device_num
            if [ "$device_num" -gt 0 ] && [ "$device_num" -le "${#uuids[@]}" ]; then
                read -p "$(echo -e ${YELLOW}"Enter the channel to lock for ${interfaces[$device_num-1]}: "${NC})" channel
                lock_channel "${uuids[$device_num-1]}" "$channel" "${interfaces[$device_num-1]}"
                echo -e "${CYAN}Updating datasource information...${NC}"
                sleep 2  # Give Kismet a moment to update
            else
                echo -e "${RED}Invalid device number.${NC}"
            fi
            ;;
        2)
            echo -e "${GREEN}Exiting...${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice. Please enter 1 or 2.${NC}"
            ;;
    esac
    
    echo ""
done
