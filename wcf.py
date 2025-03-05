import subprocess
import os

def main():
    # Membersihkan layar terminal
    os.system('clear' if os.name == 'posix' else 'cls')

    # Clone repositori
    print("Mengunduh direktori...")
    result = subprocess.run(['git', 'clone', 'https://github.com/Nizwara/wcx.git'])
    if result.returncode != 0:
        print("Gagal mengunduh direktori. Pastikan URL benar dan koneksi internet stabil.")
        exit(1)

    # Pindah ke direktori yang diunduh
    os.chdir('wcx')

    # Beri izin eksekusi pada menu
    print("Memberikan izin eksekusi pada menu...")
    result = subprocess.run(['chmod', '+x', 'menu'])
    if result.returncode != 0:
        print("Gagal memberikan izin eksekusi pada menu.")
        exit(1)

    # Jalankan menu
    print("Menjalankan menu...")
    result = subprocess.run(['./menu'])
    if result.returncode != 0:
        print("Gagal menjalankan menu.")
        exit(1)

if __name__ == "__main__":
    main()
