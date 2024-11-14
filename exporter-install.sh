#!/bin/bash

# Variables
NODE_EXPORTER_VERSION="1.6.1"
NODE_EXPORTER_USER="node_exporter"
NODE_EXPORTER_SERVICE="/etc/systemd/system/node_exporter.service"

# Descargar Node Exporter
echo "Descargando Node Exporter..."
wget https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz

# Extraer y mover el binario a /usr/local/bin
echo "Extrayendo Node Exporter..."
tar xvf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
cd node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/
sudo mv node_exporter /usr/local/bin/

# Crear usuario para Node Exporter sin acceso a shell
echo "Creando usuario ${NODE_EXPORTER_USER}..."
sudo useradd -rs /bin/false ${NODE_EXPORTER_USER}

# Configurar el servicio systemd
echo "Creando archivo de servicio systemd para Node Exporter..."
sudo tee ${NODE_EXPORTER_SERVICE} > /dev/null <<EOF
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=${NODE_EXPORTER_USER}
Group=${NODE_EXPORTER_USER}
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=default.target
EOF

# Recargar los demonios de systemd y habilitar el servicio
echo "Habilitando y arrancando Node Exporter..."
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter

# Verificar que Node Exporter esté funcionando
echo "Verificando la instalación..."
curl -s http://localhost:9100/metrics | head -n 10

echo "Instalación de Node Exporter completada. El servicio está habilitado y funcionando."