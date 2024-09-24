#!/bin/bash

BINARY_NAME="whereisit"
SERVICE_NAME="whereisit.service"
BINARY_INSTALL_PATH="/usr/local/bin/"
SERVICE_INSTALL_PATH="/etc/systemd/system/"
PUBLIC_SOURCE_DIR="./public"
PUBLIC_DEST_DIR="/var/www/whereisit/public"
WORKING_DIR="$(pwd)"
USER_NAME="$(whoami)"  # Or set your specific username here

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Use sudo." 
   exit 1
fi

# Build the Go binary (Optional step, assuming Go is installed)
echo "Building the Go binary..."
go build -o "${WORKING_DIR}/${BINARY_NAME}"

# Copy the binary to /usr/local/bin/
echo "Installing ${BINARY_NAME} binary to ${BINARY_INSTALL_PATH}"
cp "${WORKING_DIR}/${BINARY_NAME}" "${BINARY_INSTALL_PATH}"

# Check if the copy was successful
if [[ $? -ne 0 ]]; then
    echo "Failed to install binary. Exiting."
    exit 1
fi

# Copy the static files to /var/www/whereisit/public
echo "Creating web content directory at ${PUBLIC_DEST_DIR}"
mkdir -p "${PUBLIC_DEST_DIR}"

echo "Copying web content from $PUBLIC_SOURCE_DIR to $PUBLIC_DEST_DIR"
cp -r "$PUBLIC_SOURCE_DIR"/* "$PUBLIC_DEST_DIR"

# Ensure proper permissions
echo "Setting permissions for web content directory..."
chown -R "${USER_NAME}:${USER_NAME}" "${PUBLIC_DEST_DIR}"
chmod -R 755 "${PUBLIC_DEST_DIR}"

# Create the systemd service file
echo "Creating systemd service file at ${SERVICE_INSTALL_PATH}${SERVICE_NAME}"

cat <<EOL > "${SERVICE_INSTALL_PATH}${SERVICE_NAME}"
[Unit]
Description=WhereIsIt
After=network.target

[Service]
Type=simple
ExecStart=${BINARY_INSTALL_PATH}${BINARY_NAME} --public ${PUBLIC_DEST_DIR}
WorkingDirectory=${PUBLIC_DEST_DIR}/../
Restart=on-failure
User=$USER_NAME
Group=$USER_NAME

[Install]
WantedBy=multi-user.target
EOL

# Set permissions for the service file
chmod 644 "$SERVICE_INSTALL_PATH$SERVICE_NAME"

# Reload systemd manager configuration
echo "Reloading systemd daemon..."
systemctl daemon-reload

# Enable the service to start on boot
echo "Enabling the $SERVICE_NAME service..."
systemctl enable "$SERVICE_NAME"

# Start the service immediately
echo "Starting the $SERVICE_NAME service..."
systemctl start "$SERVICE_NAME"

# Verify that the service is running
echo "Checking the status of the service..."
systemctl status "$SERVICE_NAME"

echo "Installation complete."
