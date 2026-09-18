#!/usr/bin/env bash
set -euo pipefail

git config --local --replace-all core.filemode false
git config --local --replace-all core.autocrlf false
git config --local --replace-all core.hooksPath .githooks
