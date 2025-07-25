#!/bin/bash

# Jalankan sebagai root
if [ "$EUID" -ne 0 ]; then
  echo "Silakan jalankan script ini sebagai root."
  exit 1
fi

echo "[+] Melakukan update apt..."
apt update -y

# Uninstall dan purge layanan yang disebutkan
for pkg in openvpn apache2 dropbear squid; do
  echo "[+] Menghapus dan purge $pkg..."
  apt remove -y $pkg && apt purge -y $pkg
done

# Nonaktifkan dan hapus service udp-server
echo "[+] Menonaktifkan dan menghentikan udp-server..."
systemctl disable udp-server
systemctl stop udp-server

echo "[+] Menghapus file service udp-server..."
rm -f /etc/systemd/system/udp-server.service

echo "[+] Reload systemd daemon..."
systemctl daemon-reload

# Set parameter sysctl untuk saat ini (runtime)
echo "[+] Menyetel sysctl runtime..."
sysctl -w vm.swappiness=10
sysctl -w vm.vfs_cache_pressure=50

# Tambahkan konfigurasi ke /etc/sysctl.conf jika belum ada
echo "[+] Memastikan konfigurasi permanen ada di /etc/sysctl.conf..."

grep -q "^vm.swappiness=" /etc/sysctl.conf \
    && sed -i 's/^vm.swappiness=.*/vm.swappiness=10/' /etc/sysctl.conf \
    || echo "vm.swappiness=10" >> /etc/sysctl.conf

grep -q "^vm.vfs_cache_pressure=" /etc/sysctl.conf \
    && sed -i 's/^vm.vfs_cache_pressure=.*/vm.vfs_cache_pressure=50/' /etc/sysctl.conf \
    || echo "vm.vfs_cache_pressure=50" >> /etc/sysctl.conf

echo "[✓] Semua tugas selesai. Konfigurasi sistem telah diperbarui."
