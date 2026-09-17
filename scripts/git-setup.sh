#!/usr/bin/env bash
set -euo pipefail

git config --local core.filemode false
git config --local core.autocrlf false
git config --local core.hooksPath .githooks
