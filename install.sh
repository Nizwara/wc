#!/bin/bash

# Membersihkan layar terminal
clear

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
