#!/bin/bash

# Warna untuk output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# File output
AKUN_FILE="akun.txt"

# Fungsi untuk input akun baru
input_akun() {
    echo -e "${YELLOW}Masukkan Email Cloudflare (AUTH_EMAIL):${NC}"
    read AUTH_EMAIL
    echo -e "${YELLOW}Masukkan Global API Key (AUTH_KEY):${NC}"
    read AUTH_KEY
    echo -e "${YELLOW}Masukkan Account ID (ACCOUNT_ID):${NC}"
    read ACCOUNT_ID
    echo -e "${YELLOW}Masukkan Nama Anda (YOUR_NAME):${NC}"
    read YOUR_NAME
    echo -e "${YELLOW}Masukkan Zone ID (ZONE_ID):${NC}"
    read ZONE_ID

    # Menulis konfigurasi ke file akun.txt
    cat <<EOL > "$AKUN_FILE"
AUTH_EMAIL="$AUTH_EMAIL"
AUTH_KEY="$AUTH_KEY"
ACCOUNT_ID="$ACCOUNT_ID"
YOUR_NAME="$YOUR_NAME"
ZONE_ID="$ZONE_ID"
EOL

    echo -e "${GREEN}File akun.txt berhasil dibuat dengan konfigurasi berikut:${NC}"
    cat "$AKUN_FILE"
}

# Fungsi untuk edit akun yang sudah ada
edit_akun() {
    if [ ! -f "$AKUN_FILE" ]; then
        echo -e "${RED}File $AKUN_FILE tidak ditemukan. Pastikan file akun.txt sudah ada.${NC}"
        return
    fi

    echo -e "${YELLOW}Isi file akun.txt saat ini:${NC}"
    cat "$AKUN_FILE"

    echo -e "\n${YELLOW}Masukkan Zone ID yang baru:${NC}"
    read NEW_ZONE_ID

    sed -i "s/^ZONE_ID=\".*\"/ZONE_ID=\"$NEW_ZONE_ID\"/" "$AKUN_FILE"

    echo -e "${GREEN}File akun.txt berhasil diperbarui:${NC}"
    cat "$AKUN_FILE"
}

# Fungsi untuk menampilkan isi file akun.txt
tampil_akun() {
    if [ ! -f "$AKUN_FILE" ]; then
        echo -e "${RED}File $AKUN_FILE tidak ditemukan.${NC}"
        return
    fi

    echo -e "${YELLOW}Isi file akun.txt saat ini:${NC}"
    cat "$AKUN_FILE"
    read -p "Tekan Enter untuk kembali ke menu..."
}

# Main loop
while true; do
    clear
    echo -e "${CYAN}=====================${NC}"
    echo -e "${GREEN}=== Menu Opsi ===${NC}"
    echo -e "${CYAN}=====================${NC}"
    echo -e "${YELLOW}1. Buat akun baru${NC}"
    echo -e "${YELLOW}2. Edit akun yang sudah ada${NC}"
    echo -e "${YELLOW}3. Tampilkan isi file akun.txt${NC}"
    echo -e "${RED}0. Keluar${NC}"

    # Meminta input opsi
    echo -e "${GREEN}Pilih opsi [1/2/3/0]:${NC}"
    read pilihan

    # Menjalankan sesuai pilihan
    case $pilihan in
        1)
            input_akun
            read -p "Tekan Enter untuk kembali ke menu..."
            ;;
        2)
            edit_akun
            read -p "Tekan Enter untuk kembali ke menu..."
            ;;
        3)
            tampil_akun
            ;;
        0)
            echo -e "${RED}Terima kasih! Keluar dari program.${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Opsi tidak valid. Silakan pilih lagi.${NC}"
            read -p "Tekan Enter untuk melanjutkan..."
            ;;
    esac
done
