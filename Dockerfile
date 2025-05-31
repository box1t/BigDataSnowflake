FROM debezium/postgres:15-alpine

RUN apk add --no-cache python3 py3-pip build-base

RUN python3 -m venv /opt/venv \
    && /opt/venv/bin/pip install pandas psycopg2-binary

ENV PATH="/opt/venv/bin:$PATH"

COPY ./scripts/02_load_data.py /usr/local/bin/02_load_data.py 

COPY ./scripts/02_run_load_data.sh /docker-entrypoint-initdb.d/02_run_load_data.sh
RUN chmod +x /docker-entrypoint-initdb.d/02_run_load_data.sh

COPY ./data_csv_for_docker /data_csv/