# Proyecto: Administración de un servidor Linux (Ubuntu Server 24.04)

## Qué resuelve este proyecto
Configuración de un entorno tipo servidor con gestión de usuarios y permisos
diferenciados, automatización de tareas con cron, y un servicio systemd propio —
el flujo real que se espera de un puesto de Soporte Técnico N2 / SysAdmin Trainee.

## Stack y herramientas
Ubuntu Server 24.04 LTS, VirtualBox, systemd, cron, Bash, vim, SSH.

## Estructura del repositorio
- `dia-04.md` a `dia-09.md`: bitácora diaria del proceso
- `scripts/`: todos los scripts bash desarrollados
- `screenshots/`: evidencia visual de cada etapa
- `healthcheck_semana.log`: última auditoría del entorno completo

## Lo que se construyó
1. Usuarios con permisos diferenciados (admin, solo lectura, cuenta de servicio)
2. Automatización con cron (chequeo de sistema programado)
3. Servicio systemd propio (`saludo.service`)
4. Script de auditoría/healthcheck que verifica todo lo anterior

## Desafíos y aprendizajes
En este proyecto sentí una dificultad grande al aventurarme en herramientas nuevas cada día que avanzaba. La ventaja y sorpresa sobre el final no es sólo entender para qué servía cada una sino poder ver la construcción finalizada y dando las respuestas que uno buscaría usualmente a la hora de monitorear un servidor.

## Cómo se prueba
`bash scripts/healthcheck_semana.sh`