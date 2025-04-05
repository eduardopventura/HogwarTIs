#!/bin/bash

# Function to create folders
create_folder() {
    local service_name=$1
    echo "Creating folders for $service_name..."
    
    # Create data folder
    sudo mkdir -p "/mnt/cloud/data/$service_name"
    echo "Created /mnt/cloud/data/$service_name"
    
    # Create cache folder
    sudo mkdir -p "/mnt/rclone/cache/$service_name"
    echo "Created /mnt/rclone/cache/$service_name"
}

# Main script execution
echo "Starting folder creation for services..."

# Check if any arguments were provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 drive1 [drive2 ...]"
    echo "No drives specified. Exiting."
    exit 1
fi

# Process each drive passed as argument
for drive in "$@"; do
    create_folder "$drive"
done

# Wait for a couple of seconds
sleep 3

echo "All operations completed for drives: $@"
