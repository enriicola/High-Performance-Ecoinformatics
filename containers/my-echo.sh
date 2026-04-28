#!/bin/sh

# Color constants
BLUE='\033[1;34m'
NC='\033[0m'

# Function to print blue echo messages
blue_echo() {
    echo "${BLUE}${1}${NC}"
}

export BLUE NC
