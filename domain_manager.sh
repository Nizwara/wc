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

# File yang berisi konfigurasi akun API Cloudflare
AKUN_FILE="akun.txt"

# Cek apakah file akun.txt ada
if [ ! -f "$AKUN_FILE" ]; then
    echo -e "${RED}File $AKUN_FILE tidak ditemukan!${NC}"
    exit 1
fi

# Membaca konfigurasi dari akun.txt
source "$AKUN_FILE"

# Cek apakah semua variabel sudah ada
if [ -z "$AUTH_EMAIL" ] || [ -z "$AUTH_KEY" ] || [ -z "$ACCOUNT_ID" ] || [ -z "$YOUR_NAME" ] || [ -z "$ZONE_ID" ]; then
    echo -e "${RED}Konfigurasi API Cloudflare tidak lengkap. Pastikan file akun.txt berisi semua informasi.${NC}"
    exit 1
fi

# File yang berisi daftar domain
DOMAIN_FILE="domain.txt"

# Cek apakah file domain.txt ada
if [ ! -f "$DOMAIN_FILE" ]; then
    echo -e "${RED}File $DOMAIN_FILE tidak ditemukan!${NC}"
    exit 1
fi

# Fungsi untuk menambahkan domain
tambah_domain() {
    while true; do
        display_header
        echo -e "${CYAN}=====================================================${NC}"
        echo -e "${GREEN}           Menu Tambah Domain                       ${NC}"
        echo -e "${CYAN}=====================================================${NC}"
        echo -e "${YELLOW}1. Tambah domain manual${NC}"
        echo -e "${YELLOW}2. Tambah domain dari file${NC}"
        echo -e "${RED}0. Kembali${NC}"
        echo -e "${CYAN}=====================================================${NC}"
        read -p "Masukkan nomor opsi (1/2/0): " option
        clear

        case $option in
            1)
                # Menambah domain manual
                echo -e "${YELLOW}Masukkan subdomain yang ingin ditambahkan (contoh 'www' atau subdomain lain):${NC}"
                read inputDomain

                if [ -z "$inputDomain" ]; then
                    echo -e "${RED}Subdomain tidak boleh kosong.${NC}"
                    read -p "Tekan Enter untuk kembali..."
                    continue
                fi

                # Generate custom domain otomatis
                customDomain="${inputDomain}.${SBD_SUFFIX}"

                # Cek apakah domain sudah ada di Cloudflare
                check_url="https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?name=$customDomain"
                check_response=$(curl -s -w "%{http_code}" -o check_response.json -H "X-Auth-Email: $AUTH_EMAIL" -H "X-Auth-Key: $AUTH_KEY" "$check_url")
                check_httpCode=$(echo "$check_response" | tail -n1)

                if [ "$check_httpCode" -eq 200 ]; then
                    if jq -e '.success == true' check_response.json >/dev/null 2>&1; then
                        existing_domains=$(jq '.result | length' < check_response.json)
                        if [ "$existing_domains" -gt 0 ]; then
                            echo -e "${YELLOW}Domain $customDomain sudah ada, melewati penambahan.${NC}"
                        else
                            # Menambahkan domain
                            if tambah_domain_manual "$customDomain"; then
                                success_count=$((success_count + 1))
                            fi
                        fi
                    else
                        echo -e "${RED}Respons API tidak valid untuk domain $customDomain.${NC}"
                    fi
                else
                    echo -e "${RED}Gagal memeriksa keberadaan domain $customDomain. Kode HTTP: $check_httpCode${NC}"
                fi
                read -p "Tekan Enter untuk kembali..."
                ;;
            2)
                # Menambah domain dari file
                echo -e "${YELLOW}Menambahkan domain dari file...${NC}"
                success_count=0  # Reset penghitung
                while IFS= read -r inputDomain; do
                    # Cek apakah baris kosong, jika ya, lanjutkan ke baris berikutnya
                    if [ -z "$inputDomain" ]; then
                        continue
                    fi

                    # Generate custom domain otomatis
                    customDomain="${inputDomain}.${SBD_SUFFIX}"
                    echo "Memproses domain: $customDomain"

                    # Cek apakah domain sudah ada di Cloudflare
                    check_url="https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?name=$customDomain"
                    check_response=$(curl -s -w "%{http_code}" -o check_response.json -H "X-Auth-Email: $AUTH_EMAIL" -H "X-Auth-Key: $AUTH_KEY" "$check_url")
                    check_httpCode=$(echo "$check_response" | tail -n1)

                    if [ "$check_httpCode" -eq 200 ]; then
                        if jq -e '.success == true' check_response.json >/dev/null 2>&1; then
                            existing_domains=$(jq '.result | length' < check_response.json)
                            if [ "$existing_domains" -gt 0 ]; then
                                echo -e "${YELLOW}Domain $customDomain sudah ada, melewati penambahan.${NC}"
                                continue
                            fi
                        else
                            echo -e "${RED}Respons API tidak valid untuk domain $customDomain.${NC}"
                            continue
                        fi
                    else
                        echo -e "${RED}Gagal memeriksa keberadaan domain $customDomain. Kode HTTP: $check_httpCode${NC}"
                        continue
                    fi

                    # Menambahkan domain
                    if tambah_domain_manual "$customDomain"; then
                        success_count=$((success_count + 1))
                    fi
                    
                    # Delay untuk menghindari rate limiting
                    sleep 1

                done < "$DOMAIN_FILE"

                # Tampilkan jumlah domain yang berhasil ditambahkan
                echo -e "${GREEN}Jumlah domain yang berhasil ditambahkan: $success_count${NC}"
                read -p "Tekan Enter untuk kembali..."
                ;;
            0)
                # Kembali ke menu sebelumnya
                break
                ;;
            *)
                echo -e "${RED}Pilihan tidak valid. Harap pilih 1, 2, atau 0.${NC}"
                read -p "Tekan Enter untuk kembali..."
                ;;
        esac
    done
}

