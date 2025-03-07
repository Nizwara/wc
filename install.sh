#!/bin/bash

# Membersihkan layar terminal
clear

# Unduh file wcf.py ke /usr/bin
echo "Mengunduh wcf.py ke /usr/bin..."
wget -O /usr/bin/wcf.py https://raw.githubusercontent.com/Nizwara/wcx/main/wcf.py
if [ $? -ne 0 ]; then
    echo "Gagal mengunduh wcf.py. Pastikan URL benar dan koneksi internet stabil."
    exit 1
fi

# Berikan izin eksekusi pada file wcf.py
echo "Memberikan izin eksekusi pada /usr/bin/wcf.py..."
chmod +x /usr/bin/wcf.py
if [ $? -ne 0 ]; then
    echo "Gagal memberikan izin eksekusi pada /usr/bin/wcf.py."
    exit 1
fi

# Jalankan wcf.py
echo "Menjalankan wcf.py..."
python3 /usr/bin/wcf.py
if [ $? -ne 0 ]; then
    echo "Gagal menjalankan wcf.py."
    exit 1
fi

echo "Proses selesai."
