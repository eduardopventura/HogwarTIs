#!/bin/bash

# Function to remove services
remove_service() {
    local service_name=$1
    echo "Removing service $service_name..."

    # Stop and disable service if exists
    if systemctl list-unit-files | grep -q "^$service_name.service"; then
        sudo systemctl stop "$service_name.service"
        sudo systemctl disable "$service_name.service"
        echo "Service $service_name stopped and disabled"
    else
        echo "Service $service_name not found in systemd"
    fi

    # Remove service file
    if [ -f "/etc/systemd/system/$service_name.service" ]; then
        sudo rm "/etc/systemd/system/$service_name.service"
        echo "Removed /etc/systemd/system/$service_name.service"
    else
        echo "Service file /etc/systemd/system/$service_name.service not found"
    fi

    # Unmount if mounted
    if mount | grep -q "/mnt/cloud/data/$service_name"; then
        sudo umount "/mnt/cloud/data/$service_name"
        echo "Unmounted /mnt/cloud/data/$service_name"
    else
        echo "No mount found at /mnt/cloud/data/$service_name"
    fi
}

# Main script execution
echo "Starting service removal process..."

# Check if any arguments were provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 service1 [service2 ...]"
    echo "No services specified. Exiting."
    exit 1
fi

# Process each service passed as argument
for service in "$@"; do
    remove_service "$service"
done

# Wait for a couple of seconds
sleep 3
echo "All removal operations completed for services: $@"
