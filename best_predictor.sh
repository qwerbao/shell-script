#!/bin/bash
# Input validation 
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <input_file.tsv>"
    exit 1
fi

