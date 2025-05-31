#!/bin/bash
# Fecha y autor
#25/01/2021 - Adaptado para Ubuntu 20/22/24 y con opción de puerto personalizado
clear
clear
SCPdir="/etc/VPS-MX"
SCPfrm="${SCPdir}/herramientas" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="${SCPdir}/protocolos" && [[ ! -d ${SCPinst} ]] && exit
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
mportas () {
    unset portas
    portas_var=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" | grep -v "COMMAND" | grep "LISTEN")
    while read port; do
        var1=$(echo $port | awk '{print $1}')
        var2=$(echo $port | awk '{print $9}' | awk -F ":" '{print $2}')
        [[ "$(echo -e $portas|grep "$var1 $var2")" ]] || portas+="$var1 $var2\n"
    done <<< "$portas_var"
    echo -e "$portas"
}
# Función para preguntar y configurar Dropbear
fun_dropbear () {
    # Preguntar por el puerto
    echo -e "${cor[1]}$(echo "¿Qué puerto deseas abrir en Dropbear?")${cmar}"
    read -p "Puerto: " DPORT

    # Validar puerto
    if ! [[ "$DPORT" =~ ^[0-9]+$ ]] || [ "$DPORT" -lt 1 ] || [ "$DPORT" -gt 65535 ]; then
        echo -e "${cor[2]}Puerto inválido, se usará el puerto 22.${cmar}"
        DPORT=22
    fi

    # Instalar Dropbear si no está, y eliminar configuración previa
    apt-get update -y
    apt-get install dropbear -y
    service dropbear stop

    # Configurar Dropbear
    sed -i "/^NO_START=/c\NO_START=0" /etc/default/dropbear
    sed -i "/^DROPBEAR_PORT=/c\DROPBEAR_PORT=\"$DPORT\"" /etc/default/dropbear
    if ! grep -q "^DROPBEAR_PORT=" /etc/default/dropbear; then
        echo "DROPBEAR_PORT=\"$DPORT\"" >> /etc/default/dropbear
    fi

    # Crear servicio systemd para Dropbear
    cat <<EOF > /etc/systemd/system/dropbear_custom.service
[Unit]
Description=Dropbear SSH Server Custom Port
After=network.target

[Service]
Type=simple
ExecStart=/usr/sbin/dropbear -E -F -p $DPORT
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

    # Habilitar e iniciar el servicio
    systemctl daemon-reload
    systemctl enable dropbear_custom.service
    systemctl start dropbear_custom.service

    # abrir en UFW
    ufw allow $DPORT/tcp > /dev/null 2>&1

    echo -e "${cor[4]} Dropbear configurado en puerto $DPORT y se inicia automáticamente.${cmar}"
}
# Llamar a la función para configurar dropbear
fun_dropbear
