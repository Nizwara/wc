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

    # Memberikan izin eksekusi pada semua file di direktori wcx
    print("Memberikan izin eksekusi pada semua file di direktori wcx...")
    for root, dirs, files in os.walk('wcx'):  # Tetap berada di direktori saat ini, tetapi operasi dilakukan di dalam 'wcx'
        for file in files:
            file_path = os.path.join(root, file)
            print(f"Memberikan izin eksekusi pada {file_path}...")
            result = subprocess.run(['chmod', '+x', file_path])
            if result.returncode != 0:
                print(f"Gagal memberikan izin eksekusi pada {file_path}.")
                exit(1)

    print("Semua file di direktori wcx telah diberikan izin eksekusi.")

if __name__ == "__main__":
    main()
