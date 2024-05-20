# shell-script

# Best Predictor Shell Script

This repository contains a shell script `best_predictor.sh` that identifies the best predictor of Cantril-ladder life-satisfaction scores based on various factors such as GDP per capita, Population, Homicide Rate per 100,000, and Life Expectancy.

## Table of Contents

- [Description](#description)
- [Requirements](#requirements)
- [Usage](#usage)
- [Script Details](#script-details)
- [Development](#development)
- [License](#license)

## Description

The `best_predictor.sh` script processes an input TSV file containing Cantril-ladder life-satisfaction scores and other predictors. It calculates the Pearson correlation for each predictor with the Cantril-ladder scores and identifies the predictor with the highest mean absolute correlation.

## Requirements

- Bash shell
- awk
- mktemp
- bc

## Usage

To use the script, run the following command:

```sh
./best_predictor.sh <input_file.tsv>

