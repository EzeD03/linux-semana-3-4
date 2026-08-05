# Día 06 — Control de Acceso: Permisos (chmod/chown) y Usuarios/Grupos

## 🎯 Objetivos del día
* Comprender la triada de permisos en Linux (`rwx`) en notación simbólica y octal.
* Aplicar cambios de permisos (`chmod`) y propietarios/grupos (`chown`).
* Implementar una estructura multi-usuario real aplicando el **Principio de Menor Privilegio** y shells no interactivas (`nologin`).

---

## 🔐 1. Matriz de Usuarios y Roles Creados

Se configuró un entorno de pruebas colaborativo en la ruta estandarizada `/srv/compartida`.

| Usuario | Grupo(s) | Shell (`-s`) | Permisos sobre `/srv/compartida` | Rol Asignado |
| :--- | :--- | :--- | :--- | :--- |
| `admin_ezequiel` | `equipo-it`, `sudo` | `/bin/bash` | Total (`rwx` vía grupo) | Administrador de sistemas con elevación |
| `lector_invitado` | `equipo-it` | `/bin/bash` | Lectura/Escritura vía grupo | Usuario de consulta / operativo |
| `svc_backup` | `svc_backup` | `/usr/sbin/nologin` | Nulo por terminal (Solo ejecución) | Cuenta de servicio automatizada |

---

## 🛠️ 2. Despliegue del Laboratorio (Paso a Paso)

### Paso 1: Creación del Grupo y Directorio Compartido FHS
```bash
# Crear directorio de trabajo compartido en /srv
sudo mkdir -p /srv/compartida

# Crear el grupo común para el equipo
sudo groupadd equipo-it
```

### Paso 2: Creación de Usuarios con Roles Específicos
```bash
# 1. Administrador (con carpeta home, grupo secundario 'equipo-it' y acceso a 'sudo')
sudo useradd -m -G equipo-it,sudo -s /bin/bash admin_ezequiel

# 2. Lector (con carpeta home y grupo secundario 'equipo-it')
sudo useradd -m -G equipo-it -s /bin/bash lector_invitado

# 3. Cuenta de Servicio (de sistema, sin home, sin shell interactiva)
sudo useradd -r -s /usr/sbin/nologin -M svc_backup
```

### Paso 3: Asignación de Propiedad y Permisos Octales (770)
```bash
# Cambiar dueño (root) y grupo propietario (equipo-it)
sudo chown root:equipo-it /srv/compartida

# Otorgar acceso total a dueño y grupo, cerrando acceso a 'otros' (770)
sudo chmod 770 /srv/compartida
```

---

## 🧪 3. Pruebas y Verificación de Seguridad

### Verificación de Asignación de Grupos
```bash
id admin_ezequiel
id lector_invitado
id svc_backup
```

### Prueba de Bloqueo de Shell (`nologin`)
Para probar el bloqueo de una cuenta de servicio sin shell, se debe usar `sudo` para omitir la solicitud de contraseña (ya que las cuentas del sistema carecen de password activa):

```bash
sudo su - svc_backup
```

**Resultado obtenido:**
```text
This account is currently not available.
```
*Esto valida que el Kernel de Linux rechaza inmediatamente el inicio de cualquier sesión interactiva para este usuario.*

---

## 🧠 4. Justificación Técnica de Seguridad (Pregunta de Entrevista)

### ¿Por qué se utilizó `/usr/sbin/nologin` para la cuenta `svc_backup`?
Aplicando el **Principio de Menor Privilegio**, las cuentas de servicio destinadas únicamente a ejecutar tareas en segundo plano (como cronjobs, respaldos o demonios) jamás deben tener una shell interactiva (`/bin/bash`).

Al definir la shell en `/usr/sbin/nologin`, en caso de que una contraseña o credencial de esta cuenta sea comprometida, un atacante no podrá abrir una terminal interactiva a través de SSH ni por consola local, reduciendo drásticamente la superficie de ataque del servidor.

---

## 📌 Comandos clave aprendidos
* `chmod 770 <directorio>`: Lectura, escritura y ejecución para dueño y grupo; sin acceso para terceros.
* `chown usuario:grupo <ruta>`: Cambia el usuario y grupo propietario simultáneamente.
* `useradd -r -s /usr/sbin/nologin -M`: Crea un usuario de sistema sin shell interactiva ni directorio home.
* `id <usuario>`: Revela el UID (ID de usuario), GID (ID de grupo primario) y grupos secundarios.
* `ls -ld <directorio>`: Inspecciona los permisos directos del contenedor en lugar de listar sus archivos internos.

---

## 🖼️ Capturas de Pantalla

![Permisos de directorio e IDs de usuario](screenshots/dia6-permisos-srv.png)
*Verificación de permisos `770` (`drwxrwx---`) asignados a `root:equipo-it` en `/srv/compartida` y estado de los grupos de cada usuario.*

![Validacion de bloqueo nologin](screenshots/dia6-nologin.png)
*Demostración de seguridad: el Kernel rechaza la terminal interactiva para la cuenta de servicio `svc_backup`.*