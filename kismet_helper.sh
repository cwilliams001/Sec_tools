#!/bin/bash

# Kismet API credentials
KISMET_USER="kismet_user"
KISMET_PASS="kismet_password"

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to format hop channels
format_hop_channels() {
    local channels=$1
    echo $channels | sed 's/[][]//g' | sed 's/"//g' | sed 's/,/ /g'
}

# Function to lock channel
lock_channel() {
    local source_uuid=$1
    local channel=$2
    local interface=$3
    
    response=$(curl -s -X POST \
         -d "json={\"channel\": \"$channel\"}" \
         "http://$KISMET_USER:$KISMET_PASS@localhost:2501/datasource/by-uuid/$source_uuid/set_channel.cmd")

    if [[ $response == *"\"kismet.datasource.channel\": \"$channel\""* ]]; then
        echo -e "${GREEN}Successfully locked channel $channel on device $interface${NC}"
    else
        echo -e "${RED}Failed to lock channel $channel on device $interface${NC}"
    fi
}

# Function to set hopping mode
set_hopping_mode() {
    local source_uuid=$1
    local hop_rate=${2:-5}
    local channels=$3
    local interface=$4
    
    local json_data="{\"hop\": true, \"rate\": $hop_rate"
    if [[ -n $channels ]]; then
        json_data="$json_data, \"channels\": [$(echo $channels | sed 's/,/","/g' | sed 's/^/"/;s/$/"/')]"
    fi
    json_data="$json_data}"

    response=$(curl -s -X POST \
         -d "json=$json_data" \
         "http://$KISMET_USER:$KISMET_PASS@localhost:2501/datasource/by-uuid/$source_uuid/set_channel.cmd")

    if [[ $response == *"\"kismet.datasource.hopping\": 1"* ]]; then
        echo -e "${GREEN}Successfully set hopping mode on device $interface${NC}"
        new_channels=$(echo $response | grep -oP '"kismet.datasource.hop_channels": \K[^\]]+')
        formatted_channels=$(format_hop_channels "$new_channels")
        echo -e "${YELLOW}New hop channels: $formatted_channels${NC}"
    else
        echo -e "${RED}Failed to set hopping mode on device $interface${NC}"
    fi
}

# Function to get datasource information
# Function to get datasource information
get_datasources() {
    echo -e "${CYAN}Fetching available datasources...${NC}"
    local json_response=$(curl -s "http://$KISMET_USER:$KISMET_PASS@localhost:2501/datasource/all_sources.json")
    
    mapfile -t uuids < <(echo "$json_response" | grep -oP '"kismet.datasource.uuid": "\K[^"]+')
    mapfile -t names < <(echo "$json_response" | grep -oP '"kismet.datasource.name": "\K[^"]+')
    mapfile -t interfaces < <(echo "$json_response" | grep -oP '"kismet.datasource.interface": "\K[^"]+')
    mapfile -t channels < <(echo "$json_response" | grep -oP '"kismet.datasource.channel": "\K[^"]+')
    mapfile -t hopping < <(echo "$json_response" | grep -oP '"kismet.datasource.hopping": \K[^,]+')
    mapfile -t hop_channels < <(echo "$json_response" | grep -oP '"kismet.datasource.hop_channels": \K[^\]]+\]')
    
    echo -e "${YELLOW}Found datasources:${NC}"
    for i in "${!uuids[@]}"; do
        echo -e "${MAGENTA}$((i+1)). ${BLUE}${interfaces[$i]}${NC} (${CYAN}${names[$i]}${NC})"
        if [ "${hopping[$i]}" == "1" ]; then
            echo -e "   Channel: ${GREEN}Hopping${NC}"
            echo -e "   Hopping: ${CYAN}true${NC}"
            formatted_channels=$(format_hop_channels "${hop_channels[$i]}")
            echo -e "   Hop Channels: ${YELLOW}$formatted_channels${NC}"
        else
            echo -e "   Channel: ${GREEN}${channels[$i]}${NC}"
            echo -e "   Hopping: ${RED}false${NC}"
        fi
        echo -e "   UUID: ${YELLOW}${uuids[$i]}${NC}"
    done
}

# Main loop
while true; do
    echo -e "\n${CYAN}======================================${NC}"
    get_datasources
    echo -e "${CYAN}======================================${NC}"
    
    # Display options
    echo -e "\n${YELLOW}Choose an action:${NC}"
    echo -e "${MAGENTA}1. ${NC}Lock channel for a device"
    echo -e "${MAGENTA}2. ${NC}Set device to hopping mode"
    echo -e "${MAGENTA}3. ${NC}Exit"

    read -p "$(echo -e ${YELLOW}"Enter your choice (1-3): "${NC})" choice
    
    case $choice in
        1)
            echo -e "${YELLOW}Available devices:${NC}"
            for i in "${!interfaces[@]}"; do
                echo -e "${MAGENTA}$((i+1)). ${BLUE}${interfaces[$i]}${NC}"
            done
            read -p "$(echo -e ${YELLOW}"Enter the device number: "${NC})" device_num
            if [ "$device_num" -gt 0 ] && [ "$device_num" -le "${#uuids[@]}" ]; then
                read -p "$(echo -e ${YELLOW}"Enter the channel to lock for ${interfaces[$device_num-1]}: "${NC})" channel
                lock_channel "${uuids[$device_num-1]}" "$channel" "${interfaces[$device_num-1]}"
            else
                echo -e "${RED}Invalid device number.${NC}"
            fi
            ;;
        2)
            echo -e "${YELLOW}Available devices:${NC}"
            for i in "${!interfaces[@]}"; do
                echo -e "${MAGENTA}$((i+1)). ${BLUE}${interfaces[$i]}${NC}"
            done
            read -p "$(echo -e ${YELLOW}"Enter the device number: "${NC})" device_num
            if [ "$device_num" -gt 0 ] && [ "$device_num" -le "${#uuids[@]}" ]; then
                echo -e "${YELLOW}Choose hopping mode:${NC}"
                echo -e "${MAGENTA}1. ${NC}2.4GHz"
                echo -e "${MAGENTA}2. ${NC}5GHz"
                echo -e "${MAGENTA}3. ${NC}Both 2.4GHz and 5GHz"
                read -p "$(echo -e ${YELLOW}"Enter your choice (1-3): "${NC})" hop_choice
                case $hop_choice in
                    1) channels="1,2,3,4,5,6,7,8,9,10,11" ;;
                    2) channels="36,40,44,48,52,56,60,64,100,104,108,112,116,120,124,128,132,136,140,144,149,153,157,161,165" ;;
                    3) channels="1,2,3,4,5,6,7,8,9,10,11,36,40,44,48,52,56,60,64,100,104,108,112,116,120,124,128,132,136,140,144,149,153,157,161,165" ;;
                    *) echo -e "${RED}Invalid choice. Using all available channels.${NC}"; channels="" ;;
                esac
                set_hopping_mode "${uuids[$device_num-1]}" 5 "$channels" "${interfaces[$device_num-1]}"
            else
                echo -e "${RED}Invalid device number.${NC}"
            fi
            ;;
        3)
            echo -e "${GREEN}Exiting...${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice. Please enter a number between 1 and 3.${NC}"
            ;;
    esac
    
    sleep 1
done
