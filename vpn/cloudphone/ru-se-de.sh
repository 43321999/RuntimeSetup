#!/bin/bash

# === НАСТРОЙКИ ===
WG_INTERFACE="wg_se_net"  # Уникальное имя интерфейса
WG_PORT="1026"  # Порт WireGuard
WG_DIR="/etc/wireguard"
CONFIG_DIR="$WG_DIR/configs"

# Определяем внешний IP сервера (SE)
SERVER_EXTERNAL_IP=$(curl -s ifconfig.me || curl -s icanhazip.com)

# Определяем внешний интерфейс (чтобы не жёстко использовать eth0)
EXT_IFACE=$(ip route | grep default | awk '{print $5}')

# Подсеть
SUBNET="10.7.0.0/24"
SERVER_IP="10.7.0.1"
RU_IP="10.7.0.2"
DE_IP="10.7.0.3"

# Создаём директории
mkdir -p $CONFIG_DIR

# Генерация ключей для сервера
wg genkey | tee /tmp/wg_private.key | wg pubkey > /tmp/wg_public.key
SERVER_PRIVATE_KEY=$(cat /tmp/wg_private.key)
SERVER_PUBLIC_KEY=$(cat /tmp/wg_public.key)

# Генерация ключей для клиентов
RU_PRIVATE_KEY=$(wg genkey)
RU_PUBLIC_KEY=$(echo $RU_PRIVATE_KEY | wg pubkey)

DE_PRIVATE_KEY=$(wg genkey)
DE_PUBLIC_KEY=$(echo $DE_PRIVATE_KEY | wg pubkey)

# Конфигурация сервера (SE)
cat > $WG_DIR/$WG_INTERFACE.conf <<EOL
[Interface]
Address = $SERVER_IP/24
PrivateKey = $SERVER_PRIVATE_KEY
ListenPort = $WG_PORT

[Peer]
PublicKey = $RU_PUBLIC_KEY
AllowedIPs = $RU_IP/32

[Peer]
PublicKey = $DE_PUBLIC_KEY
AllowedIPs = $DE_IP/32
EOL

# Конфигурация клиента RU (MacOS)
cat > $CONFIG_DIR/client-ru.conf <<EOL
[Interface]
Address = $RU_IP/24
PrivateKey = $RU_PRIVATE_KEY
DNS = 1.1.1.1

[Peer]
PublicKey = $SERVER_PUBLIC_KEY
Endpoint = $SERVER_EXTERNAL_IP:$WG_PORT
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOL

# Конфигурация клиента DE (Android)
cat > $CONFIG_DIR/client-de.conf <<EOL
[Interface]
Address = $DE_IP/24
PrivateKey = $DE_PRIVATE_KEY
DNS = 1.1.1.1

[Peer]
PublicKey = $SERVER_PUBLIC_KEY
Endpoint = $SERVER_EXTERNAL_IP:$WG_PORT
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOL

# Включаем IP-форвардинг
sysctl -w net.ipv4.ip_forward=1

# Настраиваем NAT через iptables
iptables -t nat -A POSTROUTING -o $EXT_IFACE -j MASQUERADE
iptables -A FORWARD -i $WG_INTERFACE -j ACCEPT
iptables -A FORWARD -o $WG_INTERFACE -j ACCEPT

# Сохранение конфигов
echo "Server config saved to $WG_DIR/$WG_INTERFACE.conf"
echo "Client RU config saved to $CONFIG_DIR/client-ru.conf"
echo "Client DE config saved to $CONFIG_DIR/client-de.conf"

# Очистка временных ключей
rm -f /tmp/wg_private.key /tmp/wg_public.key
