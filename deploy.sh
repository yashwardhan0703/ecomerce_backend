#!/bin/bash

ACTIVE_PORT=$(grep -oP 'server 127.0.0.1:\K[0-9]+' /etc/nginx/sites-available/api.conf)

if [ "$ACTIVE_PORT" = "5001" ]; then
    NEW_SERVICE="backend_green"
    NEW_PORT="5002"
    OLD_SERVICE="backend_blue"
else
    NEW_SERVICE="backend_blue"
    NEW_PORT="5001"
    OLD_SERVICE="backend_green"
fi

echo "Starting $NEW_SERVICE..."
docker compose up -d --build $NEW_SERVICE

echo "Waiting 15 seconds for startup..."
sleep 15

echo "Checking health of new service on port $NEW_PORT..."

if curl -f http://localhost:$NEW_PORT/api/health > /dev/null 2>&1; then
    echo "Health check passed ✅"

    echo "Switching Nginx to $NEW_PORT..."
    sudo sed -i "s/server 127.0.0.1:[0-9]*/server 127.0.0.1:$NEW_PORT/" /etc/nginx/sites-available/api.conf
    sudo nginx -s reload

    echo "Stopping $OLD_SERVICE..."
    docker stop $OLD_SERVICE

    echo "Deployment successful 🎉"
else
    echo "Health check failed ❌"
    echo "Stopping $NEW_SERVICE..."
    docker stop $NEW_SERVICE

    echo "Rollback complete. Keeping $OLD_SERVICE running."
    exit 1
fi
