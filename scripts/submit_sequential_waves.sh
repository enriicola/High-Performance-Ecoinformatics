#!/usr/bin/env bash
set -Eeuo pipefail

readonly REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly WORKER_SCRIPT="$REPO_ROOT/scripts/sbatch.sh"
readonly FIRST_SPECIES=1
readonly LAST_SPECIES=167
readonly WAVE_SIZE=3
readonly CAMPAIGN_ID="$(date +%Y%m%d_%H%M%S)"
readonly MANIFEST="$REPO_ROOT/logs/campaign_${CAMPAIGN_ID}.tsv"

cd "$REPO_ROOT"
mkdir -p logs

printf 'wave\tarray_job_id\tspecies_indices\tdependency\n' > "$MANIFEST"

previous_job_id=""
submitted_job_ids=()
wave=0

for ((first = FIRST_SPECIES; first <= LAST_SPECIES; first += WAVE_SIZE)); do
  last=$((first + WAVE_SIZE - 1))
  if ((last > LAST_SPECIES)); then
    last=$LAST_SPECIES
  fi

  wave=$((wave + 1))
  array_spec="$first-$last"
  sbatch_args=(
    --parsable
    --array="$array_spec"
    --job-name="biomod_w${wave}"
  )

  dependency=""
  if [[ -n "$previous_job_id" ]]; then
    dependency="afterok:$previous_job_id"
    sbatch_args+=(
      --dependency="$dependency"
      --kill-on-invalid-dep=yes
    )
  fi

  if ! submission=$(sbatch "${sbatch_args[@]}" "$WORKER_SCRIPT"); then
    printf 'Failed to submit wave %d; cancelling %d submitted waves\n' \
      "$wave" "${#submitted_job_ids[@]}" >&2
    if ((${#submitted_job_ids[@]} > 0)); then
      scancel "${submitted_job_ids[@]}"
    fi
    exit 1
  fi

  job_id=${submission%%;*}
  if [[ ! "$job_id" =~ ^[0-9]+$ ]]; then
    printf 'Unexpected sbatch response: %s\n' "$submission" >&2
    if ((${#submitted_job_ids[@]} > 0)); then
      scancel "${submitted_job_ids[@]}"
    fi
    exit 1
  fi

  submitted_job_ids+=("$job_id")
  printf '%d\t%s\t%s\t%s\n' \
    "$wave" "$job_id" "$array_spec" "${dependency:-none}" \
    >> "$MANIFEST"
  printf 'Wave %d: job %s, species %s, dependency %s\n' \
    "$wave" "$job_id" "$array_spec" "${dependency:-none}"

  previous_job_id=$job_id
done

printf 'Submitted %d waves for %d species. Manifest: %s\n' \
  "$wave" "$LAST_SPECIES" "$MANIFEST"
