#!/usr/bin/env bash
set -euo pipefail

readonly PART_SIZE=$((95 * 1024 * 1024))

merff(){
  local -a first_parts parts
  local first_part file prefix temp i expected

  mapfile -d '' -t first_parts < <(find data/output \
    -type f \
    -name '*.zstd.tif.part-0000' \
    -print0)
  printf 'Found %d file(s) to merge.\n\n' "${#first_parts[@]}"

  for first_part in "${first_parts[@]}"; do
    file=${first_part%.part-0000}
    prefix="$file.part-"
    temp="$file.merging"

    if [[ -e $file || -e $temp ]]; then
      printf 'Refusing to overwrite: %s\n' "$file" >&2
      exit 1
    fi

    parts=("$prefix"*)
    for i in "${!parts[@]}"; do
      expected=$(printf '%s%04d' "$prefix" "$i")
      if [[ ${parts[i]} != "$expected" ]]; then
        printf 'Missing or invalid part: %s\n' "$expected" >&2
        exit 1
      fi
    done

    printf 'Merging %s...\n' "$file"
    cat -- "${parts[@]}" > "$temp"
    mv -- "$temp" "$file"
    rm -- "${parts[@]}"
    printf 'Merged %s from %d parts\n' "$file" "${#parts[@]}"
  done

  printf '\nMerging complete.\n'
}

spliff(){
  mapfile -d '' -t files < <(find data/output \
    -type f \
    -name '*.zstd.tif' \
    -size +95M \
    -print0)
  printf 'Found %d file(s) to split.\n\n' "${#files[@]}"

  if ((${#files[@]} == 0)); then  
    exit 0
  fi
    
  for file in "${files[@]}"; do
    prefix="$file.part-"
  
    if compgen -G "$prefix*" >/dev/null; then
      printf 'Parts already exist: %s*\n' "$prefix" >&2
      exit 1
    fi
  
    printf 'Splitting %s...\n' "$file"
    split --bytes="$PART_SIZE" --numeric-suffixes=0 --suffix-length=4 "$file" "$prefix"
  
    parts=("$prefix"*)
    printf 'Verifying %s...\n' "$file"
    if ! cat "${parts[@]}" | cmp -s - "$file"; then
    printf 'Split verification failed: %s\n' "$file" >&2
    exit 1
    fi
  
    rm -- "$file"
    printf 'Split %s into %d parts\n' "$file" "${#parts[@]}"
  done

  printf '\nSplitting complete.\n'
}

case ${1:-} in
  split) spliff ;;
  merge) merff ;;
  *) exit 2 ;;
esac
