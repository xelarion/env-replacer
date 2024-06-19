#!/bin/bash

# Ensure the script is called with the correct number of arguments
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <env_file> <input_file_or_directory> [output_file]"
    exit 1
fi

ENV_FILE="$1"
INPUT="$2"
OUTPUT="${3:-$2}"

# Function to load environment variables from the .env file
load_env_vars() {
    unamestr=$(uname)
    if [ "$unamestr" = 'Linux' ]; then
        export $(grep -v '^#' "$ENV_FILE" | xargs -d '\n')
    elif [ "$unamestr" = 'FreeBSD' ] || [ "$unamestr" = 'Darwin' ]; then
        export $(grep -v '^#' "$ENV_FILE" | xargs -0)
    fi
}

# Load the environment variables from the .env file
load_env_vars

replace_vars() {
    local input_file="$1"
    local output_file="$2"

    # Use the environment variables loaded from the .env file
    while IFS='=' read -r var_name var_value; do
        [[ $var_name =~ ^#.*$ ]] && continue
        [[ -z $var_name ]] && continue
        var_value=$(eval echo \$$var_name)
        var_value=$(echo "$var_value" | sed -e 's/[\/&]/\\&/g')
        sed -i -e "s|\${$var_name}|$var_value|g" "$output_file"
    done < "$ENV_FILE"
}

process_file() {
    local file="$1"
    temp_file=$(mktemp)
    cp "$file" "$temp_file"
    replace_vars "$file" "$temp_file"
    mv "$temp_file" "$file"
}

if [ -d "$INPUT" ]; then
    find "$INPUT" -type f | while read -r file; do
        process_file "$file"
    done
elif [ -f "$INPUT" ]; then
    temp_file=$(mktemp)
    cp "$INPUT" "$temp_file"
    replace_vars "$INPUT" "$temp_file"
    mv "$temp_file" "$OUTPUT"
else
    echo "Error: $INPUT is not a valid file or directory."
    exit 1
fi
