#!/bin/bash

echo "Ожидание готовности PostgreSQL..."
until pg_isready -h localhost -p 5432 -U ${POSTGRES_USER:-user_bd} -d ${POSTGRES_DB:-mydatabase}; do
  echo "PostgreSQL пока недоступен - ждем..."
  sleep 2 
done
echo "PostgreSQL готов!"

echo "Запускаем 02_load_data.py..."
/opt/venv/bin/python3 /usr/local/bin/02_load_data.py
    
if [ $? -eq 0 ]; then
    echo "02_load_data.py успешно завершен."
else
    echo "Ошибка: 02_load_data.py завершился с ошибкой. Выходим с кодом ошибки 1."
    exit 1
fi