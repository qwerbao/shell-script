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

# Function to check if the file is tab-delimited
check_tab_separator() {
    for file in "$@"; do
        first_line=$(head -n 1 "$file")
        if [[ "$first_line" != *$'\t'* ]]; then
            echo "File $file is not a TSV file."
            exit 1
        fi
    done
}

# Function to clean columns and remove rows with empty values in specified columns
clean_columns() {
    temp=$(mktemp)
    awk -F'\t' -v col1="$3" -v col2="$4" 'NR == 1 || ($col1 != "" && $col2 != "")' "$1" > "$temp"
    awk -F'\t' -v col1="$3" -v col2="$4" 'NR==1 { print $col1 "\t" $col2; next } FNR==NR { count[$1]++; next } count[$1] >= 3 { print $col1 "\t" $col2 }' "$temp" "$temp" > "$2"
    rm "$temp"
}

# Function to clean the input file and create temporary files for each predictor
clean_file() {
    clean_columns "$1" "$2" 4 8  # GDP per capita vs. Cantril Ladder
    clean_columns "$1" "$3" 5 8  # Population vs. Cantril Ladder
    clean_columns "$1" "$4" 6 8  # Homicide Rate vs. Cantril Ladder
    clean_columns "$1" "$5" 7 8  # Life Expectancy vs. Cantril Ladder
}

