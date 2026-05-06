#!/bin/zsh
# Cineca Leonardo setup

eval $(ssh-agent -s)
step-cli ssh login 'enricopezzano@disroot.org' --provisioner cineca-hpc

echo "Connected. Now you can use:"
echo "  ssh REDACTED_USERNAME@login.leonardo.cineca.it"
echo "  scp -r /local/path REDACTED_USERNAME@login.leonardo.cineca.it:~/"
echo ""
echo "Note: if terminal keys don't work, run on Leonardo:"
echo "  export TERM=xterm"
