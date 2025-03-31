# Инструкция по настройке Ansible

## 1. Установка зависимостей

Перед началом работы убедитесь, что у вас установлены следующие инструменты:
- **Git**: Для клонирования репозитория.
- **Python 3.x**: Необходим для работы Ansible.
- **pip**: Для установки зависимостей.

### 1.1 Установка Git

Проверьте, что Git установлен:

```bash
git --version
```

Если Git не установлен, установите его через [официальный сайт Git](https://git-scm.com/).

### 1.2 Установка Python 3

Проверьте наличие Python 3:

```bash
python3 --version
```

Если Python 3 не установлен, скачайте и установите его с [официального сайта Python](https://www.python.org/downloads/).

### 1.3 Клонирование репозитория Ansible

Клонируйте репозиторий Ansible:

```bash
git clone https://github.com/ansible/ansible.git
cd ansible
```

### 1.4 Установка виртуального окружения и зависимостей

Создайте виртуальное окружение:

```bash
python3 -m venv venv
```

Активируйте виртуальное окружение:

```bash
# second & other starts here:
source venv/bin/activate
# and finish here:
# cd 
ansible all -i "aa,ab,ba," -m ping
# x
```

Установите зависимости:

```bash
pip install -r requirements.txt
```

### 1.5 Проверка установки Ansible

Проверьте, что Ansible установлен:

```bash
ansible --version
```

## 2. Настройка инвентаря

Создайте файл инвентаря `inventory.ini` в корневой папке проекта с настройками серверов:

```ini
[all]
host1 ansible_user=<username> ansible_port=<port>
host2 ansible_user=<username> ansible_port=<port>
```

Замените `<username>` и `<port>` на соответствующие значения.

## 3. Новый подход к передаче хостов

Теперь хосты передаются через переменные в playbook. Убедитесь, что в файле `playbook.yml` используется следующий формат:

```yml
- hosts: "{{ target_hosts }}"
  vars_files:
    - vars.yml
  tasks:
    - name: Пример задачи
      debug:
        msg: "Хосты переданы через переменную target_hosts"
```

При запуске playbook укажите хосты через параметр `--extra-vars`:

```bash
ansible-playbook playbook.yml --extra-vars "target_hosts=host1,host2"
```

## 4. Проверка подключения

Для проверки подключения к серверам используйте команду:

```bash
ansible all -i inventory.ini -m ping
```

Если всё настроено правильно, вы получите ответ `"pong"`.

## 5. Применение playbook

Запустите playbook с помощью команды:

```bash
ansible-playbook -i inventory.ini playbook.yml --ask-vault-pass
```

## Примечания

- Убедитесь, что SSH-доступ на серверы настроен, и вы можете подключаться через ключ или пароль.
- В случае ошибок проверьте логи и настройки сервера.

### Удаление

# 1. Удаление репозитория Ansible
Удалите клонированный репозиторий:

```bash
rm -rf /путь/к/ansible
```

### 2. Удаление виртуального окружения
Деактивируйте виртуальное окружение и удалите его:

```bash
deactivate
rm -rf venv
```

### 3. Удаление файла инвентаря
Удалите файл инвентаря:

```bash
rm inventory.ini
```