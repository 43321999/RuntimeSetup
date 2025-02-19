# cloudphone.md
> на мак нет iptables, пример настройки правил nat, внизу
```sh
#!/bin/bash

# Определение внешнего IP
SERVER_EXTERNAL_IP=$(curl -s ifconfig.me || curl -s icanhazip.com)

# Параметры сети
SERVER_IP="10.7.0.1"
CLIENT_IP="10.7.0.2"
PRIVATE_KEY_PATH="/tmp/wg_private.key"
PUBLIC_KEY_PATH="/tmp/wg_public.key"
CONFIG_DIR="./wg-configs"

# Создаём директорию для конфигов
mkdir -p $CONFIG_DIR

# Генерация ключей для сервера и клиента
wg genkey | tee $PRIVATE_KEY_PATH | wg pubkey > $PUBLIC_KEY_PATH

# Сетевые настройки
SERVER_PRIVATE_KEY=$(cat $PRIVATE_KEY_PATH)
SERVER_PUBLIC_KEY=$(cat $PUBLIC_KEY_PATH)
CLIENT_PRIVATE_KEY=$(wg genkey)
CLIENT_PUBLIC_KEY=$(echo $CLIENT_PRIVATE_KEY | wg pubkey)

# Сетевые настройки для сервера
cat > $CONFIG_DIR/server.conf <<EOL
[Interface]
Address = $SERVER_IP/24
PrivateKey = $SERVER_PRIVATE_KEY
ListenPort = 51820

[Peer]
PublicKey = $CLIENT_PUBLIC_KEY
AllowedIPs = $CLIENT_IP/32
EOL

# Сетевые настройки для клиента
cat > $CONFIG_DIR/client.conf <<EOL
[Interface]
Address = $CLIENT_IP/24
PrivateKey = $CLIENT_PRIVATE_KEY
DNS = 1.1.1.1

[Peer]
PublicKey = $SERVER_PUBLIC_KEY
Endpoint = $SERVER_EXTERNAL_IP:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOL

# Включаем IP-форвардинг
sysctl -w net.ipv4.ip_forward=1

# Настраиваем NAT через iptables
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i wg0 -j ACCEPT
iptables -A FORWARD -o wg0 -j ACCEPT

# Оставляем серверный конфиг для дальнейшего использования (не выводим в консоль)
echo "Server config saved to $CONFIG_DIR/server.conf"

# Отображаем клиентский конфиг в консоль
echo "Client config saved to $CONFIG_DIR/client.conf"
cat $CONFIG_DIR/client.conf

# Очистка временных ключей
rm -f $PRIVATE_KEY_PATH $PUBLIC_KEY_PATH
```
- ```chmod +x```
- ```bash```

> ```sh
> # действия после перезагрузи
> # точно сбрасывается после перезагрузки:
> sudo su
> sysctl net.inet.ip.forwarding
> # sysctl -w net.inet.ip.forwarding=1
> wg-quick up wg0
> # неточно сбрасывается после перезагрузки:
> pfctl -s nat
> # echo "nat on en0 from 10.7.0.2/24 to any -> (en0)" | sudo pfctl -ef -
> ```

