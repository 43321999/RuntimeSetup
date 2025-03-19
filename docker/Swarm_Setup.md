# Настройка Docker Swarm (Swarm Setup)

Ниже приведён пример пошаговой настройки одного узла в кластере Docker Swarm.

#### 1. Установка Docker

На каждом узле выполните:
```bash
sudo apt update
sudo apt install docker.io
sudo systemctl enable docker
sudo systemctl start docker
```

#### 2. Инициализация Swarm

Выберите мастер-узел (например, **aa**):

- **Для продакшн (CD):**  
  Используется подсеть, выделенная для пользователя **d** (например, `fdaa::/16` внутри общей сети):
  ```bash
  docker swarm init --advertise-addr fdaa::
  ```
- **Для тестовой (CI):**  
  Используется подсеть для пользователя **c** (например, `fcaa::/16`):
  ```bash
  docker swarm init --advertise-addr fcaa::
  ```

*При необходимости можно использовать упрощённые IPv4‑адреса (например, 10.11) для инициализации.*

#### 3. Присоединение воркеров

На воркер-узлах (например, **ab**):
- Для продакшн:
  ```bash
  docker swarm join --token <TOKEN> fdaa::2377
  ```
- Для тестовой:
  ```bash
  docker swarm join --token <TOKEN> fcaa::2377
  ```

#### 4. Создание оверлейной сети

Создайте сеть с поддержкой IPv6 для контейнеров:
```bash
docker network create \
  --driver overlay \
  --subnet fdaa::/64 \
  --ipv6 \
  swarm_net
```
Для тестовой среды можно создать сеть с подсетью `fcaa::/64`. Общая архитектура остаётся в рамках общей сети.

#### 5. Запуск сервисов

Пример запуска сервиса:
```bash
docker service create --name my_service \
  --network swarm_net \
  nginx
```

#### 6. Проверка связи

- **IPv6:**  
  ```bash
  docker exec -it <CONTAINER_ID> ping6 fdaa::1
  docker exec -it <CONTAINER_ID> curl -6 http://google.com
  ```
- **IPv4:**  
  (Проверка упрощённой IPv4‑адресации производится согласно отдельной документации.)
