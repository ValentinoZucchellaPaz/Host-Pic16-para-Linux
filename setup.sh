# !/bin/bash

# ========================================
# Script de configuración para AN1310 Host
# ========================================

set -e  # Si algo falla, se detiene el script

echo "🔧 Configurando entorno para AN1310 Host..."

# 1. Crear entorno virtual si no existe
if [ ! -d ".venv" ]; then
    echo "📦 Creando entorno virtual..."
    python3 -m venv .venv
else
    echo "✅ Entorno virtual ya existe."
fi

# 2. Activar entorno virtual
echo "🚀 Activando entorno virtual..."
source .venv/bin/activate

# 3. Instalar dependencias
echo "📥 Instalando dependencias..."
pip install --upgrade pip
pip install pyserial intelhex crcmod

# 4. Verificar puerto serial disponible
echo "🔍 Buscando puertos /dev/ttyUSB* ..."
ls /dev/ttyUSB* 2>/dev/null || echo "⚠️  No se detectó ningún dispositivo USB-Serial. Conecta el adaptador."

# 5. Recordar configurar permisos
echo ""
echo "⚠️  IMPORTANTE: Si no lo hiciste antes, da permisos al usuario con:"
echo "   sudo usermod -aG dialout \$USER"
echo "   (Luego cierra sesión y vuelve a entrar)"
echo ""

echo "✅ Setup completado. Para usar el host:"
echo "   python host.py -p /dev/ttyUSB0 ./binarios/archivo.hex"