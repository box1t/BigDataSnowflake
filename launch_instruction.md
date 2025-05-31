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

- Скрипт полностью рабочий, и это подтверждается гифкой.

![alt text](<src/Peek 2025-06-01 00-57.gif>)