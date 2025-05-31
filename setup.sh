#!/bin/bash

# Preguntar por el puerto
read -p "Ingresa el puerto que deseas abrir en Dropbear: " DPORT

# Validar el puerto
if ! [[ "$DPORT" =~ ^[0-9]+$ ]] || [ "$DPORT" -lt 1 ] || [ "$DPORT" -gt 65535 ]; then
    echo "Puerto inválido. Se usará el puerto 22 por defecto."
    DPORT=22
fi

# Descargar el script que contiene fun_dropbear
wget -O /root/fun_dropbear.sh https://raw.githubusercontent.com/tu-repo/tu-archivo/fun_dropbear.sh
chmod +x /root/fun_dropbear.sh

# Ejecutar la función pasándole el puerto
bash /root/fun_dropbear.sh "$DPORT"

# Crear servicio systemd para que inicie automáticamente
cat <<EOF > /etc/systemd/system/dropbear_instalacion.service
[Unit]
Description=Instalador y configurador Dropbear
After=network.target

[Service]
Type=simple
ExecStart=/bin/bash -c 'bash /root/fun_dropbear.sh "$DPORT"'
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Habilitar y arrancar servicio
systemctl daemon-reload
systemctl enable dropbear_instalacion.service
systemctl start dropbear_instalacion.service

# Abrir puerto en UFW
ufw allow "$DPORT"/tcp

echo "Dropbear se configuró en el puerto $DPORT y se iniciará automáticamente al reiniciar."
