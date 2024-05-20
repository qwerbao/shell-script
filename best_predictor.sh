#!/bin/bash
# Input validation 
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <input_file.tsv>"
    exit 1
fi

# Function to check if the file exists
check_file_exist() {
    for file in "$@"; do
        if [ ! -f "$file" ]; then
            echo "Input file $file does not exist."
            exit 1
        fi
    done
}


