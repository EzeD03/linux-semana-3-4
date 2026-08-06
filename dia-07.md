# Bitácora de Aprendizaje - Día 07: Gestión de Procesos, Señales y Monitoreo en Linux

---

## 🎯 Objetivos del Día
* Comprender el ciclo de vida de los procesos en Linux y sus diferentes estados.
* Dominar las herramientas de monitoreo y diagnóstico de procesos (`ps`, `top`, `htop`, `pstree`).
* Gestionar la ejecución de procesos en primer y segundo plano (`fg`, `bg`, `jobs`, `&`).
* Manejar señales del sistema operativo (`kill`, `killall`, `pkill`) para controlar procesos.
* Ajustar prioridades de ejecución mediante `nice` y `renice`.
* Diferenciar entre procesos huérfanos y procesos zombie.

---

## 1. Conceptos Fundamentales sobre Procesos

Un **proceso** es una instancia de un programa en ejecución en el sistema. Cada proceso tiene un identificador único conocido como **PID** (Process ID) y un proceso padre identificado por **PPID** (Parent Process ID).

### Estados de un Proceso
* **R (Running / Runnable):** En ejecución o listo para ejecutarse en la CPU.
* **S (Interruptible Sleep):** Durmiendo o esperando un evento (E/S, señal, etc.).
* **D (Uninterruptible Sleep):** En espera directa de hardware/E/S (no responde a señales).
* **T (Stopped):** Detenido por una señal de control (ej. `CTRL+Z` / `SIGSTOP`).
* **Z (Zombie):** Proceso finalizado cuya entrada aún permanece en la tabla de procesos esperando que el padre lea su código de salida.

---

## 2. Herramientas de Monitoreo e Inspección

### Inspección Estática con `ps`
```bash
# Ver procesos del usuario actual en la terminal actual
ps

# Ver todos los procesos del sistema con formato detallado (BSD style)
ps aux

# Ver procesos con jerarquía de árbol y detalles
ps -ef --forest
```

### Monitoreo Dinámico en Tiempo Real

| Herramienta | Descripción | Uso Recomendado |
| :--- | :--- | :--- |
| `top` | Monitor de recursos interactivo nativo en la terminal. | Inspección rápida en cualquier servidor sin instalar paquetes extra. |
| `htop` | Interfaz interactiva mejorada con soporte de mouse, barras de colores y filtrado. | Monitoreo visual detallado y gestión interactiva de procesos. |
| `pstree` | Muestra la jerarquía de procesos en formato de árbol visual. | Entender relaciones padre-hijo (PPID / PID). |

---

## 3. Ejecución en Primer y Segundo Plano (Foreground / Background)

* **Ejecutar en segundo plano:** Agregar `&` al final del comando.
  ```bash
  sleep 300 &
  ```
* **Ver trabajos en segundo plano de la sesión actual:**
  ```bash
  jobs
  ```
* **Enviar un proceso activo al segundo plano:**
  1. Presionar `CTRL + Z` (pausa el proceso con `SIGSTOP`).
  2. Ejecutar `bg %1` para reanudarlo en segundo plano.
* **Traer un proceso al primer plano:**
  ```bash
  fg %1
  ```

---

## 4. Control de Procesos Mediante Señales (`kill`, `pkill`, `killall`)

Las señales son interrupciones asíncronas enviadas a los procesos para notificar un evento o solicitar una acción.

### Señales Más Comunes

| Número | Nombre | Descripción |
| :---: | :--- | :--- |
| **1** | `SIGHUP` | Recarga la configuración del proceso sin reiniciarlo. |
| **2** | `SIGINT` | Interrupción desde teclado (`CTRL + C`). Solicitud de parada limpia. |
| **9** | `SIGKILL` | Finalización inmediata e incondicional forzada por el Kernel. No puede ser interceptada. |
| **15** | `SIGTERM` | Señal por defecto. Solicita la terminación ordenada del proceso (permite liberar recursos). |
| **18** | `SIGCONT` | Continúa/reanuda la ejecución de un proceso detenido. |
| **19** | `SIGSTOP` | Detiene/pausa la ejecución (`CTRL + Z`). No puede ser ignorada. |

