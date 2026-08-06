# Bitácora de Aprendizaje - Día 08: Automatización y Gestión de Servicios (`systemd` y `cron`)

---

## 🎯 Objetivos del Día
* Comprender la arquitectura de **systemd** como init system y gestor de servicios principal en distribuciones Linux modernas.
* Aprender a controlar el ciclo de vida de los servicios mediante el comando `systemctl`.
* Crear y configurar un servicio personalizado (`.service`) en systemd.
* Automatizar tareas periódicas utilizando la herramienta tradicional **Cron** (`crontab`).
* Explorar los **Systemd Timers** como alternativa moderna a Cron.
* Consultar y analizar logs de ejecución de servicios y tareas mediante `journalctl`.

---

## 1. Gestor de Servicios e Inicios: Systemd

**systemd** es el primer proceso que se ejecuta en el espacio de usuario (PID 1) y se encarga de inicializar, controlar y supervisar los servicios del sistema.

### Unidades de Systemd (Units)
Systemd gestiona diferentes tipos de recursos llamados **unidades**. Las más comunes son:
* `.service`: Representa un servicio o demonio del sistema (ej. `ssh.service`, `nginx.service`).
* `.target`: Grupo lógico de unidades utilizado para definir estados o niveles de ejecución (ej. `multi-user.target`, `graphical.target`).
* `.timer`: Unidad para programar la ejecución de tareas en base a tiempo.

---

### Comandos Clave con `systemctl`

#### Gestión del Estado en Tiempo Real
```bash
# Ver el estado detallado de un servicio
sudo systemctl status nombre_servicio

# Iniciar un servicio
sudo systemctl start nombre_servicio

# Detener un servicio
sudo systemctl stop nombre_servicio

# Reiniciar un servicio
sudo systemctl restart nombre_servicio

# Recargar la configuración sin detener el servicio
sudo systemctl reload nombre_servicio
```

#### Gestión del Inicio Automático (Boot)
```bash
# Habilitar para que inicie automáticamente al arrancar el sistema
sudo systemctl enable nombre_servicio

# Deshabilitar el inicio automático
sudo systemctl disable nombre_servicio

# Verificar si un servicio está habilitado
systemctl is-enabled nombre_servicio
```

---

## 2. Creación de un Servicio Personalizado en Systemd

### Paso 1: Crear el Script a Ejecutar
Ubicación recomendada: `/usr/local/bin/mi_script.sh`

```bash
#!/bin/bash
# /usr/local/bin/mi_script.sh
echo "Servicio iniciado a las $(date)" >> /var/log/mi_servicio.log
```

Dar permisos de ejecución:
```bash
sudo chmod +x /usr/local/bin/mi_script.sh
```

### Paso 2: Crear el Archivo de Unidad `.service`
Ubicación para servicios locales del sistema: `/etc/systemd/system/mi_servicio.service`

```ini
[Unit]
Description=Servicio de Prueba Personalizado
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/mi_script.sh
Restart=on-failure
User=root

[Install]
WantedBy=multi-user.target
```

### Paso 3: Cargar y Activar el Servicio
```bash
# Recargar el demonio de systemd para detectar nuevos archivos de unidad
sudo systemctl daemon-reload

# Iniciar el servicio
sudo systemctl start mi_servicio.service

# Comprobar el estado
sudo systemctl status mi_servicio.service
```

---

## 3. Programación de Tareas con Cron

**Cron** es el demonio encargado de la ejecución automática de tareas en intervalos regulares definidos.

### Sintaxis de Crontab
La configuración de cada tarea sigue el esquema de 5 campos temporales seguido del comando:

```text
┌───────────── minuto (0 - 59)
│ ┌─────────── hora (0 - 23)
│ │ ┌───────── día del mes (1 - 31)
│ │ │ ┌─────── mes (1 - 12)
│ │ │ │ ┌───── día de la semana (0 - 6) [0 = Domingo]
│ │ │ │ │
* * * * * comando_a_ejecutar
```

#### Operadores Especiales
* `*`: Cualquier valor.
* `,`: Separador de lista (ej. `1,15,30`).
* `-`: Rango de valores (ej. `1-5`).
* `/`: Intervalos o pasos (ej. `*/15` = cada 15 minutos).

---

### Comandos de Gestión de Crontab
```bash
# Editar el archivo crontab del usuario actual
crontab -e

# Listar las tareas programadas
crontab -l

# Eliminar el archivo crontab del usuario
crontab -r
```

---

### Ejemplos Prácticos de Cron

```text
# Ejecutar un backup todos los días a las 02:30 AM
30 2 * * * /usr/local/bin/backup.sh

# Ejecutar un script cada 15 minutos de lunes a viernes
*/15 * * * 1-5 /home/usuario/scripts/check_health.sh

# Redireccionar salida y errores a un archivo log
0 0 * * * /home/usuario/tarea.sh >> /var/log/tarea.log 2>&1
```

---

## 4. Alternativa Moderna: Systemd Timers

Los **Systemd Timers** reemplazan o complementan a Cron ofreciendo ventajas como integración nativa con `journalctl`, control preciso de dependencias y registro de ejecuciones fallidas.

Requieren dos archivos:
1. `/etc/systemd/system/mi_tarea.service` (la acción)
2. `/etc/systemd/system/mi_tarea.timer` (la programación)

### Ejemplo de `mi_tarea.timer`:
```ini
[Unit]
Description=Ejecutar mi_tarea cada hora

[Timer]
OnCalendar=*-*-* *:00:00
Persistent=true

[Install]
WantedBy=timers.target
```

Para activar el timer:
```bash
sudo systemctl daemon-reload
sudo systemctl start mi_tarea.timer
sudo systemctl enable mi_tarea.timer

# Ver todos los timers activos
systemctl list-timers
```

---

## 5. Diagnóstico y Análisis de Logs (`journalctl`)

Systemd incluye **journald**, un recolector centralizado de logs en formato binario.

```bash
# Ver los últimos logs del sistema en tiempo real
journalctl -f

# Filtrar logs de un servicio específico
journalctl -u mi_servicio.service

# Ver logs generados en el arranque actual
journalctl -b

# Filtrar por rango de tiempo
journalctl --since "2026-08-06 00:00:00" --until "2026-08-06 12:00:00"
```

---

## 📌 Resumen de Aprendizaje
* **`systemctl`** es la herramienta principal para gestionar servicios, su estado y comportamiento en el arranque.
* Los archivos en `/etc/systemd/system/` definen unidades personalizadas.
* **Cron** permite programar scripts rápidamente mediante la sintaxis de 5 columnas.
* **Systemd Timers** ofrecen mayor control y visibilidad que Cron para entornos de producción.
* **`journalctl`** centraliza los logs permitiendo diagnósticos eficientes en un único lugar.