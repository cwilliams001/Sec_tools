import os
import base64
import gnupg
import getpass



# Check if script is being run as root
if os.geteuid() != 0:
    print("[-] Error: Please run the script as root.")
    exit()

# Clear the terminal
os.system('cls' if os.name == 'nt' else 'clear')

# Print hacker-like ASCII art
print("""
 ____ ____ ____ ____ ____ ____ 
||c |||r |||y |||p |||t |||o ||
||__|||__|||__|||__|||__|||__||
|/__\|/__\|/__\|/__\|/__\|/__\|
""")

# Initialize GPG object
gpg = gnupg.GPG()

# Prompt user for action
action = input("[*] Enter 'e' to encrypt or 'd' to decrypt a file: ")

if action != 'e' and action != 'd':
   print("[-] Error: Invalid action. Please enter 'e' to encrypt or 'd' to decrypt.")
   exit()

# Prompt user for file name
file_name = input("[*] Enter the name of the file: ")
if not os.path.exists(file_name):
    print("[-] Error: File not found.")
    exit()

# Read file to be encrypted or decrypted
try:
    with open(file_name, 'rb') as f:
        file_data = f.read()
except FileNotFoundError:
    print("[-] Error: File not found.")
    exit()

# Encrypt file
if action == 'e':
    # Encode file data with base64
    base64_data = base64.b64encode(file_data)

    # Prompt user for password
    password = getpass.getpass("[*] Enter the password for encryption: ")
    if len(password) < 8:
        print("[-] Error: Password must be at least 8 characters.")
        exit()

    # Encrypt file data with GPG symmetric encryption
    try:
        encryption_result = gpg.encrypt(base64_data, symmetric='AES256', passphrase=password, recipients=None)
    except gnupg.errors.BadPassphrase:
        print("[-] Error: Invalid password.")
        exit()

    # Write encrypted data to file
    with open('encrypted_file.gpg', 'wb') as f:
        f.write(encryption_result.data)
    print("[+] File has been encrypted.")

# Decrypt file
elif action == 'd':
    # Prompt user for password
    password = getpass.getpass("[*] Enter the password for decryption: ")

    # Decrypt file data with GPG symmetric decryption
    try:
        decryption_result = gpg.decrypt(file_data, passphrase=password)
    except gnupg.errors.BadPassphrase:
        print("[-] Error: Invalid password.")
        exit()
    except gnupg.errors.DecryptionFailed:
        print("[-] Error: Decryption failed.")
        exit()

    # Decode base64 data
    decoded_data = base64.b64decode(decryption_result.data)

    # Write decrypted data to file
    with open('decrypted_file.txt', 'wb') as f:
        f.write(decoded_data)
    print("[+] File has been decrypted.")

