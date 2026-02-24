#!/bin/bash

if [ "$#" -eq 0 ]; then
    echo "Usage: ./txt2csv.sh path/to/your_files... (e.g., ../data/*.txt)"
    exit 1
fi

for INPUT_FILE in "$@"; do
    if [ ! -f "$INPUT_FILE" ]; then
        echo "Warning: File '$INPUT_FILE' not found! Skipping..."
        continue
    fi

    OUTPUT_FILE="${INPUT_FILE%.txt}.csv"
    NEW_HEADER='"id","sp_name","x","y","pseudo-absences"'

    echo "$NEW_HEADER" > "$OUTPUT_FILE"

    # Take the input file starting from line 2 (skipping the old broken header),
    # change all tabs to commas, and append it to the output file.
    tail -n +2 "$INPUT_FILE" | sed 's/\t/,/g' >> "$OUTPUT_FILE"

    if [ $? -ne 0 ]; then
        echo "Error: Failed to convert '$INPUT_FILE'."
        continue # Skip to the next file instead of aborting the whole script
    else
        gio trash "$INPUT_FILE"
    fi
done

exit 0