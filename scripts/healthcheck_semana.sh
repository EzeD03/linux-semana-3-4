#!/bin/bash
LOG="/home/skl/scripts/healthcheck_semana.log"
echo "===== Healthcheck del proyecto - $(date) =====" > "$LOG"

verificar_permiso(){
    local usuario=$1
    local permiso=$2
    local ruta=$3
    if sudo -u "$usuario" test -"$permiso" "$ruta" 2>/dev/null; then
        echo "  $usuario -> $permiso en $ruta: SI" >> "$LOG"
    else
        echo "  $usuario -> $permiso en $ruta: NO" >> "$LOG"
    fi
}

echo "-- Usuarios y permisos --" >> "$LOG"
verificar_permiso "admin_ezequiel" "w" "/srv/compartida"
verificar_permiso "lector_invitado" "w" "/srv/compartida" 
verificar_permiso "lector_invitado" "r" "/srv/compartida" 

echo "" >> "$LOG"
echo "-- Estado de servicios --" >> "$LOG"
echo "  cron activo: $(systemctl is-active cron)" >> "$LOG"
echo "  cron habilitado: $(systemctl is-enabled cron)" >> "$LOG"

echo "" >> "$LOG"
echo "-- Últimas 5 ejecuciones del cron job --" >> "$LOG"
grep CRON /var/log/syslog | grep chequeo_sistema | tail -n 5 >> "$LOG"

echo "" >> "$LOG"
echo "Healthcheck completo. Ver detalle en $LOG"
