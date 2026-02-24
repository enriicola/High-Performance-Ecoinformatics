#!/bin/bash

echo "Setting up the development environment for biomod++..."

if ! git config core.hooksPath .githooks; then
  echo "Failed to set up githooks. Please check your git configuration."
  exit 1
fi

if ! Rscript -e '
  packages <- c("languageserver", "styler", "lintr", "biomod2")
  
  missing_pkgs <- packages[!(packages %in% installed.packages()[,"Package"])]
  if(length(missing_pkgs))
    install.packages(missing_pkgs, repos="https://cloud.r-project.org")
'
then
  echo "Failed to set up R environment. Please check your R configuration."
  exit 1
fi

echo "Setup complete! You may need to restart VS Code to apply changes."