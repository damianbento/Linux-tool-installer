#!/bin/bash

# Deshabilitar y detener el servicio multipathd
echo "Deshabilitando y deteniendo el servicio multipathd..."
sudo systemctl disable multipathd.service
sudo systemctl stop multipathd.service

# Obtener la configuración de IP actual de la interfaz enp3s0
INTERFACE="enp3s0"
IP_ADDRESS=$(ip -4 addr show $INTERFACE | grep -oP "(?<=inet\s)\d+(\.\d+){3}(?=/)")
GATEWAY=$(ip route | grep default | awk '{print $3}')

# Crear archivo de configuración de Netplan
NETPLAN_CONFIG="/etc/netplan/01-netcfg.yaml"
echo "Creando archivo de configuración de Netplan en $NETPLAN_CONFIG..."

sudo tee $NETPLAN_CONFIG > /dev/null <<EOF
network:
  version: 2
  ethernets:
    ${INTERFACE}:
      dhcp4: no
      addresses:
        - ${IP_ADDRESS}/24
      gateway4: ${GATEWAY}
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
EOF

# Aplicar la configuración de Netplan
echo "Aplicando la configuración de Netplan..."
sudo netplan apply

echo "Configuración completada. La IP, gateway y DNS han sido configurados en $NETPLAN_CONFIG"