# scripts/02_load_csv_data.sh
#!/bin/bash

CONTAINER_NAME=bigdatasnowflake-db-1
DB_USER=user_bd
DB_NAME=mydatabase
TABLE_NAME=public.mock_data
CSV_DIR="/data_csv_for_docker"

for file in "$CSV_DIR"/*.csv; do
  BASENAME=$(basename "$file")
  echo "Импортирую: $BASENAME"

  echo "Очищаю таблицу перед загрузкой $BASENAME..."
  psql -U "$DB_USER" -d "$DB_NAME" -c "TRUNCATE TABLE $TABLE_NAME RESTART IDENTITY;"

  psql -U "$DB_USER" -d "$DB_NAME" -c "\
    COPY $TABLE_NAME FROM '$file' DELIMITER ',' CSV HEADER;"

done