#!/bin/bash

# requires: sudo apt install -y latexmk texlive-fonts-extra texlive-font-utils texlive-bibtex-extra

set -u

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
main_tex="$script_dir/../docs/thesis/main.tex"
main_tex_dir="$(dirname "$main_tex")"
log_file="/tmp/tesi-compile.log"

cd "$main_tex_dir"

if ! latexmk -pdf "$main_tex" >"$log_file" 2>&1; then
  tail -n 80 "$log_file" >&2
  echo "Error: Failed to compile thesis. Full log: $log_file" >&2
  exit 1
fi

grep 'Overfull \\hbox' "$log_file" || true

echo "Thesis compiled successfully. Full log: $log_file"
echo "Cleaning up auxiliary files..."
if ! latexmk -bibtex-cond1 -c >>"$log_file" 2>&1; then
  tail -n 80 "$log_file" >&2
  echo "Error: Failed to clean auxiliary files. Full log: $log_file" >&2
  exit 1
fi
