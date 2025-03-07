import subprocess
import os
import shutil

def main():
    # Membersihkan layar terminal
    os.system('clear' if os.name == 'posix' else 'cls')

    # Tentukan direktori tujuan
    TARGET_DIR = "/usr/bin/wcx"

    # Hapus direktori wcx jika sudah ada
    if os.path.exists(TARGET_DIR):
        print(f"Menghapus direktori {TARGET_DIR} yang sudah ada...")
        try:
            shutil.rmtree(TARGET_DIR)
        except Exception as e:
            print(f"Gagal menghapus direktori {TARGET_DIR}: {e}")
            exit(1)

    # Clone repositori ke direktori tujuan
    print(f"Mengunduh direktori ke {TARGET_DIR}...")
    result = subprocess.run(['git', 'clone', 'https://github.com/Nizwara/wcx.git', TARGET_DIR])
    if result.returncode != 0:
        print("Gagal mengunduh direktori. Pastikan URL benar dan koneksi internet stabil.")
        exit(1)

    # Memberikan izin eksekusi pada semua file di direktori wcx
    print(f"Memberikan izin eksekusi pada semua file di {TARGET_DIR}...")
    for root, dirs, files in os.walk(TARGET_DIR):
        for file in files:
            file_path = os.path.join(root, file)
            print(f"Memberikan izin eksekusi pada {file_path}...")
            result = subprocess.run(['chmod', '+x', file_path])
            if result.returncode != 0:
                print(f"Gagal memberikan izin eksekusi pada {file_path}.")
                exit(1)

    print(f"Semua file di {TARGET_DIR} telah diberikan izin eksekusi.")

if __name__ == "__main__":
    main()