# Fungsi untuk menambahkan domain manual
tambah_domain_manual() {
    customDomain=$1

    # Data untuk request API
    data=$(cat <<EOF
{
    "hostname": "$customDomain",
    "zone_id": "$ZONE_ID",
    "service": "$WORKER_NAME",
    "environment": "production"
}
EOF
)

    # Endpoint API PUT
    URL="https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/workers/domains/records"

    # Header untuk autentikasi
    headers=(
        -H "X-Auth-Email: $AUTH_EMAIL"
        -H "X-Auth-Key: $AUTH_KEY"
        -H "Content-Type: application/json"
    )

    # Kirim request menggunakan curl
    response=$(curl -s -w "%{http_code}" -o response.json "${headers[@]}" -X PUT "$URL" -d "$data")

    # Pisahkan status code dan respons body
    httpCode=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')

    # Cek hasil respons
    if [ "$httpCode" -eq 200 ]; then
        echo -e "${GREEN}Custom domain berhasil ditambahkan:${NC}"
        echo -e "${YELLOW}Domain: $customDomain${NC}"
        echo "$body"
    else
        echo -e "${RED}Gagal menambahkan custom domain $customDomain:${NC}"
        echo -e "${RED}Status Code: $httpCode${NC}"
        echo "$body"
    fi

    # Tekan Enter untuk kembali
    read -p "Tekan Enter untuk kembali..."
}

