#!/bin/bash

# Get script directory (where this script and others are located)
SCRIPTS_DIR="$(dirname "$(realpath "$0")")"
# Services directory is in the parent folder
BASE_DIR="$(dirname "$SCRIPTS_DIR")"
SERVICES_DIR="$BASE_DIR/services"

# List of available scripts
SCRIPTS=("create_drive_folders.sh" "enable_services.sh" "disable_services.sh" "restart_services.sh")

# Verify and fix permissions for all scripts
for script in "${SCRIPTS[@]}"; do
    if [ ! -x "$SCRIPTS_DIR/$script" ]; then
        echo "Fixing execute permissions for $script"
        chmod +x "$SCRIPTS_DIR/$script"
    fi
done

# Check if services directory exists
if [ ! -d "$SERVICES_DIR" ]; then
    echo "Error: Services directory not found at $SERVICES_DIR"
    exit 1
fi

# Display menu
echo "Select which script to execute:"
for i in "${!SCRIPTS[@]}"; do
    echo "$((i+1)). ${SCRIPTS[$i]}"
done

# Get user choice
read -p "Enter the number of your choice: " choice
if [[ ! "$choice" =~ ^[1-4]$ ]]; then
    echo "Invalid selection. Please enter a number between 1 and 4."
    exit 1
fi

selected_script="${SCRIPTS[$((choice-1))]}"
script_path="$SCRIPTS_DIR/$selected_script"

# Verify selected script exists
if [ ! -f "$script_path" ]; then
    echo "Error: Script $selected_script not found at $script_path"
    exit 1
fi

# Get all .service files
service_files=("$SERVICES_DIR"/*.service)

if [ ${#service_files[@]} -eq 0 ]; then
    echo "No .service files found in $SERVICES_DIR"
    exit 1
fi

# Prepare parameters (strip path and .service extension)
params=()
for service_file in "${service_files[@]}"; do
    service_name=$(basename "$service_file" .service)
    params+=("$service_name")
done

echo "Found services: ${params[*]}"
echo "Executing $selected_script for all services..."

# Execute the selected script with all services as parameters
"$script_path" "${params[@]}"

echo "Operation completed for all services."
