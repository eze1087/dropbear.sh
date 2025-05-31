#!/bin/bash

# Rutas y carpetas
SCPdir="/etc/VPS-MX"
SCPfrm="${SCPdir}/herramientas"
SCPinst="${SCPdir}/protocolos"

# Crear las carpetas si no existen
mkdir -p "$SCPfrm"
mkdir -p "$SCPinst"

# Ruta del script principal
SCRIPT_PATH="/root/dropbear_setup.sh"

# Crear el script que contiene toda la configuración
cat <<'EOF' > "$SCRIPT_PATH"
#!/bin/bash
# Aquí debes poner todo el contenido del script principal (partes 1 y 2 combinadas)
# Ejemplo:
#chmod +x /root/dropbear_setup.sh
#Y luego llamar a las funciones, o incluir directamente las funciones aquí
EOF

chmod +x "$SCRIPT_PATH"

# Crear el servicio systemd
cat <<EOF > /etc/systemd/system/dropbear_setup.service
[Unit]
Description=Iniciar script de configuración Dropbear
After=network.target

[Service]
Type=simple
ExecStart=$SCRIPT_PATH
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Habilitar y arrancar el servicio
systemctl daemon-reload
systemctl enable dropbear_setup.service
systemctl start dropbear_setup.service

echo "Setup completado y servicio habilitado para arrancar automáticamente."
