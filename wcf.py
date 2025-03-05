import subprocess
import os
import platform
import sys

def install_jq():
    """Menginstal jq sesuai dengan sistem operasi."""
    os_type = platform.system().lower()
    print(f"Mendeteksi sistem operasi: {os_type}")

    if os_type == "linux":
        # Cek apakah ini Termux
        if "termux" in os.environ.get('PREFIX', '').lower():
            print("Menginstal jq di Termux...")
            subprocess.run(['pkg', 'install', '-y', 'jq'], check=True)
        else:
            print("Menginstal jq di Linux...")
            subprocess.run(['sudo', 'apt-get', 'update'], check=True)
            subprocess.run(['sudo', 'apt-get', 'install', '-y', 'jq'], check=True)
    elif os_type == "darwin":  # macOS
        print("Menginstal jq di macOS...")
        subprocess.run(['brew', 'install', 'jq'], check=True)
    elif os_type == "windows":
        print("Menginstal jq di Windows...")
        print("Silakan unduh dan instal jq secara manual dari https://stedolan.github.io/jq/")
        sys.exit(1)
    else:
        print(f"Sistem operasi {os_type} tidak didukung.")
        sys.exit(1)

def check_jq():
    """Memeriksa apakah jq sudah terinstal."""
    try:
        subprocess.run(['jq', '--version'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
        print("jq sudah terinstal.")
        return True
    except subprocess.CalledProcessError:
        print("jq belum terinstal.")
        return False

def main():
    # Membersihkan layar terminal
    os.system('clear' if os.name == 'posix' else 'cls')

    # Periksa apakah jq sudah terinstal
    if not check_jq():
        install_jq()

    # URL file install.sh
    url = "https://raw.githubusercontent.com/Nizwara/wcx/main/install.sh"
    output_file = "install.sh"

    # Unduh install.sh
    print("Mengunduh install.sh...")
    result = subprocess.run(['wget', '-O', output_file, '-q', url])
    if result.returncode != 0:
        print("Gagal mengunduh install.sh. Pastikan URL benar dan koneksi internet stabil.")
        sys.exit(1)

    # Beri izin eksekusi pada install.sh
    print("Memberikan izin eksekusi pada install.sh...")
    result = subprocess.run(['chmod', '+x', output_file])
    if result.returncode != 0:
        print("Gagal memberikan izin eksekusi pada install.sh.")
        sys.exit(1)

    # Jalankan install.sh
    print("Menjalankan install.sh...")
    result = subprocess.run([f'./{output_file}'])
    if result.returncode != 0:
        print("Gagal menjalankan install.sh.")
        sys.exit(1)

    # Setelah install.sh selesai, jalankan ./menu
    print("Menjalankan menu...")
    result = subprocess.run(['./wcx/menu'])  # Sesuaikan path ke menu
    if result.returncode != 0:
        print("Gagal menjalankan menu.")
        sys.exit(1)

if __name__ == "__main__":
    main()