### Comandos de Envío de Señales
```bash
# Enviar SIGTERM (terminación suave) por PID
kill 1234

# Enviar SIGKILL (fuerza bruta) por PID
kill -9 1234

# Enviar señal por nombre exacto de proceso
killall nginx

# Enviar señal por patrón/coincidencia de nombre
pkill -f "python3 mi_script.py"
```

---

## 5. Gestión de Prioridades (`nice` y `renice`)

En Linux, la prioridad de CPU se determina mediante el valor de **Nice** (agradabilidad), que varía en un rango de **-20 a 19**:
* **-20:** Máxima prioridad (menos "agradable" con otros procesos, consume más CPU).
* **19:** Mínima prioridad (muy "agradable", cede CPU a otros procesos).
* **0:** Prioridad por defecto asignada a procesos estándar.

```bash
# Iniciar un proceso con una prioridad específica (ej. menor prioridad / niceness 10)
nice -n 10 tar -czf backup.tar.gz /var/log

# Cambiar la prioridad de un proceso existente en ejecución
renice -n -5 -p 1234
```
> **Nota:** Un usuario común solo puede aumentar el valor de `nice` (reducir prioridad). Asignar valores negativos (mayor prioridad) requiere permisos de superusuario (`sudo`).

---

## 6. Procesos Especiales: Zombie vs Huérfano

* **Proceso Huérfano (Orphan):** Ocurre cuando el proceso padre termina antes que el hijo.
  * *Manejo del Kernel:* El proceso `init` / `systemd` (PID 1) adopta automáticamente al proceso huérfano y recolecta su estado al finalizar.
* **Proceso Zombie (`Z`):** Ocurre cuando un proceso hijo termina su ejecución, pero el proceso padre no realiza la llamada de sistema `wait()` para leer su código de salida.
  * *Efecto:* No consume CPU ni RAM, pero ocupa una ranura en la tabla de procesos.
  * *Solución:* Eliminar el proceso padre o hacer que este gestione a sus hijos. Enviar `SIGKILL` directamente a un zombie no tiene efecto porque el proceso ya está muerto.

---

## 💡 Pregunta de Entrevista Técnica

> **¿Por qué NO se debe utilizar `SIGKILL` (`kill -9`) como primera opción para detener un proceso de Base de Datos (ej. PostgreSQL o MySQL)?**
>
> **Respuesta:**
> `SIGKILL` no puede ser interceptado ni manejado por el proceso. Al enviarlo, el kernel destruye el proceso de forma inmediata sin permitirle ejecutar sus rutinas de limpieza (*graceful shutdown*).
> En una base de datos, esto implica:
> 1. Que las transacciones en memoria no se escriban ni sincronicen en disco (logs WAL / transacciones pendientes).
> 2. Riesgo alto de **corrupción de datos** o tablas desincronizadas.
> 3. Bloqueos de memoria compartida o archivos lock residuales (`.pid`, `.lock`) que impiden que el servicio vuelva a iniciar con normalidad.
>
> **Buena práctica:** Enviar siempre `SIGTERM` (`kill -15`) o utilizar `systemctl stop` para permitir que la base de datos cierre conexiones activas, haga *flush* del búfer a disco y libere recursos adecuadamente.

---

## 📌 Resumen de Aprendizaje
* **`ps aux`** y **`htop`** son esenciales para diagnosticar el estado y consumo de recursos.
* Usar siempre **`SIGTERM` (15)** primero; reservar **`SIGKILL` (9)** solo para procesos colgados que no responden.
* Entender **`nice` (-20 a 19)** permite optimizar tareas pesadas en segundo plano sin ralentizar el servidor.
* Identificar procesos **Zombie** e **Huérfanos** ayuda a diagnosticar fallos en la lógica de scripts o aplicaciones.