#!/bin/bash

# Read the service name from the command line argument
SERVICE_NAME="$1"
if [ -z "$SERVICE_NAME" ]; then
    echo "Usage: $0 <service_name>"
    exit 1
fi

cd /opt/aqualog
docker compose down $SERVICE_NAME
docker compose pull $SERVICE_NAME
docker compose up -d $SERVICE_NAME
docker system prune -af
