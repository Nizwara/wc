#!/bin/bash

# Unduh direktori atau file (contoh menggunakan git clone)
echo "Mengunduh direktori..."
git clone https://github.com/Nizwara/wcx.git

# Pindah ke direktori yang diunduh
cd wcx || exit

# Beri izin eksekusi pada file menu (jika diperlukan)
chmod +x menu

# Jalankan menu
echo "Menjalankan menu..."
./menu
