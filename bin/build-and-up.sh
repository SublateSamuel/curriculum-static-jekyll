#!/bin/bash

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
NC="\033[0m"

echo -e "${YELLOW}Checking system requirements...${NC}"

if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker is not installed. Please install Docker and try again.${NC}"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}Docker Compose is not installed. Please install Docker Compose and try again.${NC}"
    exit 1
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
DOCKER_COMPOSE_FILE="$SCRIPT_DIR/../docker-compose.yml"

echo -e "${YELLOW}Setting up the environment...${NC}"

if [ ! -f "$DOCKER_COMPOSE_FILE" ]; then
    echo -e "${RED}The file $DOCKER_COMPOSE_FILE was not found in the current directory.${NC}"
    exit 1
fi

echo -e "${YELLOW}Starting up the services...${NC}"
docker-compose -f "$DOCKER_COMPOSE_FILE" up -d --build --remove-orphans
if [ $? -ne 0 ]; then
  echo -e "${RED}An error occurred while running the docker-compose command.${NC}"
  exit 1
fi

i=1
sp="/-\|"
end=$((SECONDS+120))
server_up=false

while [ $SECONDS -lt $end ]; do
    status=$(curl -s -o /dev/null -w "%{http_code}" localhost:4000)
    
    if [ "$status" -eq 200 ]; then
        server_up=true
        break
    fi
    
    # Animação
    printf "\b${sp:i++%${#sp}:1}"
    sleep 0.1
done

if [ "$server_up" = false ]; then
    echo -ne "${NC}\nTimeout reached. The Django server did not start.\n"
    exit 0
fi


echo -e "\n${YELLOW}All done! Your environment is all set up and running.${NC}"
echo -e "${GREEN}Access the application at${NC} http://localhost:4000/index.html"