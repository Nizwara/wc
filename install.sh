#!/bin/bash

# Membersihkan layar terminal
clear

# Periksa apakah direktori wcx sudah ada
if [ -d "wcx" ]; then
    echo "Direktori 'wcx' sudah ada."
    read -p "Apakah Anda ingin menghapusnya dan melanjutkan? (y/n): " confirm
    if [ "$confirm" != "y" ]; then
        echo "Proses dibatalkan."
        exit 1
    fi
    echo "Menghapus direktori wcx yang sudah ada..."
    rm -rf wcx
fi

# Clone repositori
echo "Mengunduh direktori..."
if ! git clone https://github.com/Nizwara/wcx.git; then
    echo "Gagal mengunduh direktori. Pastikan URL benar dan koneksi internet stabil."
    exit 1
fi

# Memberikan izin eksekusi pada semua file di direktori wcx
echo "Memberikan izin eksekusi pada semua file di direktori wcx..."
find wcx -type f | while read -r file; do
    echo "Memberikan izin eksekusi pada $file..."
    if ! chmod +x "$file"; then
        echo "Gagal memberikan izin eksekusi pada $file."
        exit 1
    fi
done

echo "Semua file di direktori wcx telah diberikan izin eksekusi."
