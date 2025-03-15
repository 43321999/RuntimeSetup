#!/bin/bash

# === НАСТРОЙКИ ===
BA_NODE_INTERFACE="ba"
AB_NODE_INTERFACE="ab"
AA_NODE_INTERFACE="aa"
WG_PORT="1026"  # Порт WireGuard
WG_DIR="/etc/wireguard"
CONFIG_DIR="$WG_DIR/configs"

# Определяем внешний IP сервера (SE)
SERVER_EXTERNAL_IP=$(curl -s ifconfig.me || curl -s icanhazip.com)

# Определяем внешний интерфейс (чтобы не жёстко использовать eth0)
EXT_IFACE=$(ip route | grep default | awk '{print $5}')

# Подсети IPv6
SERVER_TEST_IP="fcba::/16"
SERVER_PROD_IP="fdba::/16"
WIREGUARD_TEST_IP="fcab::/16"
WIREGUARD_PROD_IP="fdab::/16"
RU_TEST_IP="fcaa::/8"
RU_PROD_IP="fdaa::/8"

# Дополнительные IP-адреса для интранета
ALLOWED_IPS="00::164,01::164,02::164,03::164,04::164,05::164,06::164,07::164,08::164,09::164,10::164,11::164,12::164,13::164,14::164,15::164"

# Создаём директории
mkdir -p $CONFIG_DIR

# Генерация ключей для сервера
wg genkey | tee /tmp/wg_private.key | wg pubkey > /tmp/wg_public.key
SERVER_PRIVATE_KEY=$(cat /tmp/wg_private.key)
SERVER_PUBLIC_KEY=$(cat /tmp/wg_public.key)

# Генерация ключей для клиентов
RU_PRIVATE_KEY=$(wg genkey)
RU_PUBLIC_KEY=$(echo $RU_PRIVATE_KEY | wg pubkey)

# Добавляем генерацию ключей для WIREGUARD клиента
WIREGUARD_PRIVATE_KEY=$(wg genkey)
WIREGUARD_PUBLIC_KEY=$(echo $WIREGUARD_PRIVATE_KEY | wg pubkey)

# Конфигурация сервера ba
cat > $WG_DIR/$BA_NODE_INTERFACE.conf <<EOL
[Interface]
Address = $SERVER_TEST_IP,$SERVER_PROD_IP
PrivateKey = $SERVER_PRIVATE_KEY
ListenPort = $WG_PORT

[Peer]
PublicKey = $WIREGUARD_PUBLIC_KEY
AllowedIPs = $WIREGUARD_TEST_IP,$WIREGUARD_PROD_IP

[Peer]
PublicKey = $RU_PUBLIC_KEY
AllowedIPs = $RU_TEST_IP,$RU_PROD_IP
EOL

# Конфигурация клиента ab
cat > $CONFIG_DIR/$AB_NODE_INTERFACE.conf <<EOL
[Interface]
Address = $WIREGUARD_TEST_IP,$WIREGUARD_PROD_IP
PrivateKey = $WIREGUARD_PRIVATE_KEY

[Peer]
PublicKey = $SERVER_PUBLIC_KEY
Endpoint = $SERVER_EXTERNAL_IP:$WG_PORT
AllowedIPs = $SERVER_TEST_IP,$SERVER_PROD_IP,$ALLOWED_IPS
PersistentKeepalive = 25
EOL

# Конфигурация клиента aa
cat > $CONFIG_DIR/$AA_NODE_INTERFACE.conf <<EOL
[Interface]
Address = $RU_TEST_IP,$RU_PROD_IP
PrivateKey = $RU_PRIVATE_KEY

[Peer]
PublicKey = $SERVER_PUBLIC_KEY
Endpoint = $SERVER_EXTERNAL_IP:$WG_PORT
AllowedIPs = $SERVER_TEST_IP,$SERVER_PROD_IP,$ALLOWED_IPS
PersistentKeepalive = 25
EOL

# Включаем IP-форвардинг для IPv4
sysctl -w net.ipv4.ip_forward=1

# Сохранение конфигов
echo "Server config saved to $WG_DIR/$BA_NODE_INTERFACE.conf"
echo "Client WIREGUARD config saved to $CONFIG_DIR/$AB_NODE_INTERFACE.conf"
echo "Client RU config saved to $CONFIG_DIR/$AA_NODE_INTERFACE.conf"

# Очистка временных ключей
rm -f /tmp/wg_private.key /tmp/wg_public.key