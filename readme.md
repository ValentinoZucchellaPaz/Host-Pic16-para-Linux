# AN1310 Python Host para PIC16

Este repositorio contiene un host Python para cargar programas `.hex` en microcontroladores PIC16 usando el bootloader AN1310. Funciona en **Linux** con adaptadores USB a TTL (ej. CP2102, FTDI).

---

## Requisitos

- Python 3.8+  
- `pip`  
- Adaptador USB a TTL conectado al PIC16 con el bootloader AN1310.  

> Este host soporta CP2102 y FTDI FT230X de forma predeterminada.

---

## 1. Clonar el repositorio

```bash
# con SSH
git clone git@github.com:ValentinoZucchellaPaz/Host-Pic16-para-Linux.git
# con HTTPS
git clone https://github.com/ValentinoZucchellaPaz/Host-Pic16-para-Linux.git
cd an1310_host
```

## 2. Setup del proyecto

Puedes hacerlo manual (copiar las instrucciones de setup.sh) o ejecutar el archivo `setup.sh`.

### Para ejecutar setup.sh:

```bash
chmod +x setup.sh
./setup.sh
```

## 3. Configurar permisos del puerto USB

En caso que no tengas permisos para acceder al puerto serial o las configuraciones no funcionen, sigue estos pasos:

1. Conecta tu adaptador USB a TTL al PIC.

2. Verifica el puerto asignado:

```bash
ls /dev/ttyUSB*
```

Normalmente será /dev/ttyUSB0. Si /dev/ttyUSB0 no aparece, significa que el kernel no está reconociendo el dispositivo o no está cargado el driver.

3. Agrega tu usuario al grupo dialout para poder acceder al puerto sin sudo:

```bash
sudo usermod -aG dialout $USER
```

4. Cierra sesión y vuelve a entrar para que el cambio surta efecto.

## 5. Ejecutar el host
Opción 1: especificando el puerto manualmente **recomendado**
```bash
python host.py -p /dev/ttyUSB0 ./binarios/***archivo binario a exe***.hex
```

Opción 2: autodetección del puerto
Si tu adaptador es CP2102 o FTDI FT230X, el host lo detecta automáticamente:

```bash
python host.py digIIboard_asm.X.production.hex
```

## 6. Flujo de programación
- El host solicitará hacer un reset del PIC si no está en modo bootloader.
- Se conectará al bootloader AN1310.
- Enviará el programa .hex al PIC.
- Verificará que el programa se haya cargado correctamente.
- Ejecutará el programa cargado y abrirá un terminal serial para interactuar con él.
- Para salir del terminal serial: Ctrl+C.

## 7. Notas
- Asegúrate de que el .hex que subas sea compatible con tu PIC y el bootloader AN1310.
- La autodetección funciona solo con adaptadores CP2102 (VID=10C4, PID=EA60) y FTDI FT230X (VID=0403, PID=6015). Para otros adaptadores, pasa el puerto manualmente con -p.
- El baud rate de bootloader se puso a 19200, el terminal serial en 9600. Esto se puede cambiar en el código si es necesario.
