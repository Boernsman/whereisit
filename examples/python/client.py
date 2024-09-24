import argparse
import requests
import json
import time
import socket
import os

STATE_FILE = "/tmp/ip_state.json"  # Store the last IP and timestamp

def get_local_ip():
    """
    Retrieve the current local IP address.
    """
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        # This doesn't actually send data; it's just to get the IP
        s.connect(('8.8.8.8', 80))
        return s.getsockname()[0]
    except Exception as e:
        print(f"Error retrieving local IP: {e}")
        return None
    finally:
        s.close()

def get_hostname():
    """
    Retrieve the local machine's hostname.
    """
    return socket.gethostname()

def get_serial_number():
    """
    Retrieve the device's serial number.
    This is an example command that works on many Linux systems.
    Adjust as needed based on your hardware.
    """
    try:
        # This command works on many Linux systems
        serial = os.popen("cat /etc/machine-id").read().strip()
        if not serial:
            serial = "UNKNOWN_SERIAL"
        return serial
    except Exception as e:
        print(f"Error retrieving serial number: {e}")
        return "UNKNOWN_SERIAL"

def load_state():
    """
    Load the last known state (IP and timestamp) from file.
    """
    if os.path.exists(STATE_FILE):
        with open(STATE_FILE, 'r') as f:
            return json.load(f)
    return None

def save_state(ip, timestamp):
    """
    Save the current IP and timestamp to file.
    """
    with open(STATE_FILE, 'w') as f:
        json.dump({"ip": ip, "timestamp": timestamp}, f)


def send_ip_update(ip, name, id, server_ip, server_port):
    """
    Send the local IP to the REST server as a JSON payload.
    """
    url = f"http://{server_ip}:{server_port}/api/register"
    payload = {
            "name": name,
            "address": ip,
            "id": id
            }
    try:
        response = requests.post(url, json=payload)
        if response.status_code == 200:
            print(f"Successfully sent IP update to {server_ip}:{server_port}: {ip}")
        else:
            print(f"Failed to send IP update. Status code: {response.status_code}")
    except Exception as e:
        print(f"Error sending IP update: {e}")

def main():
    # Parse command line arguments
    parser = argparse.ArgumentParser(description="Send local IP to a \"whereisit\" server when it changes, or every 24 hours.")
    parser.add_argument("--server-ip", required=True, help="The IP address of the REST server.")
    parser.add_argument("--server-port", required=True, help="The port number of the REST server.")
    args = parser.parse_args()
    server_ip = args.server_ip
    server_port = args.server_port

    while True:
        current_ip = get_local_ip()

        if not current_ip:
            print("Could not determine local IP. Retrying in 10 minutes.")
            time.sleep(600)  # Retry in 10 minutes
            continue

        hostname   = get_hostname()
        identifier = get_serial_number()

        state = load_state()
        current_time = time.time()
        
        # Check if state exists and if 24 hours have passed or IP has changed
        if not state or state['ip'] != current_ip or (current_time - state['timestamp'] > 86400):
            send_ip_update(current_ip, hostname, identifier, server_ip, server_port)
            save_state(current_ip, current_time)
        else:
            print(f"No changes in IP. Last sent IP: {state['ip']}. Will check again in 10 minutes.")

        # Wait 10 minutes before checking again
        time.sleep(600)

if __name__ == "__main__":
    main()