# Fungsi untuk menghapus domain yang terkait dengan worker
hapus_domain() {
    display_header
    echo -e "${CYAN}=====================================================${NC}"
    echo -e "${GREEN}           Menu Hapus Domain                        ${NC}"
    echo -e "${CYAN}=====================================================${NC}"
    echo -e "${YELLOW}Masukkan nama Worker yang ingin dihapus domainnya:${NC}"
    read worker_name

    # Mendapatkan daftar domain yang terkait dengan worker
    worker_domains_url="https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/workers/domains?worker_name=$worker_name"
    worker_domains_response=$(curl -s -w "%{http_code}" -o worker_domains_response.json -H "X-Auth-Email: $AUTH_EMAIL" -H "X-Auth-Key: $AUTH_KEY" "$worker_domains_url")
    worker_domains_httpCode=$(echo "$worker_domains_response" | tail -n1)

    if [ "$worker_domains_httpCode" -eq 200 ]; then
        domain_ids=$(jq -r '.result[] | .id' < worker_domains_response.json)

        # Cek jika tidak ada domain terkait dengan worker
        if [ -z "$domain_ids" ]; then
            echo -e "${YELLOW}Tidak ada domain yang terkait dengan worker $worker_name.${NC}"
            echo -e "${CYAN}Tekan Enter untuk kembali ke menu...${NC}"
            read  # Tunggu input Enter untuk kembali
            return
        fi

        # Menghapus domain yang terkait dengan worker yang dipilih
        delete_count=0
        failed_count=0
        for domain_id in $domain_ids; do
            delete_url="https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/workers/domains/$domain_id"
            delete_response=$(curl -s -w "%{http_code}" -o delete_response.json -X DELETE -H "X-Auth-Email: $AUTH_EMAIL" -H "X-Auth-Key: $AUTH_KEY" "$delete_url")

            delete_httpCode=$(echo "$delete_response" | tail -n1)
            delete_body=$(echo "$delete_response" | sed '$d')

            if [ "$delete_httpCode" -eq 200 ]; then
                echo -e "${GREEN}Domain dengan ID $domain_id berhasil dihapus.${NC}"
                delete_count=$((delete_count + 1))
            else
                echo -e "${RED}Gagal menghapus domain dengan ID $domain_id:${NC}"
                echo -e "${RED}Status Code: $delete_httpCode${NC}"
                echo "$delete_body"
                failed_count=$((failed_count + 1))
            fi
        done

        # Menampilkan ringkasan hasil penghapusan
        if [ "$delete_count" -gt 0 ]; then
            echo -e "${GREEN}$delete_count domain berhasil dihapus dari worker $worker_name.${NC}"
        fi

        if [ "$failed_count" -gt 0 ]; then
            echo -e "${RED}$failed_count domain gagal dihapus.${NC}"
        fi
    else
        echo -e "${RED}Gagal memeriksa keberadaan domain terkait worker $worker_name.${NC}"
    fi

    # Menunggu pengguna untuk menekan Enter sebelum kembali ke menu
    echo -e "${CYAN}Tekan Enter untuk kembali ke menu...${NC}"
    read
}

# Fungsi untuk membuat atau memperbarui Worker
buat_worker() {
    display_header
    echo -e "${CYAN}=====================================================${NC}"
    echo -e "${GREEN}           Menu Buat Worker                         ${NC}"
    echo -e "${CYAN}=====================================================${NC}"
    echo -e "${YELLOW}Masukkan nama Worker yang ingin dibuat:${NC}"
    read WORKER_NAME

    # Contoh script Worker yang bisa disesuaikan dengan kebutuhan
    WORKER_SCRIPT="
    addEventListener('fetch', event => {
        event.respondWith(handleRequest(event.request))
    })

    async function handleRequest(request) {
        return new Response('Hello from Cloudflare Worker!', { status: 200 })
    }
    "
    
    # Kirim request API untuk membuat Worker
    URL="https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/workers/scripts/$WORKER_NAME"
    response=$(curl -s -w "%{http_code}" -o response.json -X PUT \
        -H "X-Auth-Email: $AUTH_EMAIL" \
        -H "X-Auth-Key: $AUTH_KEY" \
        -H "Content-Type: application/javascript" \
        --data "$WORKER_SCRIPT" \
        "$URL")

    httpCode=$(echo "$response" | tail -n1)
    body=$(cat response.json)

    if [ "$httpCode" -eq 200 ]; then
        echo -e "${GREEN}Worker '$WORKER_NAME' berhasil dibuat/diupdate.${NC}"
    else
        echo -e "${RED}Gagal membuat Worker '$WORKER_NAME':${NC}"
        echo -e "${RED}Status Code: $httpCode${NC}"
        echo "$body"
    fi

    # Notifikasi untuk kembali
    echo -e "${YELLOW}Tekan Enter untuk kembali ke menu utama...${NC}"
    read
}

# Fungsi untuk menghapus Worker
hapus_worker() {
    display_header
    echo -e "${CYAN}=====================================================${NC}"
    echo -e "${GREEN}           Menu Hapus Worker                        ${NC}"
    echo -e "${CYAN}=====================================================${NC}"
    echo -e "${YELLOW}Masukkan nama Worker yang ingin dihapus:${NC}"
    read WORKER_NAME

    # Kirim request API untuk menghapus Worker
    URL="https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/workers/scripts/$WORKER_NAME"
    response=$(curl -s -w "%{http_code}" -o response.json -X DELETE -H "X-Auth-Email: $AUTH_EMAIL" -H "X-Auth-Key: $AUTH_KEY" "$URL")

    httpCode=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')

    if [ "$httpCode" -eq 200 ]; then
        echo -e "${GREEN}Worker '$WORKER_NAME' berhasil dihapus.${NC}"
    else
        echo -e "${RED}Gagal menghapus Worker '$WORKER_NAME':${NC}"
        echo -e "${RED}Status Code: $httpCode${NC}"
        echo "$body"
    fi

    # Menunggu pengguna menekan tombol Enter untuk kembali
    echo -e "${YELLOW}Tekan Enter untuk kembali...${NC}"
    read
}

