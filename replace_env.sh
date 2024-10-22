#!/bin/bash
# https://github.com/xelarion/env-replacer

# Ensure the script is called with the correct number of arguments
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <env_file> <input_file_or_directory> [output_file]"
    exit 1
fi

ENV_FILE="$1"
INPUT="$2"
OUTPUT="${3:-}"  # Default to empty if not provided

# Function to get and set file permissions
manage_permissions() {
    local file="$1"
    local original_permissions

    original_permissions=$(stat -c "%a" "$file" 2>/dev/null || stat -f "%Lp" "$file")
    echo "$original_permissions"
}

# Function to replace variables in a file
replace_vars_in_file() {
    local input_file="$1"
    local output_file="$2"
    local original_permissions

    # Get original permissions
    original_permissions=$(manage_permissions "$input_file")

    # Replace placeholders with environment variable values
    while IFS='=' read -r var_name var_value || [ -n "$var_name" ]; do
        if [[ ! "$var_name" =~ ^# && -n "$var_name" ]]; then
            # Escape forward slashes and ampersands
            var_value=$(printf '%s\n' "$var_value" | sed -e 's/[\/&]/\\&/g')
            # Use sed for in-place replacement without causing filename issues
            if [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i "" "s|\${$var_name}|$var_value|g" "$output_file"
            else
                sed -i "s|\${$var_name}|$var_value|g" "$output_file"
            fi
        fi
    done < "$ENV_FILE"

    # Restore the original permissions
    chmod "$original_permissions" "$output_file"
}

# Function to process each file in a directory
process_directory() {
    local dir="$1"
    find "$dir" -type f | while read -r file; do
        replace_vars_in_file "$file" "$file"
    done
}

# Main logic
if [ -d "$INPUT" ]; then
    if [ -n "$OUTPUT" ]; then
        echo "Error: Cannot specify output file when input is a directory."
        exit 1
    fi
    # Process the directory
    process_directory "$INPUT"
elif [ -f "$INPUT" ]; then
    if [ -n "$OUTPUT" ]; then
        # Create a new file and replace vars
        cp "$INPUT" "$OUTPUT"  # Copy original file to new output file
        replace_vars_in_file "$INPUT" "$OUTPUT"
    else
        # Modify the original file in place
        replace_vars_in_file "$INPUT" "$INPUT"
    fi
else
    echo "Error: $INPUT is not a valid file or directory."
    exit 1
fi
