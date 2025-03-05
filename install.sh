#!/bin/bash

# URL repositori GitHub (ganti dengan URL repositori yang ingin diunduh)
GITHUB_REPO_URL="https://github.com/Nizwara/wcx.git"

# Direktori lokal untuk menyimpan repositori yang diunduh
DOWNLOAD_DIR="downloads"

# Buat direktori unduhan jika belum ada
mkdir -p "$DOWNLOAD_DIR"

# Pindah ke direktori unduhan
cd "$DOWNLOAD_DIR" || exit

# Clone repositori GitHub
git clone "$GITHUB_REPO_URL" .

# Beri izin eksekusi pada file yang memerlukannya (misalnya, file Python)
chmod +x *

echo "Repositori telah diunduh ke direktori: $DOWNLOAD_DIR"
