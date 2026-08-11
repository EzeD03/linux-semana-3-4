#!/bin/bash
# Script: lista usuarios "reales" (no de sistema) y su acceso a la carpeta compartida

CARPETA="/srv/compartida"
LOG="/home/skl/scripts/usuarios_permisos.log"

echo "==== Reporte: $(date) ====" > "$LOG"

for usuario in $(cut -d: f1,3 /etc/passwd | awk -F: '$2 >= 1000 {print $1}'); do
    echo "-- Usuario: $usuario --" >> "$LOG"

    if id -nG "$usuario" | grep -qw "sudo"; then
        echo "  Pertenece a sudo: SÍ" >> "$LOG"
    else
        echo "  Pertenece a sudo: NO" >> "$LOG"
    fi

    if sudo -u "$usuario" test -r "$CARPETA" 2>/dev/null; then
        echo "  Puede leer $CARPETA: SÍ" >> "$LOG"
    else
        echo "  Puede leer $CARPETA: NO" >> "$LOG"
    fi
    
    if sudo -u "$usuario" test -w "$CARPETA" 2>/dev/null; then
        echo "  Puede escribir $CARPETA: SÍ" >> "$LOG"
    else
        echo "  Puede escribir $CARPETA: NO" >> "$LOG"
    fi

    echo "" >> "$LOG"
done

echo "Reporte generado en $LOG"
    