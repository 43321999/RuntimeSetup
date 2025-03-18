# Настройка Docker Swarm

Эта инструкция содержит пошаговую настройку кластера Docker Swarm. Общая логика адресации и архитектура кластеров описаны в файле **DockerSwarm_Overview.md**.

## Шаг 1. Установка Docker

На всех узлах выполните:
```bash
sudo apt update
sudo apt install docker.io
sudo systemctl enable docker
sudo systemctl start docker
```

## Шаг 2. Инициализация Swarm

Выберите мастер-узел (например, узел `aa`):
- **Для продакшн (CD):**  
  Узел использует свою подсеть `fdaa::/64`, входящую в общую сеть `fd00::/16`.
  ```bash
  docker swarm init --advertise-addr fdaa::
  ```
- **Для тестовой (CI):**  
  Узел использует подсеть `fcaa::/64`:
  ```bash
  docker swarm init --advertise-addr fcaa::
  ```
При необходимости можно указать упрощённый IPv4 адрес:
```bash
docker swarm init --advertise-addr 10.11
```

## Шаг 3. Присоединение воркеров

На воркер-узлах (например, узел `ab`):
- **Для продакшн:**
  ```bash
  docker swarm join --token <TOKEN> fdaa::2377
  ```
- **Для тестовой:**
  ```bash
  docker swarm join --token <TOKEN> fcaa::2377
  ```
Или с использованием IPv4:
```bash
docker swarm join --token <TOKEN> 10.11:2377
```

## Шаг 4. Создание оверлейной сети

Создайте сеть с поддержкой IPv6:
```bash
docker network create \
  --driver overlay \
  --subnet fdaa::/64 \
  --ipv6 \
  swarm_net
```
*Примечание:* Для тестовой среды можно создать сеть с подсетью `fcaa::/64`. Общая архитектура остаётся в рамках сети `fd00::/16`.

## Шаг 5. Запуск сервисов

Запустите сервисы, подключённые к созданной сети:
```bash
docker service create --name my_service \
  --network swarm_net \
  nginx
```

## Шаг 6. Проверка связи

- **IPv6:**  
  ```bash
  docker exec -it <CONTAINER_ID> ping6 fdaa::1
  docker exec -it <CONTAINER_ID> curl -6 http://google.com
  ```
- **IPv4:**  
  ```bash
  docker exec -it <CONTAINER_ID> ping -c 1 10.11
  ```