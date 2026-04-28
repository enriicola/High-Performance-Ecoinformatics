#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONTAINERS_DIR="$SCRIPT_DIR/../containers"

if [ -z "$1" ]; then
    OPTIONS_PATTERN=$(find "$CONTAINERS_DIR" -maxdepth 1 -type f -name '*.def' -printf '%f\n' | sed 's/\.def$//' | sort | paste -sd'|' -)

    echo "Usage: $0 <${OPTIONS_PATTERN}>"
    echo ""
    exit 1
fi

start_time=$(date +%s)

if [ ! -f "$CONTAINERS_DIR/$1.def" ]; then
    echo "Error: definition file not found: $CONTAINERS_DIR/$1.def"
    exit 1
fi

# Build from project root so %files paths in definition files resolve reliably.
cd "$PROJECT_ROOT"

apptainer build "$CONTAINERS_DIR/$1.sif" "$CONTAINERS_DIR/$1.def"

if [ $? -eq 0 ]; then
    end_time=$(date +%s)
    elapsed=$((end_time - start_time))
    if [ $elapsed -ge 60 ]; then
        minutes=$((elapsed / 60))
        seconds=$((elapsed % 60))
        echo "Container built in ${minutes}m ${seconds}s."
    else
        echo "Container built in ${elapsed} seconds."
    fi
else
    echo "Error: Container build failed."
    exit 1
fi