
### Pandangan Penggunaan Script

## Persiapan Awal


# PINDAHKAN SEMUA BAHAN KE DIREKTORI TANPA FOLDER
```
mv */sdcard* .

# EDIT FILE YANG DIBUTUHKAN
```

### File yang Perlu Diedit:
- `akun.txt`    : Isi dengan data Cloudflare Anda
- `domain.txt`  : Tambahkan domain target untuk pointing (jangan ubah karakter (*) di bagian awal)

## Bahan Wildcards Manual
- `worker.js`   : Untuk pointing manual

### Langkah Eksekusi

## Debugging

### 1. Periksa Instalasi `jq` Pilih Salah 1
```
jq --version
```

Jika belum terinstall:
- Ubuntu/Debian:
  ```
  sudo apt install jq
  ```
- CentOS/RHEL:
  ```
  sudo yum install jq
  ```
- Termux:
  ```
  apt install jq
  ```
  ```
  termux-setup-storage
  ```
  ### 2. Tahap Install
```
cd Scwc
chmod +x *
./menu
```



## Menggunakan Fitur Tools

1. Pilih nomor 3 untuk membuat worker (bagi yang belum punya)
2. Pilih nomor 1 untuk pointing wildcard - tunggu hingga proses selesai
3. Pilih nomor 5:
   - **Untuk pointing ke IP VPS**: Pilih A (contoh: "sub" + "127.0.0.1")
   - **Setelah berhasil**, pilih CNAME (contoh: "*.sub") dengan target subdomain (contoh: "vip.killervpn.tech")

## Setelah Eksekusi
- Hapus domain yang sudah tidak digunakan

## Catatan Penting
- Jangan ubah karakter (*) pada file domain.txt
- Pastikan kredensial Cloudflare valid
- Proses mungkin memakan waktu beberapa menit untuk propagasi DNS