# Fungsi untuk menampilkan DNS records
show_dns_records() {
    display_header
    echo -e "${CYAN}=====================================================${NC}"
    echo -e "${GREEN}           Menu Tampilkan DNS Records               ${NC}"
    echo -e "${CYAN}=====================================================${NC}"
    RESPONSE=$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records" \
        -H "X-Auth-Email: ${AUTH_EMAIL}" \
        -H "X-Auth-Key: ${AUTH_KEY}" \
        -H "Content-Type: application/json")
    
    echo -e "${CYAN}=====================================================${NC}"
    echo -e "${GREEN}Daftar DNS Records:${NC}"
    echo -e "${CYAN}=====================================================${NC}"
    
    # Menampilkan DNS records yang ada
    echo "$RESPONSE" | jq -r '.result[] | "\(.id) - \(.name) - \(.type)"'
    
    echo -e "${CYAN}=====================================================${NC}"
}

# Fungsi untuk menambahkan DNS record A atau CNAME
tambah_dns_record() {
    display_header
    echo -e "${CYAN}=====================================================${NC}"
    echo -e "${GREEN}           Menu Tambah DNS Record                   ${NC}"
    echo -e "${CYAN}=====================================================${NC}"
    echo -e "${GREEN}Pilih tipe DNS record yang ingin ditambahkan:${NC}"
    echo -e "${YELLOW}1. A (Proxy Off)${NC}"
    echo -e "${YELLOW}2. CNAME (Proxy On)${NC}"
    read -p "Pilih tipe DNS record (1/2): " dns_type

    echo -e "${YELLOW}Masukkan subdomain yang akan dipointing (contoh 'www' atau subdomain lain):${NC}"
    read domain

    # Tentukan status proxy berdasarkan pilihan
    if [ "$dns_type" -eq 1 ]; then
        proxied=false
    elif [ "$dns_type" -eq 2 ]; then
        proxied=true
    else
        echo -e "${RED}Pilihan tidak valid.${NC}"
        return
    fi

    # Tentukan tipe record A atau CNAME
    if [ "$dns_type" -eq 1 ]; then
        record_type="A"
    elif [ "$dns_type" -eq 2 ]; then
        record_type="CNAME"
    fi

    # Masukkan IP atau domain tujuan untuk CNAME
    echo -e "${YELLOW}Masukkan alamat IP untuk A record atau domain tujuan untuk CNAME:${NC}"
    read target

    # Data untuk request API
    data=$(cat <<EOF
{
    "type": "$record_type",
    "name": "$domain",
    "content": "$target",
    "proxied": $proxied
}
EOF
)

    # Endpoint API untuk menambahkan DNS record
    URL="https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records"

    # Kirim request menggunakan curl
    response=$(curl -s -w "%{http_code}" -o response.json -X POST -H "X-Auth-Email: $AUTH_EMAIL" -H "X-Auth-Key: $AUTH_KEY" -H "Content-Type: application/json" -d "$data" "$URL")

    # Pisahkan status code dan respons body
    httpCode=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')

    # Cek hasil respons
    if [ "$httpCode" -eq 200 ]; then
        echo -e "${GREEN}DNS record berhasil ditambahkan:${NC}"
        echo -e "${YELLOW}Tipe: $record_type, Domain: $domain, Target: $target, Proxy: $proxied${NC}"
    else
        echo -e "${RED}Gagal menambahkan DNS record:${NC}"
        echo -e "${RED}Status Code: $httpCode${NC}"
        echo "$body"
    fi

    # Menunggu pengguna menekan tombol Enter untuk kembali
    echo -e "${YELLOW}Tekan Enter untuk kembali...${NC}"
    read
}

