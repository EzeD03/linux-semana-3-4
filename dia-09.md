# Bitácora de Aprendizaje - Día 09: Vim a Fondo y Primeros Pasos en Bash Scripting

---

## 🎯 Objetivos del Día
* Comprender la arquitectura basada en **modos** del editor **Vim** y dominar su flujo de trabajo en entornos CLI.
* Utilizar comandos de navegación, edición, búsqueda y reemplazo masivo en Vim sin depender de la interfaz gráfica ni del ratón.
* Dominar las reglas fundamentales de **Bash Scripting**: declaración de variables, prevención de *word splitting* y sustitución de comandos `$(...)`.
* Implementar estructuras de control condicionales (`if/else`) con operadores numéricos, de texto y sobre archivos.
* Implementar iteraciones y bucles (`for` y `while`) para procesar datos del sistema.
* Integrar ambos bloques mediante la creación de un script de auditoría de usuarios y permisos (`usuarios_permisos.sh`) redactado integramente en Vim.

---

## 1. El Editor Vim: Modos de Operación

A diferencia de editores tradicionales como `nano`, **Vim** es un editor modal donde cada tecla cumple una función según el modo activo.

### Tabla Comparativa de Modos

| Modo | Propósito / Para qué sirve | Cómo entrar | Cómo salir |
| :--- | :--- | :---: | :---: |
| **Normal** | Navegar por el texto, copiar, pegar y borrar. Es el modo por defecto. | `<Esc>` (desde cualquier modo) | — |
| **Insert** | Escribir e insertar texto de forma libre. | `i`, `a`, `o`, `O` (desde Normal) | `<Esc>` |
| **Visual** | Seleccionar bloques de texto con el teclado. | `v` (desde Normal) | `<Esc>` |
| **Command-line** | Guardar, salir, ejecutar comandos ex, buscar y reemplazar. | `:` (desde Normal) | `<Esc>` o `<Enter>` |

> **Regla de oro:** Presionar `<Esc>` siempre te regresa al **Modo Normal**. Si el editor no responde como esperas, presiona `<Esc>` para volver a un estado conocido.

---

## 2. Comandos Esenciales de Vim

### Navegación y Edición Básica (Modo Normal)

#### Movimiento
* `h`, `j`, `k`, `l`: Mover cursor a la izquierda, abajo, arriba, derecha.
* `w` / `b`: Avanzar / retroceder una palabra completa.
* `0` / `$`: Ir al inicio / final de la línea actual.
* `gg` / `G`: Ir al inicio / final del archivo.
* `:N`: Ir directamente a la línea número `N` (ejemplo: `:3`).

#### Edición Rápida
* `x`: Borrar el carácter bajo el cursor.
* `dd`: Cortar / borrar la línea completa.
* `dw`: Borrar desde el cursor hasta el final de la palabra.
* `yy`: Copiar (*yank*) la línea completa.
* `p` / `P`: Pegar el buffer después / antes del cursor.
* `u` / `Ctrl + r`: Deshacer (*undo*) / Rehacer (*redo*).
* `cw`: Cambiar palabra (borra la palabra y entra en modo Insert).

---

### Búsqueda y Reemplazo

#### Búsqueda
* `/texto`: Buscar `texto` hacia adelante.
* `?texto`: Buscar `texto` hacia atrás.
* `n` / `N`: Ir a la siguiente / anterior coincidencia.

#### Reemplazo con Expresiones Regular (`:s`)
```vim
:s/origen/destino/      " Reemplaza la 1ª coincidencia en la línea actual
:s/origen/destino/g     " Reemplaza TODAS las coincidencias en la línea actual
:%s/origen/destino/g    " Reemplaza en TODO el archivo
:%s/origen/destino/gc   " Reemplaza en todo el archivo pidiendo CONFIRMACIÓN (y/n)
```

---

### Guardado y Salida (Command-line Mode)

* `:w` $\rightarrow$ Guardar cambios (*write*).
* `:q` $\rightarrow$ Salir (falla si hay cambios sin guardar).
* `:wq` o `ZZ` $\rightarrow$ Guardar cambios y salir.
* `:q!` $\rightarrow$ Salir forzadamente descartando todos los cambios.

---

## 3. Fundamentos de Bash Scripting

### Reglas de Variables y *Word Splitting*
En Bash, la asignación de variables **NO debe llevar espacios** alrededor del signo `=`.

```bash
# SINTAXIS INCORRECTA (Genera error: command not found)
nombre = "Ezequiel"

# SINTAXIS CORRECTA
nombre="Ezequiel"
echo "Hola, $nombre"
```

> **Buenas Prácticas:** Envolver siempre las variables entre comillas dobles (`"$variable"`) para evitar que espacios en blanco dentro de la variable se interpreten como múltiples argumentos (*word splitting*).

---

### Sustitución de Comandos `$(...)`
Permite capturar la salida de la ejecución de un comando de terminal y almacenarla dentro de una variable.

```bash
fecha_actual=$(date "+%Y-%m-%d")
cantidad_usuarios=$(cat /etc/passwd | wc -l)

echo "Hoy es: $fecha_actual"
echo "Cantidad total de entradas en /etc/passwd: $cantidad_usuarios"
```

---

### Estructuras Condicionales (`if / else`)

```bash
disco_uso=80

if [ "$disco_uso" -gt 75 ]; then
    echo "Alerta: Uso de disco alto ($disco_uso%)"
else
    echo "Uso de disco dentro de parámetros normales"
fi
```

