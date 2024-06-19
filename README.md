# env-replacer

`env-replacer` is a command-line tool designed to streamline the process of replacing environment variables in configuration files. It reads variables from a `.env` file and substitutes placeholders within specified files or directories, ensuring smooth configuration management.

## Features

- Efficiently replaces `${VAR_NAME}` placeholders with corresponding values from `.env`.
- Supports recursive replacement for all files within a directory and its subdirectories.
- Option to output to a specified file, leaving the original file unchanged.
- Simple and lightweight, facilitating easy integration into deployment and configuration workflows.

## Usage

### Requirements

- Bash (Bourne Again SHell) available on Unix-like systems.

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/yourusername/env-replacer.git
   cd env-replacer
   ```

2. Make sure `replace_env.sh` has execute permissions:

   ```bash
   chmod +x replace_env.sh
   ```

### Examples

Assume your `.env` file contains the following variables:

```plaintext
# .env

DB_PASSWORD=mysecretpassword
API_URL=https://api.example.com
```

#### 1. Single File Replacement

To replace variables in a single file (`configs/app.conf`):

```bash
./replace_env.sh .env configs/app.conf
```

Contents of `configs/app.conf` before:

```plaintext
# Example config file
db_password=${DB_PASSWORD}
api_url=${API_URL}
```

After running `replace_env.sh`:

```plaintext
# Example config file
db_password=mysecretpassword
api_url=https://api.example.com
```

#### 2. Directory Recursive Replacement

Assume the following directory structure (`configs/`):

```
configs/
├── app.conf
└── nested/
    ├── config1.conf
    └── config2.conf
```

To replace variables recursively in the `configs/` directory:

```bash
./replace_env.sh .env configs
```

After running `replace_env.sh`, contents of `configs/app.conf`, `configs/nested/config1.conf`, and `configs/nested/config2.conf` will be updated accordingly.

#### 3. Specify Output File

To specify an output file (`configs/app.conf` to `configs/app_updated.conf`):

```bash
./replace_env.sh .env configs/app.conf configs/app_updated.conf
```

Contents of `configs/app.conf` before running `replace_env.sh`:

```plaintext
# Example config file
db_password=${DB_PASSWORD}
api_url=${API_URL}
```

After running `replace_env.sh`:

```plaintext
# Example config file
db_password=mysecretpassword
api_url=https://api.example.com
```

Contents of `configs/app_updated.conf` after running `replace_env.sh` will be the same as `configs/app.conf`, while `configs/app.conf` remains unchanged.

### License

This project is licensed under the MIT License - see the LICENSE file for details.

### Contributing

Contributions are welcome! Please fork the repository and submit a pull request with your improvements.
