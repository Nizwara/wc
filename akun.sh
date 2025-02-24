#!/bin/bash

# Warna untuk output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# File output
AKUN_FILE="akun.txt"

# Fungsi untuk membersihkan layar
clear_screen() {
    clear
}

# Fungsi untuk menampilkan menu opsi
show_menu() {
    clear_screen
    echo -e "${CYAN}=====================${NC}"
    echo -e "${GREEN}=== Menu Opsi ===${NC}"
    echo -e "${CYAN}=====================${NC}"
    echo -e "${YELLOW}1. Buat akun baru${NC}"
    echo -e "${YELLOW}2. Edit akun yang sudah ada${NC}"
    echo -e "${YELLOW}3. Tampilkan isi file akun.txt${NC}"
    echo -e "${RED}0. Keluar${NC}"
}

# Fungsi untuk input akun baru
input_akun() {
    # Meminta input dari pengguna untuk membuat file akun.txt
    echo -e "${YELLOW}Masukkan Email Cloudflare (AUTH_EMAIL):${NC}"
    read -r AUTH_EMAIL
    if [ -z "$AUTH_EMAIL" ]; then
        echo -e "${RED}Email tidak boleh kosong!${NC}"
        return
    fi

    echo -e "${YELLOW}Masukkan Global API Key (AUTH_KEY):${NC}"
    read -r AUTH_KEY
    if [ -z "$AUTH_KEY" ]; then
        echo -e "${RED}Global API Key tidak boleh kosong!${NC}"
        return
    fi

    echo -e "${YELLOW}Masukkan Account ID (ACCOUNT_ID):${NC}"
    read -r ACCOUNT_ID
    if [ -z "$ACCOUNT_ID" ]; then
        echo -e "${RED}Account ID tidak boleh kosong!${NC}"
        return
    fi

    echo -e "${YELLOW}Masukkan Nama Anda (YOUR_NAME):${NC}"
    read -r YOUR_NAME
    if [ -z "$YOUR_NAME" ]; then
        echo -e "${RED}Nama tidak boleh kosong!${NC}"
        return
    fi

    echo -e "${YELLOW}Masukkan Zone ID (ZONE_ID):${NC}"
    read -r ZONE_ID
    if [ -z "$ZONE_ID" ]; then
        echo -e "${RED}Zone ID tidak boleh kosong!${NC}"
        return
    fi

    # Menulis konfigurasi ke file akun.txt
    cat <<EOL > "$AKUN_FILE"
AUTH_EMAIL="$AUTH_EMAIL"
AUTH_KEY="$AUTH_KEY"
ACCOUNT_ID="$ACCOUNT_ID"
YOUR_NAME="$YOUR_NAME"
ZONE_ID="$ZONE_ID"
EOL

    # Konfirmasi
    echo -e "${GREEN}File akun.txt berhasil dibuat dengan konfigurasi berikut:${NC}"
    cat "$AKUN_FILE" | while IFS= read -r line; do
        echo -e "${YELLOW}$line${NC}"
    done

    # Menunggu untuk kembali ke menu
    read -rp "Tekan Enter untuk kembali ke menu..."
}

# Fungsi untuk edit akun yang sudah ada
edit_akun() {
    # Mengecek apakah file akun.txt ada
    if [ ! -f "$AKUN_FILE" ]; then
        echo -e "${RED}File $AKUN_FILE tidak ditemukan. Pastikan file akun.txt sudah ada.${NC}"
        read -rp "Tekan Enter untuk kembali ke menu..."
        return
    fi

    # Menampilkan isi file akun.txt
    echo -e "${YELLOW}Isi file akun.txt saat ini:${NC}"
    cat "$AKUN_FILE" | while IFS= read -r line; do
        echo -e "${GREEN}$line${NC}"
    done

    # Meminta input zona ID baru dari pengguna
    echo -e "\n${YELLOW}Masukkan Zone ID yang baru:${NC}"
    read -r NEW_ZONE_ID
    if [ -z "$NEW_ZONE_ID" ]; then
        echo -e "${RED}Zone ID tidak boleh kosong!${NC}"
        return
    fi

    # Mengedit file akun.txt untuk mengganti nilai ZONE_ID
    sed -i "s/^ZONE_ID=\".*\"/ZONE_ID=\"$NEW_ZONE_ID\"/" "$AKUN_FILE"

    # Menampilkan hasil setelah pengeditan
    echo -e "\n${GREEN}File akun.txt berhasil diperbarui. Isi file sekarang:${NC}"
    cat "$AKUN_FILE" | while IFS= read -r line; do
        echo -e "${YELLOW}$line${NC}"
    done

    # Menunggu untuk kembali ke menu
    read -rp "Tekan Enter untuk kembali ke menu..."
}

# Fungsi untuk menampilkan isi file akun.txt
tampil_akun() {
    if [ ! -f "$AKUN_FILE" ]; then
        echo -e "${RED}File $AKUN_FILE tidak ditemukan. Pastikan file akun.txt sudah ada.${NC}"
        read -rp "Tekan Enter untuk kembali ke menu..."
        return
    fi

    # Menampilkan isi file akun.txt
    echo -e "${YELLOW}Isi file akun.txt saat ini:${NC}"
    cat "$AKUN_FILE" | while IFS= read -r line; do
        echo -e "${GREEN}$line${NC}"
    done

    # Menunggu untuk kembali ke menu
    read -rp "Tekan Enter untuk kembali ke menu..."
}

# Loop utama untuk menampilkan menu
while true; do
    show_menu
    echo -e "${GREEN}Pilih opsi [1/2/3/0]:${NC}"
    read -r pilihan

    # Menjalankan sesuai pilihan
    case $pilihan in
        1)
            input_akun
            ;;
        2)
            edit_akun
            ;;
        3)
            tampil_akun
            ;;
        0)
            echo -e "${RED}Terima kasih! Keluar dari program.${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Opsi tidak valid. Silakan pilih opsi yang benar.${NC}"
            read -rp "Tekan Enter untuk kembali ke menu..."
            ;;
    esac
done
