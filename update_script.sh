#!/bin/bash

# Warna
CYAN='\033[1;36m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
NC='\033[0m' # No Color

# Dapatkan path absolut ke direktori script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Fungsi untuk update otomatis dari GitHub
update_script() {
    echo -e "${YELLOW}Memeriksa pembaruan dari GitHub...${NC}"
    
    # Pindah ke direktori repository (direktori script)
    cd "$SCRIPT_DIR"
    
    # Lakukan git pull untuk mengambil perubahan terbaru
    git pull origin main  # Ganti "main" dengan branch yang sesuai jika berbeda
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Pembaruan berhasil!${NC}"
    else
        echo -e "${RED}Gagal melakukan pembaruan. Pastikan repository sudah di-clone dengan benar.${NC}"
    fi

    # Kembali ke direktori sebelumnya
    cd -
    
    # Tunggu input pengguna sebelum kembali ke menu
    read -rp "Tekan Enter untuk kembali ke menu..."
}

# Panggil fungsi update
update_script