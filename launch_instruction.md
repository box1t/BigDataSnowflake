# Инструкция по запуску

```sh

git clone "репозиторий"
cd BigDataSnowflake
chmod +x scripts/02_load_csv_data.sh
chmod +x scripts/run_all.sh



docker compose down -v
docker compose up --build -d
docker compose logs -f db 

```

- Скрипт успешно записывает 10 тыс. строк в базу данных, и это подтверждается гифкой.

![alt text](<src/Peek 2025-06-01 14-19.gif>)