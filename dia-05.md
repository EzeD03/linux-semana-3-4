# Día 05 — Estructura del Sistema de Archivos (FHS) y Gestión de Directorios

## 🎯 Objetivos del día
* Comprender la Jerarquía Estándar del Sistema de Archivos en Linux (FHS - Filesystem Hierarchy Standard).
* Identificar la ubicación crítica de archivos de configuración (`/etc`), archivos variables/logs (`/var`) y recursos compartidos (`/srv`).
* Dominar comandos de navegación, estructuración y monitoreo de almacenamiento (`df`, `du`).

---

## 📂 1. Estructura FHS (Filesystem Hierarchy Standard)

En Linux todo reside bajo el directorio raíz (`/`). A diferencia de Windows, no existen unidades separadas por letras (`C:`, `D:`), sino un único árbol en el que se montan los diferentes sistemas de archivos.

| Directorio | Propósito y Descripción Técnica |
| :--- | :--- |
| `/` | **Raíz (Root):** El origen de todo el árbol del sistema de archivos. |
| `/etc` | **Configuración:** Archivos de configuración de todo el sistema y servicios instalados (ej. `/etc/passwd`, `/etc/ssh/sshd_config`). |
| `/var` | **Variables:** Información dinámica que cambia durante la ejecución (logs en `/var/log`, colas de correo, bases de datos). |
| `/srv` | **Servicios:** Datos que este sistema sirve a otros usuarios o red (sitios web en `/srv/www`, recursos compartidos de archivos). |
| `/home` | **Usuarios:** Carpetas personales de los usuarios normales (ej. `/home/usuario`). |
| `/root` | **Superusuario:** Carpeta personal del usuario administrador `root`. |
| `/tmp` | **Archivos Temporales:** Espacio para archivos volátiles de uso temporal. Suele limpiarse al reiniciar. |
| `/usr` | **Programas de Usuario:** Librerías, binarios e información compartida de las aplicaciones de usuario. |
| `/bin` / `/sbin` | Binarios esenciales del sistema (en distribuciones modernas son symlinks a `/usr/bin` y `/usr/sbin`). |
| `/proc` / `/sys` | **Sistemas de archivos virtuales:** Exponen métricas en tiempo real del Kernel, memoria, procesos y hardware sin usar espacio en disco. |

---

## 🛠️ 2. Laboratorio Práctico de Gestión de Estructura

### Paso 1: Exploración e Inspección del Sistema
```bash
# Verificar ubicación actual
pwd

# Monitorear el espacio en disco en formato legible por humanos (-h)
df -h

# Analizar los logs más pesados del sistema en /var/log
sudo du -sh /var/log/* | sort -rh | head -n 5
```

### Paso 2: Creación de Estructura de Proyecto
```bash
# Crear estructura de carpetas anidadas con -p
mkdir -p ~/laboratorio/dia5/{logs,config,backups}

# Crear archivos de simulación
touch ~/laboratorio/dia5/config/app.conf
touch ~/laboratorio/dia5/logs/app.log

# Desplazar y renombrar archivos
cp ~/laboratorio/dia5/config/app.conf ~/laboratorio/dia5/backups/app.conf.bak
```

---

## 🧠 3. Justificación Técnica para Entrevistas (SysAdmin / DevOps)

### Q: Un servidor se quedó sin espacio en disco en el volumen raíz (`/`). ¿Por dónde empiezas a investigar?
**Respuesta:**
1. Ejecuto `df -h` para identificar la partición llena.
2. Si la partición comprometida es `/var`, suelo revisar `/var/log` usando `du -sh /var/log/* | sort -rh` para identificar logs rotos o excesivos que no fueron rotados por `logrotate`.
3. Si el problema está en `/tmp`, verifico procesos colgados que hayan generado temporales masivos.
4. Con `find / -type f -size +100M` busco archivos individuales que superen los 100 MB para tomar medidas de purga o archivado.

---

## 📌 Comandos clave aprendidos
* `df -h`: Muestra el uso de espacio en las particiones montadas.
* `du -sh <directorio>`: Calcula el tamaño total ocupado por un directorio específico.
* `mkdir -p`: Crea directorios padres e hijos de manera recursiva si no existen.
* `cp -r` / `mv`: Copia recursiva y movimiento/renombrado de archivos o directorios.

---

## 🖼️ Capturas de Pantalla

![Espacio en disco y analisis de logs](screenshots/dia5-df-du.png)
*Ejecución de `df -h` para auditar el espacio en la partición raíz y `du` para identificar los logs más pesados en `/var/log`.*