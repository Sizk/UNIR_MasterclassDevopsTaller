#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Starting Ansible Playbook Testing Environment${NC}"
echo "This script will test your Ansible playbook on both AWS and Azure-like environments"
echo

# Stop and remove any existing containers
echo -e "${YELLOW}Cleaning up any existing test containers...${NC}"
docker-compose down -v 2>/dev/null

# Build and start the containers
echo -e "${YELLOW}Building and starting test containers...${NC}"
docker-compose up -d --build

# Wait for containers to be ready
echo -e "${YELLOW}Waiting for containers to initialize...${NC}"
sleep 10

# Check if containers are running
AWS_RUNNING=$(docker ps -q -f name=aws-webserver-test)
AZURE_RUNNING=$(docker ps -q -f name=azure-webserver-test)

# Test AWS container
if [ ! -z "$AWS_RUNNING" ]; then
    echo -e "${GREEN}AWS test container is running${NC}"
    echo "Testing AWS webserver at http://localhost:8080"
    
    # Check if webserver is responding
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 || echo "Failed")
    if [ "$HTTP_CODE" = "200" ]; then
        echo -e "${GREEN}✓ AWS webserver is responding (HTTP 200)${NC}"
    else
        echo -e "${RED}✗ AWS webserver is not responding properly (HTTP $HTTP_CODE)${NC}"
        echo -e "${YELLOW}AWS container logs:${NC}"
        docker logs aws-webserver-test
    fi
else
    echo -e "${RED}✗ AWS test container failed to start${NC}"
    echo -e "${YELLOW}AWS container logs:${NC}"
    docker logs aws-webserver-test
fi

echo

# Test Azure container
if [ ! -z "$AZURE_RUNNING" ]; then
    echo -e "${GREEN}Azure test container is running${NC}"
    echo "Testing Azure webserver at http://localhost:8081"
    
    # Check if webserver is responding
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8081 || echo "Failed")
    if [ "$HTTP_CODE" = "200" ]; then
        echo -e "${GREEN}✓ Azure webserver is responding (HTTP 200)${NC}"
    else
        echo -e "${RED}✗ Azure webserver is not responding properly (HTTP $HTTP_CODE)${NC}"
        echo -e "${YELLOW}Azure container logs:${NC}"
        docker logs azure-webserver-test
    fi
else
    echo -e "${RED}✗ Azure test container failed to start${NC}"
    echo -e "${YELLOW}Azure container logs:${NC}"
    docker logs azure-webserver-test
fi

echo
echo -e "${YELLOW}Test Summary:${NC}"
echo "AWS webserver: http://localhost:8080"
echo "Azure webserver: http://localhost:8081"
echo
echo -e "${YELLOW}To stop the test containers, run:${NC}"
echo "docker-compose down"
echo
echo -e "${YELLOW}To view container logs:${NC}"
echo "docker logs aws-webserver-test"
echo "docker logs azure-webserver-test"
