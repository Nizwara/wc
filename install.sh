#!/bin/bash

# Unduh direktori atau file (contoh menggunakan git clone)
echo "Mengunduh direktori..."
git clone https://github.com/Nizwara/wcx.git

# Beri izin eksekusi pada semua file di dalam direktori wcx
echo "Memberikan izin eksekusi pada semua file di direktori wcx..."
find wcx -type f -exec chmod +x {} \;

# Selesai
echo "Proses selesai. Izin eksekusi telah diberikan pada semua file di direktori wcx."
