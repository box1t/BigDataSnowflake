# scripts/run_all.sh
#!/bin/bash
set -e

echo "Ждём запуска Postgres..."
until pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB"; do
  sleep 1
done

echo "Postgres готов!"

echo "Шаг 1: Создание таблиц..."
psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /docker-entrypoint-initdb.d/01_create_tables.sql

echo "Шаг 2: Загрузка CSV в mock_data..."
bash /docker-entrypoint-initdb.d/02_load_csv_data.sh

echo "Шаг 3: Наполнение аналитических таблиц..."
psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /docker-entrypoint-initdb.d/03_fill_tables_w_mock.sql

echo "Шаг 4: Анализ содержимого..."
psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /docker-entrypoint-initdb.d/04_tables_analysis.sql

echo "Все шаги успешно выполнены!"