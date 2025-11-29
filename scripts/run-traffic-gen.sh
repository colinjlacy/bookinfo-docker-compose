#!/bin/bash

# Simple script to run the traffic generator
# Works with docker, podman, nerdctl, and docker-compose

echo "Building traffic generator image..."

# Try nerdctl first (common on Lima/Rancher Desktop)
if command -v nerdctl &> /dev/null; then
    nerdctl build -t traffic-generator ./traffic-generator/
    echo "Running traffic generator with nerdctl..."
    nerdctl run --rm --network docker-compose-boutique_bookinfo traffic-generator
# Then try podman
elif command -v podman &> /dev/null; then
    podman build -t traffic-generator ./traffic-generator/
    echo "Running traffic generator with podman..."
    podman run --rm --network docker-compose-boutique_bookinfo traffic-generator
# Then try docker compose (Docker Compose V2)
elif command -v docker &> /dev/null; then
    docker build -t traffic-generator ./traffic-generator/
    echo "Running traffic generator with docker..."
    docker run --rm --network docker-compose-boutique_bookinfo traffic-generator
# Finally try docker-compose (Docker Compose V1)
elif command -v docker-compose &> /dev/null; then
    docker-compose build traffic-generator
    echo "Running traffic generator with docker-compose..."
    docker-compose run --rm traffic-generator
else
    echo "Error: Neither nerdctl, podman, docker, nor docker-compose found!"
    exit 1
fi

