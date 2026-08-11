#!/usr/bin/env bash
FECHA=$(date "+%Y-%m-%d %H-%M-%S")
LOG="/home/skl/scripts/chequeo_sistema.log"

echo "===== Chequeo: $FECHA =====" >> "$LOG"
echo "-- Disco --" >> "$LOG"
/bin/df -h >> "$LOG"
echo "-- Memoria --" >> "$LOG"
/usr/bin/free -h >> "$LOG"
echo "" >> "$LOG"