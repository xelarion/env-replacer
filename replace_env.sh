#!/bin/bash

# Ensure the script is called with the correct number of arguments
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <env_file> <input_file_or_directory> [output_file]"
    exit 1
fi

ENV_FILE="$1"
INPUT="$2"
OUTPUT="${3:-$2}"

# Function to replace variables in the specified file
replace_vars() {
    local input_file="$1"
    local output_file="$2"

    # Create a temporary file for safe replacement
    local temp_file
    temp_file=$(mktemp)
    cp "$input_file" "$temp_file"

    # Replace placeholders with environment variable values
    while IFS='=' read -r var_name var_value || [ -n "$var_name" ]; do
        if [[ ! "$var_name" =~ ^# && -n "$var_name" ]]; then
            # Escape forward slashes and ampersands
            var_value=$(echo "$var_value" | sed -e 's/[\/&]/\\&/g')
            sed -i -e "s|\${$var_name}|$var_value|g" "$temp_file"
        fi
    done < "$ENV_FILE"

    mv "$temp_file" "$output_file"
}

# Function to process each file in a directory
process_directory() {
    local dir="$1"
    find "$dir" -type f | while read -r file; do
        replace_vars "$file" "$file"
    done
}

# Determine if input is a file or directory and process accordingly
if [ -d "$INPUT" ]; then
    process_directory "$INPUT"
elif [ -f "$INPUT" ]; then
    replace_vars "$INPUT" "$OUTPUT"
else
    echo "Error: $INPUT is not a valid file or directory."
    exit 1
fi
