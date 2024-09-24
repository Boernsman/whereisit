#!/usr/bin/env sh

DEVICE_NAME=$(hostname)

get_serial_number() {
    local serial_number=""

    # Detect operating system
    os_name=$(uname)
    if [[ "$os_name" == "Darwin" ]]; then
        serial_number=$(system_profiler SPHardwareDataType | grep "Serial Number (system)" | awk '{print $NF}')
    elif [[ "$os_name" == "Linux" ]]; then
        serial_number=$(cat /etc/machine-id)
    else
        echo "Unsupported operating system: $os_name"
        return 1
    fi
    echo "$serial_number"
}

get_lan_ip() {
    local ip_address=""

    # Detect operating system
    os_name=$(uname)

    if [[ "$os_name" == "Darwin" ]]; then
        # macOS - Get LAN IP using ifconfig
        ip_address=$(ifconfig en0 | grep "inet " | awk '{print $2}')
    elif [[ "$os_name" == "Linux" ]]; then
        # Linux - Get LAN IP using hostname or ip command
        if command -v ip &> /dev/null; then
            ip_address=$(ip addr show $(ip route show default | awk '/default/ {print $5}') | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)
        else
            ip_address=$(hostname -I | awk '{print $1}')
        fi
    else
        echo "Unsupported operating system: $os_name"
        return 1
    fi

    echo "$ip_address"
}

get_os_version() {
    OS_TYPE=$(uname)

    if [[ "$OS_TYPE" == "Darwin" ]]; then
        # macOS (Darwin) version
        OS_VERSION=$(sw_vers -productVersion)
        echo "Operating System: macOS"
        echo "Version: $OS_VERSION"
    elif [[ "$OS_TYPE" == "Linux" ]]; then
        # Linux version
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            echo "Operating System: $NAME"
            echo "Version: $VERSION"
        else
            echo "Operating System: Linux"
            echo "Version information not found."
        fi
    else
        echo "Unsupported operating system: $OS_TYPE"
        return 1
    fi
}

DEVICE_ID=$(get_serial_number)
DEVICE_IP=$(get_lan_ip)

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <server_ip> <server_port>"
  exit 1
fi

SERVER_IP=$1
SERVER_PORT=$2

PAYLOAD=$(cat <<EOF
{
  "name": "${DEVICE_NAME}",
  "id": "${DEVICE_ID}",
  "address": "${DEVICE_IP}"
}
EOF
)
HEADERS="-H 'Content-Type: application/json'"

if [[ "$server_ip" == "localhost" || "$server_ip" == "127.0.0.1" ]]; then
  headers+=" -H 'x-real-ip: ${DEVICE_IP}'"
fi

WHEREISIT_URL="http://${SERVER_IP}:${SERVER_PORT}/api/register"

eval "curl -X POST $WHEREISIT_URL $HEADERS -d '$PAYLOAD'"

echo "Payload sent: ${PAYLOAD}"
echo "----- DONE -----"
