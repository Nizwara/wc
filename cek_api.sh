#!/bin/bash

# Warna
NC='\e[0m'
BLACK='\e[0;30m';  RED='\e[0;31m';    GREEN='\e[0;32m'
YELLOW='\e[0;33m'; BLUE='\e[0;34m';   MAGENTA='\e[0;35m'
CYAN='\e[0;36m';   WHITE='\e[0;37m'
BBLACK='\e[1;30m'; BRED='\e[1;31m';   BGREEN='\e[1;32m'
BYELLOW='\e[1;33m';BBLUE='\e[1;34m';  BMAGENTA='\e[1;35m'
BCYAN='\e[1;36m';  BWHITE='\e[1;37m'

# Fungsi untuk menampilkan header
display_header() {
  clear
    echo -e "${BCYAN}"
    echo "╔══════════════════════════════════════════════════╗"
    printf "║  %-46s  ║\n" "KILLER VPN MANAGER PRO"
    echo "╠══════════════════════════════════════════════════╣"
printf "║ %-20s:${BWHITE}%-28s${BCYAN}║\n" "Tanggal" "$(date '+%A, %d %B %Y')"
printf "║ %-20s:${BWHITE}%-28s${BCYAN}║\n" "Waktu" "$(date '+%H:%M:%S')"
   echo "╚══════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Membaca file akun.txt
if [ -f akun.txt ]; then
  source akun.txt
else
  echo -e "${RED}File akun.txt tidak ditemukan!${NC}"
  exit 1
fi

# Memastikan variabel utama dari akun.txt
if [[ -z "$AUTH_EMAIL" || -z "$AUTH_KEY" ]]; then
  echo -e "${RED}Variabel AUTH_EMAIL atau AUTH_KEY tidak ditemukan di akun.txt!${NC}"
  exit 1
fi

# Fungsi untuk mendapatkan ACCOUNT_ID secara otomatis
get_account_id() {
  ACCOUNT_ID_RESPONSE=$(curl -s -X GET "https://api.cloudflare.com/client/v4/accounts" \
    -H "X-Auth-Email: $AUTH_EMAIL" \
    -H "X-Auth-Key: $AUTH_KEY" \
    -H "Content-Type: application/json")

  # Memeriksa apakah response valid
  if ! echo "$ACCOUNT_ID_RESPONSE" | jq -e '.success' >/dev/null; then
    echo -e "${RED}Gagal mendapatkan ACCOUNT_ID. Response tidak valid atau terjadi kesalahan API.${NC}"
    echo -e "${YELLOW}Response: $ACCOUNT_ID_RESPONSE${NC}"
    return
  fi

  ACCOUNT_ID=$(echo "$ACCOUNT_ID_RESPONSE" | jq -r '.result[0].id')

  if [[ -z "$ACCOUNT_ID" ]]; then
    echo -e "${RED}Tidak dapat menemukan ACCOUNT_ID untuk akun Cloudflare!${NC}"
    return
  fi

  echo -e "${GREEN}ACCOUNT_ID ditemukan: $ACCOUNT_ID${NC}"
}

# Fungsi untuk mendapatkan daftar zona
get_zones() {
  ZONE_RESPONSE=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones" \
    -H "X-Auth-Email: $AUTH_EMAIL" \
    -H "X-Auth-Key: $AUTH_KEY" \
    -H "Content-Type: application/json")

  # Memeriksa apakah response valid
  if ! echo "$ZONE_RESPONSE" | jq -e '.success' >/dev/null; then
    echo -e "${RED}Gagal mendapatkan daftar zona. Response tidak valid atau terjadi kesalahan API.${NC}"
    echo -e "${YELLOW}Response: $ZONE_RESPONSE${NC}"
    return
  fi

  # Memeriksa apakah ada zona
  if echo "$ZONE_RESPONSE" | jq -e '.result | length > 0' >/dev/null; then
    echo -e "${GREEN}Daftar zona ditemukan:${NC}"
    ZONE_LIST=($(echo "$ZONE_RESPONSE" | jq -r '.result[] | .name + ":" + .id'))
    for i in "${!ZONE_LIST[@]}"; do
      ZONE_NAME=$(echo "${ZONE_LIST[$i]}" | cut -d':' -f1)
      ZONE_ID=$(echo "${ZONE_LIST[$i]}" | cut -d':' -f2)
      echo "$((i + 1)). $ZONE_NAME (ID: $ZONE_ID)"
    done

    # Meminta input zona yang dipilih
    while true; do
      echo -e "${CYAN}Pilih nomor zona berdasarkan urutan:${NC}"
      read -r ZONE_INDEX

      # Validasi input
      if [[ "$ZONE_INDEX" =~ ^[0-9]+$ ]] && [ "$ZONE_INDEX" -ge 1 ] && [ "$ZONE_INDEX" -le "${#ZONE_LIST[@]}" ]; then
        break
      else
        echo -e "${RED}Input tidak valid. Harap masukkan nomor yang sesuai.${NC}"
      fi
    done

    # Mendapatkan nama dan ID zona yang dipilih
    SELECTED_ZONE=$(echo "${ZONE_LIST[$ZONE_INDEX-1]}")
    SELECTED_ZONE_NAME=$(echo "$SELECTED_ZONE" | cut -d':' -f1)
    SELECTED_ZONE_ID=$(echo "$SELECTED_ZONE" | cut -d':' -f2)

    echo -e "${GREEN}Zona yang Anda pilih: $SELECTED_ZONE_NAME (ID: $SELECTED_ZONE_ID)${NC}"
  else
    echo -e "${RED}Tidak ada zona yang ditemukan pada akun ini!${NC}"
  fi
}

# Menu utama
while true; do
  display_header

  echo -e "${CYAN}====================================${NC}"
  echo -e "${GREEN}          Main Menu                ${NC}"
  echo -e "${CYAN}====================================${NC}"
  echo -e "${YELLOW}1. Cek Account ID${NC}"
  echo -e "${YELLOW}2. Cek Daftar Zona${NC}"
  echo -e "${RED}0. Keluar${NC}"
  echo -e "${CYAN}====================================${NC}"

  read -rp "Pilih opsi (1/2/0): " pilihan

  case $pilihan in
    1)
      # Memanggil fungsi untuk mendapatkan ACCOUNT_ID
      get_account_id
      # Menunggu user menekan Enter untuk kembali ke menu
      read -rp "Tekan Enter untuk kembali ke menu utama..." dummy
      ;;
    2)
      # Memanggil fungsi untuk mendapatkan daftar zona
      get_zones
      # Menunggu user menekan Enter untuk kembali ke menu
      read -rp "Tekan Enter untuk kembali ke menu utama..." dummy
      ;;
    0)
      echo -e "${RED}Keluar dari menu.${NC}"
      exit 0
      ;;
    *)
      echo -e "${RED}Pilihan tidak valid. Coba lagi.${NC}"
      sleep 2
      ;;
  esac
done