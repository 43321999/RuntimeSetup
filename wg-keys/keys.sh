#!/bin/bash

# Создание директории для ключей
mkdir -p wg-keys
cd wg-keys

echo "=== Генерация ключей для сервера ==="
# Генерация приватного ключа сервера
wg genkey | tee server_private.key | wg pubkey > server_public.key

echo "Приватный ключ сервера:"
cat server_private.key

echo "Публичный ключ сервера:"
cat server_public.key

echo -e "\n=== Генерация ключей для клиента ==="
# Генерация приватного ключа клиента
wg genkey | tee client_private.key | wg pubkey > client_public.key

echo "Приватный ключ клиента:"
cat client_private.key

echo "Публичный ключ клиента:"
cat client_public.key

echo -e "\nКлючи сохранены в директории $(pwd)"
