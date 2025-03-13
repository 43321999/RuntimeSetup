# [first](gpt3.5.md)
# [debian](https://www.debian.org/releases/stable/amd64/index.ru.html)

>>>
>>> При помощи каких утилит NextCloud, производит объединение дисков в одно логическое хранилище?
>>>
>>> youtu.be/afD2_H215JM?si=S8dAdn65ujWDE2Pl
>>> 

## hardware debian setup on «American Mega Trends… » bios
Graphic installation:
  - Installation language: С - no localisation
  - Location, Locale, Timezone, live country: United Kingdom
  - Keyboard layout: American English
  - hostname: aa
  - domain name: d
  - root passwd: < zte superadmin >
  - superadmin passwd: < zte superadmin >
  - use entire sda disk
  - package manager mirror (Russian Federation): deb.debian.org
  - blank proxy
  - usage statistics: no
  - predefined soft:
    - [x] Debian desktop env
    - [x] GNOME
    - [] SSH
    - [x] standard system utilities
  - GRUB boot loader: sda
```shell
sudo su
apt update
apt install openssh-server
vi /etc/ssh/sshd_config
# setup port 1025
```
```shell
apt update
mkdir /etc/systemd/sleep.conf.d
vi /etc/systemd/sleep.conf.d/nosuspend.conf
```
To prevent unexpected message: - «:The system will suspend now!»
Copy this:
```config
[Sleep]
AllowSuspend=no
AllowHibernation=no
AllowSuspendThenHibernate=no
AllowHybridSleep=no
```
and paste to: ```/etc/systemd/sleep.conf.d/nosuspend.conf```
```sh
# reboot
systemctl daemon-reload
systemctl restart systemd-logind.service
```
## grub setup
Привет! Чтобы убрать меню GRUB и сделать его невидимым при загрузке, тебе нужно настроить его так, чтобы он автоматически загружал выбранную операционную систему без запроса на выбор.

Вот как это можно сделать:

1. **Редактирование конфигурации GRUB**:
   Открой терминал и отредактируй файл конфигурации GRUB:

   ```bash
   sudo nano /etc/default/grub
   ```

2. **Настройка параметров**:
   Найди строку с параметром `GRUB_TIMEOUT` и установи его значение в 0:

   ```bash
   GRUB_TIMEOUT=0
   ```

   Это означает, что GRUB будет сразу загружать операционную систему без ожидания.

   Также проверь, что строка с параметром `GRUB_HIDDEN_TIMEOUT` выглядит так (или добавь ее, если она отсутствует):

   ```bash
   GRUB_HIDDEN_TIMEOUT=0
   ```

   Эти параметры скрывают меню и заставляют GRUB загружать ОС автоматически.

3. **Обновление GRUB**:
   После внесения изменений в конфигурацию нужно обновить GRUB, чтобы изменения вступили в силу:

   ```bash
   sudo update-grub
   ```

4. **Перезагрузка**:
   После обновления перезагрузи систему:

   ```bash
   sudo reboot
   ```

Теперь, при загрузке, GRUB не будет отображаться, и система сразу загрузится без запроса на выбор. Если у тебя несколько операционных систем, по умолчанию будет загружена та, что указана в конфигурации GRUB как основная.

Понял! Давайте разберем, как исправить имена хоста и пользователя, чтобы они соответствовали вашим ожиданиям (`aa` вместо `00` и `c` вместо `fc`).

### 2. **Добавление пользователя (с `fc` на `c`)**:

1. **Создайте нового пользователя `c`**:
   ```sh
   sudo adduser c
   ```

4. **Проверка**:
   Войдите под новым пользователем:
   ```sh
   su - c
   ```

### Итог:
1. **Имя хоста**:
   - На Debian: измените `/etc/hostname` и `/etc/hosts`.
   - На macOS: используйте `scutil`.

2. **Имя пользователя**:
   - Создайте нового пользователя, перенесите данные и удалите старого.

3. **Проверка**:
   Убедитесь, что изменения применены и система работает корректно.
