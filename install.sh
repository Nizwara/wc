#!/bin/bash

# URL direktori GitHub (ganti dengan URL direktori yang ingin diunduh)
GITHUB_DIR_URL="https://github.com/Nizwara/wcx/tree/main"

# Direktori lokal untuk menyimpan file yang diunduh
DOWNLOAD_DIR="downloads"

# Buat direktori unduhan jika belum ada
mkdir -p "$DOWNLOAD_DIR"

# Unduh semua file di direktori menggunakan wget
wget -r -np -nH --cut-dirs=3 -R "index.html*" -P "$DOWNLOAD_DIR" "$GITHUB_DIR_URL"

# Beri izin eksekusi pada file yang diunduh (jika diperlukan)
chmod +x "$DOWNLOAD_DIR"/*

echo "Semua file telah diunduh ke direktori: $DOWNLOAD_DIR"
