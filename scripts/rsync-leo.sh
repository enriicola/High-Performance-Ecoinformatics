#!/bin/bash

LOCAL_DIR="$HOME/tesi"
REMOTE="REDACTED_USERNAME@login.leonardo.cineca.it"
REMOTE_DIR="/leonardo_work/IscrC_SPECC"

case "${1:-push}" in
  push)
    # -O = omit dir times (fixes permission error on shared dirs)
    # no --delete = preserve remote output files
    rsync -avO --progress --exclude='.git*' "$LOCAL_DIR/" "$REMOTE:$REMOTE_DIR/"
    ;;
  pull)
    rsync -avO --progress "$REMOTE:$REMOTE_DIR/output/" "$LOCAL_DIR/output/"
    ;;
  *)
    echo "Usage: $0 [push|pull]"
    exit 1
    ;;
esac

