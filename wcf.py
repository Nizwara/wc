import subprocess
import os
import sys

def main():
    # Membersihkan layar terminal
    os.system('clear' if os.name == 'posix' else 'cls')

    # URL file install.sh
    url = "https://raw.githubusercontent.com/Nizwara/wcx/main/install.sh"
    output_file = "install.sh"

    # Unduh install.sh
    print("Mengunduh install.sh...")
    try:
        subprocess.run(['wget', '-O', output_file, '-q', url], check=True)
    except subprocess.CalledProcessError:
        print("Gagal mengunduh install.sh. Pastikan URL benar dan koneksi internet stabil.")
        sys.exit(1)

    # Beri izin eksekusi pada install.sh
    print("Memberikan izin eksekusi pada install.sh...")
    try:
        subprocess.run(['chmod', '+x', output_file], check=True)
    except subprocess.CalledProcessError:
        print("Gagal memberikan izin eksekusi pada install.sh.")
        sys.exit(1)

    # Jalankan install.sh
    print("Menjalankan install.sh...")
    try:
        subprocess.run([f'./{output_file}'], check=True)
    except subprocess.CalledProcessError:
        print("Gagal menjalankan install.sh.")
        sys.exit(1)

    # Setelah install.sh selesai, jalankan ./menu
    print("Menjalankan menu...")
    try:
        subprocess.run(['./wcx/menu'], check=True)  # Sesuaikan path ke menu
    except subprocess.CalledProcessError:
        print("Gagal menjalankan menu.")
        sys.exit(1)

if __name__ == "__main__":
    main()
