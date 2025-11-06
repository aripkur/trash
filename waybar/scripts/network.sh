#!/bin/bash

# Deteksi interface aktif (wifi/lan)
IFACE=$(ip route get 8.8.8.8 2>/dev/null | while read -a arr; do
  for ((i=0;i<${#arr[@]};i++)); do
    [ "${arr[i]}" = "dev" ] && echo "${arr[i+1]}" && break 2
  done
done)

# Jika tidak ada koneksi
[ -z "$IFACE" ] && { echo "⇣ 0KB/s ⇡ 0KB/s"; exit; }

# Baca bytes awal
RX1=$(< /sys/class/net/"$IFACE"/statistics/rx_bytes)
TX1=$(< /sys/class/net/"$IFACE"/statistics/tx_bytes)
sleep 1
RX2=$(< /sys/class/net/"$IFACE"/statistics/rx_bytes)
TX2=$(< /sys/class/net/"$IFACE"/statistics/tx_bytes)

# Hitung KB/s
RXBPS=$(( (RX2 - RX1) / 1024 ))
TXBPS=$(( (TX2 - TX1) / 1024 ))

# Format cepat tanpa awk/bc
format_speed() {
  local s=$1
  if [ "$s" -ge 1024 ]; then
    # Hitung MB dengan 1 desimal
    local mb=$(( s * 10 / 1024 ))
    printf "%d.%d MB/s" $((mb/10)) $((mb%10))
  else
    printf "%d KB/s" "$s"
  fi
}

echo "⇣ $(format_speed $RXBPS) ⇡ $(format_speed $TXBPS)"

