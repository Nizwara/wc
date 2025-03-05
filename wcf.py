import subprocess
import os
import platform
import sys
import time

def install_tool(tool):
    os_type = platform.system().lower()
    print(f"Mendeteksi sistem operasi: {os_type}")

    if os_type == "linux":
        if "termux" in os.environ.get('PREFIX', '').lower():
            print(f"Menginstal {tool} di Termux...")
            subprocess.run(['pkg', 'install', '-y', tool], check=True)
        else:
            print(f"Menginstal {tool} di Linux...")
            subprocess.run(['sudo', 'apt-get', 'update'], check=True)
            subprocess.run(['sudo', 'apt-get', 'install', '-y', tool], check=True)
    elif os_type == "darwin":
        print(f"Menginstal {tool} di macOS...")
        subprocess.run(['brew', 'install', tool], check=True)
    elif os_type == "windows":
        print(f"Menginstal {tool} di Windows...")
        print(f"Silakan unduh dan instal {tool} secara manual:")
        if tool == "wget":
            print("https://eternallybored.org/misc/wget/")
        elif tool == "jq":
            print("https://stedolan.github.io/jq/")
        sys.exit(1)
    else:
        print(f"Sistem operasi {os_type} tidak didukung.")
        sys.exit(1)

def check_tool(tool):
    try:
        subprocess.run([tool, '--version'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
        print(f"{tool} sudah terinstal.")
        return True
    except subprocess.CalledProcessError:
        print(f"{tool} belum terinstal.")
        return False

def main():
    # Membersihkan layar terminal hanya di awal
    os.system('clear' if os.name == 'posix' else 'cls')

    # Periksa dan instal wget jika belum terinstal
    if not check_tool("wget"):
        install_tool("wget")

    # Periksa dan instal jq jika belum terinstal
    if not check_tool("jq"):
        install_tool("jq")

    # URL file wcf.py
    url = "https://raw.githubusercontent.com/Nizwara/wcx/main/wcf.py"
    output_file = "wcf.py"

    # Unduh wcf.py
    print("Mengunduh wcf.py...")
    time.sleep(1)  # Jeda 1 detik
    result = subprocess.run(['wget', '-O', output_file, '-q', url], capture_output=True, text=True)
    if result.returncode != 0:
        print("Gagal mengunduh wcf.py. Pastikan URL benar dan koneksi internet stabil.")
        sys.exit(1)

    # Beri izin eksekusi pada wcf.py
    print("Memberikan izin eksekusi pada wcf.py...")
    time.sleep(1)  # Jeda 1 detik
    result = subprocess.run(['chmod', '+x', output_file], capture_output=True, text=True)
    if result.returncode != 0:
        print("Gagal memberikan izin eksekusi pada wcf.py.")
        sys.exit(1)

    # Jalankan wcf.py
    print("Menjalankan wcf.py...")
    time.sleep(1)  # Jeda 1 detik
    result = subprocess.run(['python3', output_file], capture_output=True, text=True)
    if result.returncode != 0:
        print("Gagal menjalankan wcf.py.")
        sys.exit(1)

if __name__ == "__main__":
    main()
