#!/bin/bash

# Function to set up test environment
setup() {
    # Create a temporary directory for testing
    TMP_DIR=$(mktemp -d)
    cp replace_env.sh "$TMP_DIR/"
    cd "$TMP_DIR"
}

# Function to clean up test environment
teardown() {
    # Remove the temporary directory after tests
    rm -rf "$TMP_DIR"
}

# Function to run a single test
run_test() {
    local description="$1"
    local command="$2"
    local expected="$3"
    local result

    echo "Running test: $description"
    result=$(eval "$command")
    if [ "$result" == "$expected" ]; then
        echo "Test passed"
    else
        echo "Test failed"
        echo "Expected: $expected"
        echo "Got: $result"
        exit 1
    fi
}

# Set up the test environment
setup

# Test 1: Single file replacement
echo "DB_PASSWORD=mysecretpassword" > .env
echo "API_URL=https://api.example.com" >> .env

mkdir -p configs
echo "db_password=\${DB_PASSWORD}" > configs/app.conf
echo "api_url=\${API_URL}" >> configs/app.conf

./replace_env.sh .env configs/app.conf

run_test "Single file replacement - db_password" "grep -o 'db_password=mysecretpassword' configs/app.conf" "db_password=mysecretpassword"
run_test "Single file replacement - api_url" "grep -o 'api_url=https://api.example.com' configs/app.conf" "api_url=https://api.example.com"

# Test 2: Directory recursive replacement
echo "DB_PASSWORD=mysecretpassword" > .env
echo "API_URL=https://api.example.com" >> .env

mkdir -p configs/nested
echo "db_password=\${DB_PASSWORD}" > configs/app.conf
echo "api_url=\${API_URL}" >> configs/app.conf
echo "db_password=\${DB_PASSWORD}" > configs/nested/config1.conf
echo "api_url=\${API_URL}" > configs/nested/config2.conf

./replace_env.sh .env configs

run_test "Directory recursive replacement - app.conf db_password" "grep -o 'db_password=mysecretpassword' configs/app.conf" "db_password=mysecretpassword"
run_test "Directory recursive replacement - app.conf api_url" "grep -o 'api_url=https://api.example.com' configs/app.conf" "api_url=https://api.example.com"
run_test "Directory recursive replacement - config1.conf db_password" "grep -o 'db_password=mysecretpassword' configs/nested/config1.conf" "db_password=mysecretpassword"
run_test "Directory recursive replacement - config2.conf api_url" "grep -o 'api_url=https://api.example.com' configs/nested/config2.conf" "api_url=https://api.example.com"

# Test 3: Specify output file
echo "DB_PASSWORD=mysecretpassword" > .env
echo "API_URL=https://api.example.com" >> .env

mkdir -p configs
echo "db_password=\${DB_PASSWORD}" > configs/app.conf
echo "api_url=\${API_URL}" >> configs/app.conf

./replace_env.sh .env configs/app.conf configs/app_updated.conf

run_test "Specify output file - app_updated.conf db_password" "grep -o 'db_password=mysecretpassword' configs/app_updated.conf" "db_password=mysecretpassword"
run_test "Specify output file - app_updated.conf api_url" "grep -o 'api_url=https://api.example.com' configs/app_updated.conf" "api_url=https://api.example.com"
run_test "Specify output file - original app.conf db_password" "grep -o 'db_password=\${DB_PASSWORD}' configs/app.conf" "db_password=\${DB_PASSWORD}"
run_test "Specify output file - original app.conf api_url" "grep -o 'api_url=\${API_URL}' configs/app.conf" "api_url=\${API_URL}"

# Test 4: Safe replacement example
echo "DB_PASSWORD=mysecretpassword" > .env
echo "API_URL=https://api.example.com" >> .env

mkdir -p configs
echo "db_password=\${DB_PASSWORD}" > configs/app_safe.conf
echo "api_url=\${API_URL}" >> configs/app_safe.conf
echo "other_var=\${OTHER_VAR}" >> configs/app_safe.conf

./replace_env.sh .env configs/app_safe.conf

run_test "Safe replacement - db_password" "grep -o 'db_password=mysecretpassword' configs/app_safe.conf" "db_password=mysecretpassword"
run_test "Safe replacement - api_url" "grep -o 'api_url=https://api.example.com' configs/app_safe.conf" "api_url=https://api.example.com"
run_test "Safe replacement - other_var" "grep -o 'other_var=\${OTHER_VAR}' configs/app_safe.conf" "other_var=\${OTHER_VAR}"

# Test 5: .env without a newline at the end
echo "DB_PASSWORD=mysecretpassword" > .env
echo "API_URL=https://api.example.com" >> .env
# No trailing newline, use printf to avoid the newline
printf "LAST_VAR=value" >> .env

mkdir -p configs
echo "db_password=\${DB_PASSWORD}" > configs/app_no_newline.conf
echo "api_url=\${API_URL}" >> configs/app_no_newline.conf
echo "last_var=\${LAST_VAR}" >> configs/app_no_newline.conf

./replace_env.sh .env configs/app_no_newline.conf

run_test "No newline at end of .env - db_password" "grep -o 'db_password=mysecretpassword' configs/app_no_newline.conf" "db_password=mysecretpassword"
run_test "No newline at end of .env - api_url" "grep -o 'api_url=https://api.example.com' configs/app_no_newline.conf" "api_url=https://api.example.com"
run_test "No newline at end of .env - last_var" "grep -o 'last_var=value' configs/app_no_newline.conf" "last_var=value"

# Clean up the test environment
teardown

echo "All tests passed"