# Fungsi untuk menghapus DNS record
delete_dns_record() {
    display_header
    echo -e "${CYAN}=====================================================${NC}"
    echo -e "${GREEN}           Menu Hapus DNS Record                    ${NC}"
    echo -e "${CYAN}=====================================================${NC}"
    show_dns_records

    # Menampilkan pilihan record berdasarkan nomor urut
    echo -e "${YELLOW}Pilih nomor DNS record yang ingin dihapus:${NC}"
    echo -e "${YELLOW}Misalnya: Masukkan angka 1 untuk record pertama, 2 untuk record kedua, dll.${NC}"
    echo -e "${YELLOW}Atau masukkan 'x' untuk batal.${NC}"

    # Menerima input nomor record atau 'x' untuk batal
    read -rp "Masukkan nomor record yang ingin dihapus: " choice

    # Jika input adalah 'x' atau 'X', batal
    if [[ "$choice" =~ ^[xX]$ ]]; then
        return
    fi

    # Mengambil ID record yang sesuai berdasarkan nomor yang dipilih
    RESPONSE=$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records" \
        -H "X-Auth-Email: ${AUTH_EMAIL}" \
        -H "X-Auth-Key: ${AUTH_KEY}" \
        -H "Content-Type: application/json")

    RECORD_ID=$(echo "$RESPONSE" | jq -r ".result[$((choice - 1))].id")
    RECORD_NAME=$(echo "$RESPONSE" | jq -r ".result[$((choice - 1))].name")

    if [[ -z "$RECORD_ID" || "$RECORD_ID" == "null" ]]; then
        echo -e "${RED}Nomor record tidak valid!${NC}"
        return
    fi

    # Mengirimkan request untuk menghapus DNS record
    DELETE_RESPONSE=$(curl -sLX DELETE "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records/${RECORD_ID}" \
        -H "X-Auth-Email: ${AUTH_EMAIL}" \
        -H "X-Auth-Key: ${AUTH_KEY}" \
        -H "Content-Type: application/json")

    if [[ $(echo "$DELETE_RESPONSE" | jq -r '.success') == "true" ]]; then
        echo -e "${GREEN}$RECORD_NAME ${GREEN}Berhasil dihapus${NC}"
    else
        echo -e "${RED}$RECORD_NAME ${RED}Gagal dihapus${NC}"
    fi

    # Menunggu pengguna menekan tombol Enter untuk kembali
    echo -e "${YELLOW}Tekan Enter untuk kembali...${NC}"
    read
}

# Menu utama
while true; do
    display_header
    echo -e "${CYAN}=====================================================${NC}"
    echo -e "${GREEN}     Selamat datang di Menu Pengelolaan Domain      ${NC}"
    echo -e "${CYAN}=====================================================${NC}"
    echo -e "${YELLOW}1. Pointing (Menambahkan domain)${NC}"
    echo -e "${YELLOW}2. Hapus Domain${NC}"
    echo -e "${YELLOW}3. Membuat Worker${NC}"
    echo -e "${YELLOW}4. Hapus Worker${NC}"
    echo -e "${YELLOW}5. Menambahkan atau Menghapus DNS Record${NC}"
    echo -e "${RED}0. Keluar${NC}"
    echo -e "${CYAN}=====================================================${NC}"
    read -p "Pilih opsi (1/2/3/4/5/0): " pilihan

    case $pilihan in
        1)
            # Meminta input SBD dan Worker sebelum pointing
            echo -e "${YELLOW}Masukkan suffix domain yang akan digunakan (misalnya: speedssh.my.id):${NC}"
            read SBD_SUFFIX

            echo -e "${YELLOW}Masukkan nama Worker yang ingin dipilih untuk pointing:${NC}"
            read WORKER_NAME

            echo -e "${GREEN}Menambahkan domain dengan worker '$WORKER_NAME'...${NC}"
            tambah_domain
            ;;
        2)
            echo -e "${GREEN}Menghapus domain terkait worker...${NC}"
            hapus_domain
            ;;
        3)
            echo -e "${GREEN}Membuat atau memperbarui Worker...${NC}"
            buat_worker
            ;;
        4)
            echo -e "${GREEN}Menghapus Worker...${NC}"
            hapus_worker
            ;;
        5)
            echo -e "${GREEN}Menambahkan atau Menghapus DNS Record...${NC}"
            echo -e "${YELLOW}1. Menambahkan DNS Record${NC}"
            echo -e "${YELLOW}2. Menghapus DNS Record${NC}"
            read -p "Pilih opsi untuk DNS Record (1/2): " dns_option
            clear
            case $dns_option in
                1)
                    tambah_dns_record
                    ;;
                2)
                    delete_dns_record
                    ;;
                *)
                    echo -e "${RED}Pilihan tidak valid!${NC}"
                    ;;
            esac
            ;;
        0)
            echo -e "${RED}Keluar dari menu.${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Pilihan tidak valid!${NC}"
            ;;
    esac
done