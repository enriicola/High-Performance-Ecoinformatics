#!/bin/bash
# https://docs.hpc.cineca.it/general/access.html
# IMPORTANT: run it with ". ./cineca-setup.sh" or "source ./cineca-setup.sh"

CA_URL="https://sshproxy.hpc.cineca.it"
CA_FINGERPRINT="2ae1543202304d3f434bdc1a2c92eff2cd2b02110206ef06317e70c1c1735ecd"
USER_EMAIL="enricopezzano@disroot.org"

#check if running with source or dot
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Error: This script must be sourced, not executed."
    echo "Run with: source $0 or . $0"
    exit 1
fi

# Check step-cli installed
if ! command -v step &> /dev/null; then
    echo "Error: step-cli not installed"
    echo "Install: sudo apt install step-cli"
    exit 1
fi

# Bootstrap (one-time config, safe to re-run)
echo "Configuring smallstep CA..."
step ca bootstrap --ca-url="$CA_URL" --fingerprint "$CA_FINGERPRINT" --force

# Use persistent socket so it survives script exit
export SSH_AUTH_SOCK="$HOME/.ssh/cineca-agent.sock"

# Start ssh-agent if not running on this socket
if ! ssh-add -l &>/dev/null; then
    rm -f "$SSH_AUTH_SOCK"
    eval "$(ssh-agent -a "$SSH_AUTH_SOCK")"
    echo "Started ssh-agent on $SSH_AUTH_SOCK"
else
    echo "Using existing ssh-agent"
fi

# Get SSH certificate (opens browser for 2FA)
echo "Requesting SSH certificate (browser will open for 2FA)..."
step ssh login "$USER_EMAIL" --provisioner cineca-hpc

ssh REDACTED_USERNAME@login.leonardo.cineca.it