#!/bin/bash

# ====================================================================
#                         Nama Pembuat Script
# ====================================================================
# By: KILLER VPN
# Tanggal: $(date '+%A, %d %B %Y')
# Waktu: $(date '+%H:%M:%S')
# Deskripsi: Skrip ini digunakan untuk mengelola SSL (certificate) dari domain yang terdaftar di Cloudflare
# ====================================================================

# Warna
NC='\e[0m'
BLACK='\e[0;30m';  RED='\e[1;31m';    GREEN='\e[0;32m'
YELLOW='\e[1;33m'; BLUE='\e[0;34m';   MAGENTA='\e[0;35m'
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

# Pastikan variabel dari akun.txt terdefinisi
if [[ -z "$AUTH_EMAIL" || -z "$AUTH_KEY" || -z "$ZONE_ID" ]]; then
  echo -e "${RED}Variabel AUTH_EMAIL, AUTH_KEY, atau ZONE_ID tidak ditemukan di akun.txt!${NC}"
  exit 1
fi

# Fungsi untuk mendapatkan daftar certificate packs
get_certificate_packs() {
  echo -e "${CYAN}Mendapatkan daftar certificate packs...${NC}"
  RESPONSE=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/ssl/certificate_packs" \
    -H "X-Auth-Email: $AUTH_EMAIL" \
    -H "X-Auth-Key: $AUTH_KEY" \
    -H "Content-Type: application/json")

  # Memeriksa apakah response valid
  if ! echo "$RESPONSE" | jq -e '.success' >/dev/null; then
    echo -e "${RED}Gagal mendapatkan daftar certificate packs. Response tidak valid atau terjadi kesalahan API.${NC}"
    echo -e "${YELLOW}Response: $RESPONSE${NC}"
    return
  fi

  # Memeriksa apakah ada certificate packs yang ditemukan
  if echo "$RESPONSE" | jq -e '.result | length > 0' >/dev/null; then
    echo -e "${GREEN}Certificate packs ditemukan. Berikut detailnya:${NC}"
    
    # Menampilkan setiap certificate pack
    echo "$RESPONSE" | jq -c '.result[]' | while read -r PACK; do
      ID=$(echo "$PACK" | jq -r '.id')
      STATUS=$(echo "$PACK" | jq -r '.status')
      HOSTS=$(echo "$PACK" | jq -r '.hosts[]')
      
      echo -e "\n${CYAN}ID: $ID${NC}"
      echo -e "${CYAN}Status: $STATUS${NC}"
      
      # Menampilkan nama domain dari setiap host
      echo -e "${CYAN}Domains:${NC}"
      for HOST in $HOSTS; do
        DOMAIN=$(echo "$HOST" | awk -F'.' '{print $(NF-1)"."$NF}')
        echo -e "- ${YELLOW}$HOST${NC} (Domain: ${GREEN}$DOMAIN${NC})"
      done
    done
  else
    echo -e "${RED}Tidak ada certificate packs yang ditemukan.${NC}"
  fi

  # Menunggu input untuk melanjutkan ke menu utama
  read -p "Tekan Enter untuk kembali ke menu utama..." dummy
}

# Fungsi untuk menghapus semua certificate packs
delete_certificate_packs() {
  echo -e "${CYAN}Mendapatkan daftar certificate packs untuk dihapus...${NC}"
  RESPONSE=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/ssl/certificate_packs" \
    -H "X-Auth-Email: $AUTH_EMAIL" \
    -H "X-Auth-Key: $AUTH_KEY" \
    -H "Content-Type: application/json")

  # Memeriksa apakah response valid
  if ! echo "$RESPONSE" | jq -e '.success' >/dev/null; then
    echo -e "${RED}Gagal mendapatkan daftar certificate packs. Response tidak valid atau terjadi kesalahan API.${NC}"
    echo -e "${YELLOW}Response: $RESPONSE${NC}"
    return
  fi

  # Memeriksa apakah ada certificate packs yang ditemukan
  if echo "$RESPONSE" | jq -e '.result | length > 0' >/dev/null; then
    echo -e "${GREEN}Certificate packs ditemukan. Berikut detailnya:${NC}"
    
    # Menampilkan setiap certificate pack
    echo "$RESPONSE" | jq -c '.result[]' | while read -r PACK; do
      ID=$(echo "$PACK" | jq -r '.id')
      STATUS=$(echo "$PACK" | jq -r '.status')
      HOSTS=$(echo "$PACK" | jq -r '.hosts[]')
      
      echo -e "\n${CYAN}ID: $ID${NC}"
      echo -e "${CYAN}Status: $STATUS${NC}"
      
      # Menampilkan nama domain dari setiap host
      echo -e "${CYAN}Domains:${NC}"
      for HOST in $HOSTS; do
        DOMAIN=$(echo "$HOST" | awk -F'.' '{print $(NF-1)"."$NF}')
        echo -e "- ${YELLOW}$HOST${NC} (Domain: ${GREEN}$DOMAIN${NC})"
      done
    done
    
    # Konfirmasi sebelum menghapus
    read -p "Apakah Anda yakin ingin menghapus SEMUA certificate packs? (y/n): " CONFIRM
    if [[ "$CONFIRM" == "y" || "$CONFIRM" == "Y" ]]; then
      echo -e "${CYAN}Menghapus semua certificate packs...${NC}"
      
      # Mengambil semua ID certificate packs
      PACK_IDS=$(echo "$RESPONSE" | jq -r '.result[].id')
      
      for PACK_ID in $PACK_IDS; do
        echo -e "${CYAN}Menghapus certificate pack dengan ID: $PACK_ID...${NC}"
        DELETE_RESPONSE=$(curl -s -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/ssl/certificate_packs/$PACK_ID" \
          -H "X-Auth-Email: $AUTH_EMAIL" \
          -H "X-Auth-Key: $AUTH_KEY" \
          -H "Content-Type: application/json")

        # Mengecek hasil penghapusan
        if echo "$DELETE_RESPONSE" | jq -e '.success' >/dev/null; then
          echo -e "${GREEN}Certificate pack dengan ID $PACK_ID berhasil dihapus.${NC}"
        else
          echo -e "${RED}Gagal menghapus certificate pack dengan ID $PACK_ID.${NC}"
          echo -e "${YELLOW}Response: $DELETE_RESPONSE${NC}"
        fi
      done
    else
      echo -e "${YELLOW}Penghapusan dibatalkan.${NC}"
    fi
  else
    echo -e "${RED}Tidak ada certificate packs yang ditemukan.${NC}"
  fi
}

# Menu utama
while true; do
  display_header

  echo -e "${CYAN}=====================================================${NC}"
  echo -e "${GREEN}         Cloudflare SSL Management                    ${NC}"
  echo -e "${CYAN}=====================================================${NC}"
  echo -e "${YELLOW}1. Tampilkan daftar certificate packs${NC}"
  echo -e "${YELLOW}2. Hapus semua certificate packs SSL${NC}"
  echo -e "${RED}0. Keluar${NC}"
  echo -e "${CYAN}=====================================================${NC}"
  read -p "Pilih opsi (1/2/0): " pilihan

  case $pilihan in
    1)
      get_certificate_packs
      ;;
    2)
      delete_certificate_packs
      ;;
    0)
      echo -e "${RED}Keluar dari menu...${NC}"
      exit 0
      ;;
    *)
      echo -e "${RED}Pilihan tidak valid!${NC}"
      ;;
  esac
done