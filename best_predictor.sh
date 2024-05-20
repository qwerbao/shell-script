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
    # Remove rows with empty values in specified columns
    awk -F'\t' -v col1="$3" -v col2="$4" 'NR == 1 || ($col1 != "" && $col2 != "")' "$1" > "$temp"
    # Keep rows where the country appears at least three times
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

# Function to calculate Pearson correlation and determine the best predictor
calculate_result() {
    max_corr=0
    max_file=""

    for file in "$@"; do
        pearson_corr=$(awk -F'\t' '{
            sum1+=$1; sum2+=$2; sum1sq+=$1*$1; sum2sq+=$2*$2; sum12+=$1*$2
        } END {
            if (NR < 3) {
                print "Insufficient data for calculation"
                exit 1
            }
            mean1=sum1/NR
            mean2=sum2/NR
            cov=sum12/NR-mean1*mean2
            sd1=sqrt((sum1sq/NR)-mean1*mean1)
            sd2=sqrt((sum2sq/NR)-mean2*mean2)
            if (sd1 == 0 || sd2 == 0) {
                print "Division by zero attempted"
                exit 1
            }
            print cov/(sd1*sd2)
        }' "$file")

        awk -F'\t' 'NR==1 { print "Mean correlation of " $1 " with Cantril ladder is", '"$pearson_corr"'; exit }' "$file"

        abs_corr=$(echo "$pearson_corr" | awk '{print ($1 < 0) ? -$1 : $1}')
        if (( $(awk -v corr="$abs_corr" -v max_corr="$max_corr" 'BEGIN {print (corr > max_corr)}') )); then
            max_corr="$pearson_corr"
            max_file="$file"
        fi
    done
    awk -F'\t' 'NR==1 { print "Most predictive mean correlation with the Cantril ladder is" $1 "(r =", '"$max_corr"' ")"; exit }' "$max_file"
}

# Main function
main() {
    clean_columns48=$(mktemp)  # Temporary file for GDP per capita vs. Cantril Ladder
    clean_columns58=$(mktemp)  # Temporary file for Population vs. Cantril Ladder
    clean_columns68=$(mktemp)  # Temporary file for Homicide Rate vs. Cantril Ladder
    clean_columns78=$(mktemp)  # Temporary file for Life Expectancy vs. Cantril Ladder

    check_file_exist "$1"
    check_tab_separator "$1"
    
    clean_file "$1" "$clean_columns48" "$clean_columns58" "$clean_columns68" "$clean_columns78"
  
    calculate_result "$clean_columns48" "$clean_columns58" "$clean_columns68" "$clean_columns78"

    rm "$clean_columns48" "$clean_columns58" "$clean_columns68" "$clean_columns78"
}

# Run the main function with the provided input file
main "$1"

