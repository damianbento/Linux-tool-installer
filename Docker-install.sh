#!/bin/bash

# Solicitar el nombre del usuario sudo y la contraseña
read -p "Ingrese el nombre de un usuario con privilegios de sudo: " SUDO_USER
read -sp "Ingrese la contraseña de sudo para $SUDO_USER: " SUDO_PASS
echo

# Configura sudo temporalmente para no pedir contraseña para el usuario sudo especificado
echo "$SUDO_PASS" | sudo -S echo "$SUDO_USER ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/${SUDO_USER}_docker_install

# Actualizar repositorios y preparar dependencias
echo "Actualizando repositorios..."
echo "$SUDO_PASS" | sudo -S apt update
echo "$SUDO_PASS" | sudo -S apt install -y apt-transport-https ca-certificates curl software-properties-common

# Descargar y agregar la clave GPG de Docker
echo "Descargando clave GPG de Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Agregar el repositorio de Docker
echo "Agregando repositorio de Docker..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Actualizar repositorios e instalar Docker
echo "Instalando Docker..."
echo "$SUDO_PASS" | sudo -S apt update
echo "$SUDO_PASS" | sudo -S apt install -y docker-ce

# Instalar Docker Compose
echo "Instalando Docker Compose..."
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verificar la instalación de Docker Compose
docker-compose --version

# Agregar el usuario especificado al grupo de Docker
echo "Agregando usuario al grupo de Docker..."
sudo usermod -aG docker $SUDO_USER

# Reiniciar sesión del usuario para aplicar cambios en el grupo
echo "Reiniciando sesión de usuario..."
su - $SUDO_USER

# Eliminar configuración temporal de sudo sin contraseña
sudo rm /etc/sudoers.d/${SUDO_USER}_docker_install

echo "Instalación completada. Por favor, cierra y vuelve a abrir la terminal para aplicar los cambios."