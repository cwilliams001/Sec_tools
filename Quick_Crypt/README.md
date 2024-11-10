# Quick-Crypt

Quick-Crypt is a fast and secure file encryption and decryption tool written in Python. It provides an easy-to-use command-line interface for encrypting and decrypting files and directories.

```ascii
  ____        _      _    ______                 _   
 / __ \      (_)    | |  / _____)               | |  
| |  | |_   _ _  ___| |_| /     _ __ _   _ _ __ | |_ 
| |  | | | | | |/ __| __| |    | '__| | | | '_ \| __|
| |__| | |_| | | (__| |_| \____| |  | |_| | |_) | |_ 
 \___\_\\__,_|_|\___|\__)\_____)_|   \__, | .__/ \__|
                                      __/ | |        
                                     |___/|_|        
```

## Features

- Encrypt and decrypt individual files
- Encrypt and decrypt entire directories
- Uses strong AES256 encryption
- Password-based encryption
- Progress bar for file operations
- Tab completion for file paths
- User-friendly command-line interface

## Requirements

- Python 3.6+
- Required Python packages:
  - gnupg
  - tqdm

## Installation

1. Clone this repository or download the script.
2. Install the required packages:

```bash
pip install gnupg tqdm
```

## Usage

Run the script:

```bash
python quick-crypt.py
```

Follow the on-screen menu to:

1. Encrypt a file or directory
2. Decrypt a file or directory
3. View help
4. Exit the program

When prompted, enter the path to the file or directory you want to process. You can use tab completion for file paths and '~' to represent your home directory.

## Security Note

This tool uses symmetric encryption with a password. Always use strong, unique passwords and keep them secure. The security of your encrypted files depends on the strength of your password.
