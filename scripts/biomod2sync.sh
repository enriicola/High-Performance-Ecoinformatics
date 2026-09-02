#!/usr/bin/env bash
set -Eeuo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."
git -C docs/biomod2 switch master
git -C docs/biomod2 pull --ff-only origin master
git add docs/biomod2

if git diff --cached --quiet -- docs/biomod2; then
  echo "BIOMOD2 is already up to date."
  exit 0
fi

git commit -m "chore: update BIOMOD2 submodule" -- docs/biomod2
git push origin main
