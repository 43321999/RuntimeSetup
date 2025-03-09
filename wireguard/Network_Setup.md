### aa
#### Настройка сетевого интерфейса
```cat /etc/network/interfaces```
```sh
# ... existing code ...

auto ens128
iface ens128 inet dhcp

# ... ci ...
iface ens128 inet6 static
    address fcaa::
    netmask 8

# ... cd ...
iface ens128 inet6 static
    address fdaa::
    netmask 8
```

#### Применение изменений
```sh
sudo ifdown ens128 && sudo ifup ens128
# или
sudo systemctl restart networking
```