#### Operadores de Comparación Comunes

| Numéricos | Cadenas (Strings) | Archivos |
| :---: | :---: | :---: |
| `-eq` (igual) | `=` (igual) | `-f` (es archivo regular) |
| `-ne` (distinto) | `!=` (distinto) | `-d` (es directorio) |
| `-gt` (mayor que) | `-z` (está vacío) | `-x` (es ejecutable) |
| `-lt` (menor que) | `-n` (no está vacío) | `-r` / `-w` (lectura / escritura) |

---

### Bucles e Iteraciones (`for` y `while`)

#### Bucle `for` (Recorrer listas o salidas de comandos)
```bash
# Recorrer una lista definida
for usuario in admin_ezequiel lector_invitado svc_backup; do
    echo "Revisando usuario: $usuario"
done

# Recorrer usuarios del sistema
for usuario in $(cut -d: -f1 /etc/passwd); do
    echo "Usuario encontrado: $usuario"
done
```

#### Bucle `while` (Repetir mientras se cumpla una condición)
```bash
contador=1
while [ "$contador" -le 5 ]; do
    echo "Iteración número: $contador"
    contador=$((contador + 1))
done
```

---

## 4. Proyecto Práctico: Script `usuarios_permisos.sh`

El objetivo del proyecto fue desarrollar un script escrito enteramente en **Vim** que audite los usuarios reales del sistema, su pertenencia al grupo `sudo` y sus permisos de acceso sobre la carpeta compartida `/srv/compartida`.

### ¿Por qué filtramos por UID $\ge$ 1000?
En distribuciones Linux basadas en Debian/Ubuntu, los **UIDs de 0 a 999** están reservados para la cuenta `root` y cuentas de servicio del sistema (ej. `www-data`, `nobody`, `systemd-resolve`). Los usuarios humanos o reales creados convencionalmente mediante `useradd` reciben identificadores **UID $\ge$ 1000**. 

Filtramos mediante `awk -F: '$2 >= 1000'` para enfocar la auditoría únicamente en cuentas reales del sistema.

---

### Código Fuente Comentado (`usuarios_permisos.sh`)

```bash
#!/bin/bash
# Script: Lista usuarios reales (UID >= 1000) y verifica sus accesos a la carpeta compartida

CARPETA="/srv/compartida"
LOG="/home/skl/scripts/usuarios_permisos.log"

# Encabezado del reporte (sobrescribe o crea el archivo log)
echo "====== Reporte: $(date) ======" > "$LOG"

# Obtener usuarios cuyo UID sea mayor o igual a 1000 desde /etc/passwd
for usuario in $(cut -d: -f1,3 /etc/passwd | awk -F: '$2 >= 1000 {print $1}'); do
    echo "-- Usuario: $usuario --" >> "$LOG"

    # 1. Verificar si pertenece al grupo sudo
    if id -nG "$usuario" | grep -qw "sudo"; then
        echo "  Pertenece a sudo: SÍ" >> "$LOG"
    else
        echo "  Pertenece a sudo: NO" >> "$LOG"
    fi

    # 2. Verificar permisos de lectura en la carpeta compartida
    if sudo -u "$usuario" test -r "$CARPETA" 2>/dev/null; then
        echo "  Puede leer $CARPETA: SÍ" >> "$LOG"
    else
        echo "  Puede leer $CARPETA: NO" >> "$LOG"
    fi

    # 3. Verificar permisos de escritura en la carpeta compartida
    if sudo -u "$usuario" test -w "$CARPETA" 2>/dev/null; then
        echo "  Puede escribir en $CARPETA: SÍ" >> "$LOG"
    else
        echo "  Puede escribir en $CARPETA: NO" >> "$LOG"
    fi

    echo "" >> "$LOG"
done

echo "Reporte generado en $LOG"
```

---

### Ejecución y Resultado del Log (`usuarios_permisos.log`)

```bash
# Asignar permisos de ejecución
chmod +x /home/skl/scripts/usuarios_permisos.sh

# Ejecutar script
/home/skl/scripts/usuarios_permisos.sh

# Inspeccionar log generado
cat /home/skl/scripts/usuarios_permisos.log
```

#### Salida del Log Generado:
```text
====== Reporte: Fri Aug 07 14:00:00 -03 2026 ======
-- Usuario: ezequiel --
  Pertenece a sudo: SÍ
  Puede leer /srv/compartida: SÍ
  Puede escribir en /srv/compartida: SÍ

-- Usuario: lector_invitado --
  Pertenece a sudo: NO
  Puede leer /srv/compartida: SÍ
  Puede escribir en /srv/compartida: NO

-- Usuario: svc_backup --
  Pertenece a sudo: NO
  Puede leer /srv/compartida: NO
  Puede escribir en /srv/compartida: NO
```

---

## 📌 Resumen de Aprendizaje y Notas Extras
* **`set -e`:** Agregar esta instrucción al inicio de un script provoca que se detenga inmediatamente si algún comando falla. Es una buena práctica de seguridad en scripts de producción.
* **`vimtutor`:** Tutorial interactivo oficial de 30 minutos ejecutable en terminal para reforzar la agilidad en Vim.
* **Integración:** Se conectó la edición rápida en servidor sin GUI (`vim`) con lógica de automatización (`bash`), reutilizando conceptos de permisos y gestión de usuarios vistos en días anteriores.
