# Настройка WireGuard

Эта инструкция описывает, как настроить VPN-сеть с использованием WireGuard для узлов.

## Шаг 1. Установка WireGuard

На каждом узле выполните:
```bash
sudo apt update
sudo apt install wireguard
```

## Шаг 2. Настройка узлов

### Узел `ba`

Создайте файл `/etc/wireguard/fd01.conf`:
```ini
[Interface]
Address = fd01::/64
PrivateKey = <ВАШ_ПРИВАТНЫЙ_КЛЮЧ>
ListenPort = 1026
PostUp = ip6tables -A FORWARD -i %i -j ACCEPT; ip6tables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = ip6tables -D FORWARD -i %i -j ACCEPT; ip6tables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
PublicKey = <ПУБЛИЧНЫЙ_КЛЮЧ_УЗЛА_1C>
AllowedIPs = fd1c::/64
Endpoint = <IP_УЗЛА_1C>:1026
PersistentKeepAlive = 25
```

### Узел `1c`

Создайте файл `/etc/wireguard/fd1c.conf`:
```ini
[Interface]
Address = fd1c::/64
PrivateKey = <ВАШ_ПРИВАТНЫЙ_КЛЮЧ>
ListenPort = 1026
PostUp = ip6tables -A FORWARD -i %i -j ACCEPT; ip6tables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = ip6tables -D FORWARD -i %i -j ACCEPT; ip6tables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
PublicKey = <ПУБЛИЧНЫЙ_КЛЮЧ_УЗЛА_01>
AllowedIPs = fd01::/64
PersistentKeepAlive = 25
```

## Шаг 3. Запуск WireGuard

На каждом узле выполните:
```bash
sudo wg-quick up /etc/wireguard/fd01.conf  # Для узла 01
sudo wg-quick up /etc/wireguard/fd1c.conf  # Для узла 1c
```

## Шаг 4. Проверка работы

1. Убедитесь, что туннель запущен:
```bash
sudo wg show
```

2. Проверьте связь между узлами:
```bash
ping6 fd1c::
ping6 fd01::
```