# Парная гастройка Docker Swarm со штурманом

Эта инструкция описывает, как настроить кластер Docker Swarm с поддержкой IPv6.

## Шаг 1. Установка Docker

На всех узлах установите Docker:
```bash
sudo apt update
sudo apt install docker.io
sudo systemctl enable docker
sudo systemctl start docker
```

## Шаг 2. Инициализация Swarm

### 1. Инициализируйте Swarm на узле `01`:
```bash
docker swarm init --advertise-addr fd01::
```

### 2. Присоедините узел `1c`:
На узле `1c` выполните команду, показанную Docker на предыдущем шаге. Например:
```bash
docker swarm join --token <TOKEN> fd01::2377
```

## Шаг 3. Создание сети

Создайте IPv6-сеть Swarm:
```bash
docker network create \
  --driver overlay \
  --subnet fd01::/64 \
  --ipv6 \
  swarm_net
```

## Шаг 4. Запуск сервисов

Запустите сервисы, подключенные к этой сети:
```bash
docker service create --name my_service \
  --network swarm_net \
  nginx
```

## Шаг 5. Проверка связи

1. Проверьте связь между контейнерами:
```bash
docker exec -it <CONTAINER_ID> ping6 fd01::1
```

2. Убедитесь, что контейнеры могут выходить в интернет:
```bash
docker exec -it <CONTAINER_ID> curl -6 http://google.com
```
