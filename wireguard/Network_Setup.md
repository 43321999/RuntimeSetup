#### 1. **Настройка устройства `aa` (Debian)**

- **Конфигурация интерфейса**

  Узел `aa` (например, мастер) настраивается следующим образом:

  - **IPv4:**  
    Используется упрощённая запись:
    ```sh
    auto ens128
    iface ens128 inet static
        address 10.11
        netmask 255.255.255.0
    ```
  
  - **IPv6:**  
    Узел получает свою уникальную подсеть `/64` внутри общей сети `fd00::/16`.
    - Для продакшн (CD):
      ```sh
      iface ens128 inet6 static
          address fdaa::
          netmask 64
      ```
    - Для тестовой (CI):
      ```sh
      iface ens128 inet6 static
          address fcaa::
          netmask 64
      ```

- **Добавление маршрутов (пример для IPv6):**
  ```sh
  sudo ip -6 route add fdab::/16 dev ens128
  sudo ip -6 route add fcab::/16 dev ens128
  ```

- **Настройка таблицы соседей (NDP):**
  ```sh
  sudo ip -6 neigh add fdab:: lladdr <MAC-адрес> dev ens128 nud permanent
  sudo ip -6 neigh add fcab:: lladdr <MAC-адрес> dev ens128 nud permanent
  ```

- **Применение изменений:**
  ```sh
  sudo ifdown ens128 && sudo ifup ens128
  # или
  sudo systemctl restart networking
  ```

- **Проверка конфигурации:**
  ```sh
  ip -6 addr show dev ens128
  ip -6 route show
  ping -c 1 10.11  # проверка IPv4
  ```

#### 2. **Настройка устройства `ab` (Mac)**

- **Скрипт `add_route.sh`**

  Для узла `ab` (например, воркер):

  - **IPv4:**  
    Пример добавления маршрута:
    ```sh
    route -n add -inet 10.12 -gateway 10.11
    ```
  
  - **IPv6:**  
    Настройка маршрутов (с учетом выбранной среды):
    ```sh
    # Маршрут по умолчанию для рабочей сети через fdaa:: (CD) или fcaa:: (CI)
    route -n add -inet6 default -gateway fdaa::
    
    # Дополнительные маршруты для VPN-узлов
    route -n add -inet6 fdba::/16 -gateway fdaa::
    route -n add -inet6 fdbb::/16 -gateway fdaa::
    # и т.д.
    ```

- **Загрузка демона:**
  ```sh
  sudo launchctl unload /Library/LaunchDaemons/com.user.delayedroute.plist
  sudo launchctl load /Library/LaunchDaemons/com.user.delayedroute.plist
  ```

- **Проверка работы:**
  ```sh
  ping6 -c 1 fdab::
  ping6 -c 1 fcab::
  ping -c 1 10.12
  ```

#### Дополнительные рекомендации

1. **Логирование:**
   ```sh
   echo "Маршруты добавлены: $(date)" >> /var/log/add_route.log
   ```
2. **Проверка доступности шлюзов:**
   ```sh
   ping6 -c 1 fdaa:: && route -n add -inet6 default -gateway fdaa::
   ping6 -c 1 fcaa:: && route -n add -inet6 fcaa::/16 -gateway fcaa::
   ```
3. **Резервное копирование конфигураций:**
   ```sh
   sudo cp /etc/network/interfaces /etc/network/interfaces.backup
   sudo cp /usr/local/bin/add_route.sh /usr/local/bin/add_route.sh.backup
   ```
4. **Автоматизация обновления таблицы соседей (NDP).**