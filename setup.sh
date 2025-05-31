#!/bin/bash

# Preguntar por el puerto
read -p "Ingresa el puerto que deseas abrir en Dropbear: " DPORT

# Validar el puerto
if ! [[ "$DPORT" =~ ^[0-9]+$ ]] || [ "$DPORT" -lt 1 ] || [ "$DPORT" -gt 65535 ]; then
    echo "Puerto inválido. Se usará el puerto 22 por defecto."
    DPORT=22
fi

# Descargar tu script de instalación
wget -O /root/instalar_dropbear.sh https://raw.githubusercontent.com/eze1087/dropbear.sh/refs/heads/main/instalar_dropbear.sh
chmod +x /root/instalar_dropbear.sh

# Ejecutar el script pasando el puerto
bash /root/instalar_dropbear.sh "$DPORT"

# Crear un servicio systemd para que inicie automáticamente después
cat <<EOF > /etc/systemd/system/dropbear_auto.service
[Unit]
Description=Dropbear con puerto personalizado
After=network.target

[Service]
Type=simple
ExecStart=/bin/bash -c 'bash /root/instalar_dropbear.sh "$DPORT"'
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Recargar systemd, habilitar y arrancar
systemctl daemon-reload
systemctl enable dropbear_auto.service
systemctl start dropbear_auto.service

# Abrir el puerto en UFW
ufw allow "$DPORT"/tcp

echo "Dropbear se configuró en el puerto $DPORT y se iniciará automáticamente en cada reinicio."
