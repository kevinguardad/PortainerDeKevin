#!/usr/bin/env bash

# ========================================
#  Script de instalación y configuración
#  Servidor Debian con Docker + Portainer + IP Estática automática
#  Versión mejorada con validaciones
#  By: Nazarhet
# ========================================

# --- Colores ---
verde="\e[32m"
azul="\e[34m"
amarillo="\e[33m"
rojo="\e[31m"
reset="\e[0m"

# ================================
# Comprobar si es root
# ================================
if [[ $EUID -ne 0 ]]; then
    echo -e "${rojo}❌ Debes ejecutar este script como root.${reset}"
    exit 1
fi

# ================================
# Verificar formato del script
# ================================
if file "$0" | grep -q "CRLF"; then
    echo -e "${amarillo}⚠ El script está en formato Windows (CRLF). Corrigiendo...${reset}"
    apt install -y dos2unix >/dev/null
    dos2unix "$0"
    echo -e "${verde}✔ Formato corregido. Vuelve a ejecutarlo.${reset}"
    exit 0
fi

# ================================
# Actualizar sistema
# ================================
echo -e "${azul}🔄 Actualizando el sistema...${reset}"
apt update && apt upgrade -y

# ================================
# Instalar herramientas básicas
# ================================
echo -e "${azul}📦 Instalando herramientas...${reset}"
apt install -y curl wget git unzip zip net-tools htop ufw openssh-server sudo ipcalc

# ================================
# Configuración SSH
# ================================
systemctl enable ssh
systemctl start ssh

# ================================
#!/bin/bash

systemctl enable ssh
systemctl start ssh

# ==============================
#   Autodetectar y configurar red en DHCP
# ==============================

IP_ACTUAL=$(hostname -I | awk '{print $1}')
INTERFAZ=$(ip route | grep 'default' | awk '{print $5}')
GATEWAY=$(ip route | grep 'default' | awk '{print $3}')

echo -e "🔹 IP detectada: $IP_ACTUAL"
echo -e "🔹 Interfaz: $INTERFAZ"
echo -e "🔹 Gateway: $GATEWAY"
echo -e "🔹 Configurando DHCP automático…"

# Hacemos backup del interfaces actual
cp /etc/network/interfaces /etc/network/interfaces.bak

# Escribimos configuración con DHCP
cat > /etc/network/interfaces <<EOL
auto lo
iface lo inet loopback

auto $INTERFAZ
iface $INTERFAZ inet dhcp
EOL

systemctl restart networking
echo -e "✅ Interfaz $INTERFAZ configurada en DHCP."


# ================================
# Instalar Docker
# ================================
echo -e "${azul}🐳 Instalando Docker...${reset}"
curl -fsSL https://get.docker.com | sh
systemctl enable docker
systemctl start docker

# ================================
# Instalar Portainer
# ================================
echo -e "${azul}📦 Instalando Portainer...${reset}"
docker volume create portainer_data
docker run -d \
  -p 8000:8000 \
  -p 9443:9443 \
  --name=portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest

# ================================
# Configuración firewall
# ================================
ufw allow OpenSSH
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 9443/tcp
ufw --force enable

# ================================
# Estructura de carpetas para web
# ================================
mkdir -p ~/servidor_web/{proyectos,scripts,backups}

# ================================
# Mensaje final
# ================================
clear
echo -e "${verde}✅ Configuración completa.${reset}"
echo -e "${azul}🌐 Portainer disponible en: https://$IP_ACTUAL:9443${reset}"
echo -e "${amarillo}💻 Proyectos web en: ~/servidor_web${reset}"
