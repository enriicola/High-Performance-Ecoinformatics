#!/usr/bin/env bash
set -Eeuo pipefail

echo "TODO: to be implemented"
exit 0
# this script will help me execute a given command or other script with cpu/cores limits
# due to gpu2 host 32 cpu rule

usage() {
  printf 'Usage: %s --quota|--logical|--both COMMAND [ARGUMENTS...]\n' "$0" >&2
  printf '  --quota    cap the command at 32 CPU-equivalents\n' >&2
  printf '  --logical  restrict the command to logical CPUs 0-31\n' >&2
  printf '  --both     apply both restrictions\n' >&2
}

case "${1-}" in
  --quota|-c)
    mode=quota
    ;;
  --logical|-l)
    mode=logical
    ;;
  --both|-b)
    mode=both
    ;;
  *)
    usage
    exit 2
    ;;
esac
shift

if (($# == 0)); then
  usage
  exit 2
fi

case "$mode" in
  quota)
    exec systemd-run --user --quiet --scope --expand-environment=no \
      -p CPUQuota=3200% -- "$@"
    ;;
  logical)
    exec taskset --cpu-list 0-31 "$@"
    ;;
  both)
    exec systemd-run --user --quiet --scope --expand-environment=no \
      -p CPUQuota=3200% -- taskset --cpu-list 0-31 "$@"
    ;;
esac
