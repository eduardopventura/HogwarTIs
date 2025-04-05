#!/bin/bash

# Function to restart services with validation
restart_service() {
    local service_name=$1
    echo "Attempting to restart $service_name..."
    
    # Check if service exists
    if systemctl list-unit-files | grep -q "^${service_name}$"; then
        # Check if service is active
        if systemctl is-active --quiet "$service_name"; then
            sudo systemctl restart "$service_name"
            echo "Successfully restarted $service_name"
        else
            echo "Service $service_name is not currently active"
            sudo systemctl start "$service_name"
            echo "Started $service_name"
        fi
    else
        echo "Error: Service $service_name not found in systemd"
        return 1
    fi
}

# Main script execution
echo "Starting service restart process..."

# Check if any arguments were provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 service1 [service2 ...]"
    echo "No services specified. Exiting."
    exit 1
fi

# Process each service passed as argument
for service in "$@"; do
    # Add .service suffix if not present
    if [[ "$service" != *.service ]]; then
        service="${service}.service"
    fi
    restart_service "$service"
done

# Wait for a couple of seconds
sleep 3

echo "All restart operations completed for services: ${*/%.service/}"
