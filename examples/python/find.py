import argparse
import requests

from typing import List

def get_devices(server_ip, server_port) -> List[str]:
    """
    Send the local IP to the REST server as a JSON payload.
    """
    url = f"http://{server_ip}:{server_port}/api/devices"
    try:
        response = requests.get(url)
        if response.status_code == 200:
            print(f"Successfully sent IP update to {server_ip}:{server_port}: {ip}")
            print(response.content)
        else:
            print(f"Failed to send IP update. Status code: {response.status_code}")
    except Exception as e:
        print(f"Error sending IP update: {e}")

def main():
    # Parse command line arguments
    parser = argparse.ArgumentParser(description="Get devices inside the network from a \"whereisit\" server.")
    parser.add_argument("--server-ip", required=True, help="The IP address of the REST server.")
    parser.add_argument("--server-port", required=True, help="The port number of the REST server.")
    parser.add_argument("--identifier", required=False, help="The identifier of the device searched for.")
    args = parser.parse_args()
    server_ip = args.server_ip
    server_port = args.server_port

    deviceList = get_devices(server_ip, server_port)

    if deviceList.count > 0:
        for device in deviceList:
            print("Device:", device)
    else:
        print("No device found")

if __name__ == "__main__":
    main()
