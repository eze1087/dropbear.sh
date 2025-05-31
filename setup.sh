#!/bin/bash

# Define las rutas
SCPdir="/etc/VPS-MX"
SCPfrm="${SCPdir}/herramientas"
SCPinst="${SCPdir}/protocolos"
SCRIPT_PATH="/root/dropbear.sh"  # Aquí descargaremos el script de Dropbear

# Crear las carpetas si no existen
mkdir -p "$SCPfrm"
mkdir -p "$SCPinst"

# Descargar el script de Dropbear desde GitHub
DROPBEAR_URL="https://raw.githubusercontent.com/eze1087/dropbear.sh/refs/heads/main/autodropbear"
wget -O "$SCRIPT_PATH" "$DROPBEAR_URL"
chmod +x "$SCRIPT_PATH"

# Crear el script principal que invocará a dropbear (puedes personalizarlo o llamarlo directamente)
# Aquí simplemente llamamos al script descargado
cat <<EOF > /root/execute_dropbear.sh
#!/bin/bash
bash "$SCRIPT_PATH"
EOF

chmod +x /root/execute_dropbear.sh

# Crear servicio systemd
cat <<EOF > /etc/systemd/system/dropbear_setup.service
[Unit]
Description=Iniciar script de configuración Dropbear
After=network.target

[Service]
Type=simple
ExecStart=/bin/bash /root/execute_dropbear.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Habilitar y arrancar el servicio
systemctl daemon-reload
systemctl enable dropbear_setup.service
systemctl start dropbear_setup.service

echo "Setup completo. Dropbear se descargó, configuró y el servicio está activo para iniciarse automáticamente al reiniciar."
