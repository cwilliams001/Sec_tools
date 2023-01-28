# GPG File Crypt

GPG File Crypt is a command-line tool for encrypting and decrypting files using the Gnu Privacy Guard (GPG) library. It uses symmetric AES-256 encryption and requires a password for encryption and decryption.

## Usage

1. Run the script as root
2. Choose 'e' to encrypt a file or 'd' to decrypt a file
3. Enter the name of the file to be encrypted or decrypted
4. Enter a password for encryption or decryption (minimum 8 characters)

The encrypted file will be saved as 'encrypted_file.gpg' and the decrypted file will be saved as 'decrypted_file.txt'

## Dependencies
- os
- base64
- gnupg
- getpass

## Note

This script will only work on Windows if you have the `cls` command installed,  otherwise you can remove the os.system('cls' if os.name == 'nt' else 'clear') command or replace it with os.system('clear') if you are running the script on a unix-based system.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
