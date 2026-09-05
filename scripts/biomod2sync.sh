#!/usr/bin/env bash
set -Eeuo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."
git -C docs/biomod2 switch master
# If this fails with "Cannot fast-forward to multiple branches", another process
# (for example VS Code autofetch) may be updating FETCH_HEAD concurrently.
# Retry this script after a few minutes. Alternatively, run:
# git -C docs/biomod2 fetch --no-write-fetch-head origin master
# git -C docs/biomod2 merge --ff-only origin/master
git -C docs/biomod2 pull --ff-only origin master
git add docs/biomod2

if git diff --cached --quiet -- docs/biomod2; then
  echo "BIOMOD2 is already up to date."
  exit 0
fi

git commit -m "chore: update BIOMOD2 submodule" -- docs/biomod2
git push origin main
