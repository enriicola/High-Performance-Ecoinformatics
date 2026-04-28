#!/bin/bash

# Configuration
WIP_MSG="wip: just saving progress here, commit to be deleted later"

# Check if inside a git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  echo "Error: Not a git repository."
  exit 1
fi

# Get the last commit message
LAST_MSG=$(git log -1 --pretty=%s 2>/dev/null)
CURRENT_BRANCH=$(git branch --show-current)

save_wip() {
  echo "Saving WIP..."
  git add .
  git commit -m "$WIP_MSG"
  
  if git remote | grep -q 'origin'; then
    echo "Pushing to origin/$CURRENT_BRANCH..."
    git push origin "$CURRENT_BRANCH"
  else
    echo "No remote 'origin' found. Skipping push."
  fi
}

restore_wip() {
  if [ "$LAST_MSG" != "$WIP_MSG" ]; then
    echo "Error: Last commit is NOT a WIP commit. Aborting restore for safety."
    exit 1
  fi

  echo "Restoring WIP (un-committing)..."
  # Reset --soft keeps your changes staged
  git reset --soft HEAD~1
  
  if git remote | grep -q 'origin'; then
    echo "Deleting WIP commit from origin/$CURRENT_BRANCH..."
    # Force push to remove the commit from the remote
    git push origin +"$CURRENT_BRANCH"
  else
    echo "No remote 'origin' found. Skipping remote cleanup."
  fi
  
  echo "Workspace restored. Changes are staged and ready for work."
}

# Logic for flags or auto-toggle
case "$1" in
  --save)
    save_wip
    ;;
  --restore)
    restore_wip
    ;;
  *)
    # Auto-toggle behavior
    if [ "$LAST_MSG" == "$WIP_MSG" ]; then
      restore_wip
    else
      save_wip
    fi
    ;;
esac
