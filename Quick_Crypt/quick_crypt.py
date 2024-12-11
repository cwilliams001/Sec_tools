#!/usr/bin/python3
import os
import base64
import gnupg
import getpass
import readline
import glob
import tarfile
from tqdm import tqdm

BANNER = r"""
██████  ██    ██ ██  ██████ ██   ██      ██████ ██████  ██    ██ ██████  ████████
██    ██ ██    ██ ██ ██      ██  ██      ██      ██   ██  ██  ██  ██   ██    ██    
██    ██ ██    ██ ██ ██      █████       ██      ██████    ████   ██████     ██    
██ ▄▄ ██ ██    ██ ██ ██      ██  ██      ██      ██   ██    ██    ██         ██    
██████   ██████  ██  ██████ ██   ██      ██████ ██   ██    ██    ██         ██    
    ▀▀                                                                             
"""

def print_banner():
    print(BANNER)
    print("File Encryption and Decryption Tool")
    print("-----------------------------------")

def expand_path(path):
    return os.path.expanduser(path)

def setup_readline():
    readline.set_completer_delims(' \t\n;')
    readline.parse_and_bind("tab: complete")
    readline.set_completer(lambda text, state: (glob.glob(text+'*')+[None])[state])

def compress_directory(dir_name):
    tar_name = f"{dir_name}.tar.gz"
    with tarfile.open(tar_name, mode='w:gz') as tar:
        tar.add(dir_name, arcname=os.path.basename(dir_name))
    return tar_name

def decompress_directory(file_name):
    if tarfile.is_tarfile(file_name):
        with tarfile.open(file_name, 'r:gz') as tar:
            tar.extractall(path=os.path.dirname(file_name))
        return True
    return False

def encrypt_file(file_name, password, output_file=None):
    with open(file_name, 'rb') as f:
        file_data = f.read()
    base64_data = base64.b64encode(file_data)
    gpg = gnupg.GPG()

    encryption_result = gpg.encrypt(base64_data, symmetric='AES256', passphrase=password, recipients=None)

    if not encryption_result.ok:
        raise Exception(f"Encryption failed: {encryption_result.status}")

    output_file = output_file or f"{file_name}.enc"
    with open(output_file, 'wb') as f:
        f.write(encryption_result.data)
    print(f"[+] File encrypted: {output_file}")

def decrypt_file(file_name, password, output_file=None):
    with open(file_name, 'rb') as f:
        file_data = f.read()
    gpg = gnupg.GPG()

    decryption_result = gpg.decrypt(file_data, passphrase=password)

    if not decryption_result.ok:
        raise Exception(f"Decryption failed: {decryption_result.status}")

    decoded_data = base64.b64decode(decryption_result.data)
    output_file = output_file or (file_name[:-4] if file_name.endswith('.enc') else f"{file_name}.dec")
    with open(output_file, 'wb') as f:
        f.write(decoded_data)
    print(f"[+] File decrypted: {output_file}")
    return output_file

def process_file_with_progress(action, file_name, password, output_file=None):
    file_size = os.path.getsize(file_name)
    with tqdm(total=file_size, unit='B', unit_scale=True, desc=f"{'Encrypting' if action == 'e' else 'Decrypting'}") as pbar:
        if action == 'e':
            encrypt_file(file_name, password, output_file)
        else:
            decrypted_file = decrypt_file(file_name, password, output_file)
            if decrypted_file is not None:
                file_size = os.path.getsize(decrypted_file)
        pbar.update(file_size)

def print_help():
    print("\nFile Encryption/Decryption Tool")
    print("-------------------------------")
    print("This tool allows you to encrypt and decrypt files and directories.")
    print("\nUsage:")
    print("1. Encrypt a file or directory")
    print("2. Decrypt a file or directory")
    print("3. Help")
    print("4. Exit")
    print("\nFor file operations, you can use tab completion when entering file paths.")

def main():
    setup_readline()
    print_banner()
    while True:
        print("\n--- File Encryption/Decryption Tool ---")
        print("1. Encrypt a file or directory")
        print("2. Decrypt a file or directory")
        print("3. Help")
        print("4. Exit")
        choice = input("\nEnter your choice (1-4): ")
        if choice == '1':
            action = 'e'
        elif choice == '2':
            action = 'd'
        elif choice == '3':
            print_help()
            continue
        elif choice == '4':
            print("Exiting the program. Goodbye!")
            break
        else:
            print("Invalid choice. Please try again.")
            continue
        file_path = input("Enter the path to the file or directory: ")
        file_path = expand_path(file_path)
        if not os.path.exists(file_path):
            print(f"[-] Error: {file_path} not found.")
            continue
        is_dir = os.path.isdir(file_path)
        if is_dir and action == 'e':
            file_path = compress_directory(file_path)
        password = getpass.getpass("Enter the password (min 8 characters): ")
        if len(password) < 8:
            print("[-] Error: Password must be at least 8 characters.")
            continue
        output_file = input("Enter the output file name (press Enter for default): ") or None
        try:
            decrypted_file = None
            if action == 'd':
                decrypted_file = process_file_with_progress(action, file_path, password, output_file)
                if is_dir:
                    if decompress_directory(decrypted_file):
                        print("[+] Directory decompressed successfully.")
                    else:
                        print("[-] Error: Failed to decompress directory.")
            else:
                process_file_with_progress(action, file_path, password, output_file)
        except Exception as e:
            print(f"[-] Error: {str(e)}")

if __name__ == "__main__":
    main()