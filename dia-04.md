# Día 4 — Instalación de Ubuntu Server + primeros pasos

## Especificaciones de la VM

- Hostname: `skl-srv-estudio`
- Usuario: `skl`
- CPU: 2 vCPU asignadas (host: AMD Ryzen 7 5700X)
- RAM: ~1.9 GiB
- Disco: 20 GB (con LVM)
- Virtualización: KVM (full)

## Particionado (LVM)

Salida de `lsblk`:

```
sda           20G  disk
├─sda1         1M  part
├─sda2       1.8G  part /boot
└─sda3      18.2G  part
  └─ubuntu--vg-ubuntu--lv  10G  lvm  /
```

**Nota para mí**: usa LVM (Logical Volume Manager) sobre sda3. Esto significa que el disco de 20GB no está completamente asignado a `/` (solo 10G del `ubuntu--vg`) — queda espacio libre en el volume group para expandir después si hace falta. Preguntar/investigar: `vgs`, `lvextend`.

## Comandos ejecutados hoy

| Comando | Qué hace |
|------|------|
| `lscpu` | Muestra info de la CPU (arquitectura, núcleos, virtualización, vulnerabilidades) |
| `free -h` | Muestra uso de memoria RAM y swap en formato legible (human-readable) |
| `lsblk` | Lista los discos y particiones del sistema en forma de árbol |
| `ip a` | Muestra las interfaces de red y sus direcciones IP |
| `sudo apt update && sudo apt upgrade -y` | Actualiza la lista de paquetes y luego los paquetes instalados |
| `sudo systemctl status ssh` | Verifica que el servicio SSH esté corriendo |

## Acceso SSH

- IP de la VM: `[10.0.2.15]`
- Método de conexión: `ssh -p 2222 skl@127.0.0.1`
- Estado del servicio: activo (`systemctl status ssh` → running)

## Capturas

![lscpu-lsblk](img\captura-lscpu-lsblk.png)

## Duda para mañana

¿Por qué el instalador armó LVM en vez de una partición simple para `/`? ¿Qué ventaja da esto en un entorno de sysadmin real?