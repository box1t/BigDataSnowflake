import pandas as pd
import psycopg2
from psycopg2 import sql
import os
import sys
import glob
import time
from io import StringIO

def clean_dataframe(df):
    original_columns = df.columns.tolist()
    new_columns = []
    for col in original_columns:
        clean_col = col.lower().replace(' ', '_')
        clean_col = clean_col.replace('#', '').replace('id', '').strip('_')
        new_columns.append(clean_col)
    
    df.columns = new_columns

    for col in df.select_dtypes(include='object').columns:
        df[col] = df[col].astype(str).replace({'nan': ''})

    if 'product_release_date' in df.columns:
        df['product_release_date'] = pd.to_datetime(df['product_release_date'], errors='coerce').dt.strftime('%Y-%m-%d')
    if 'product_expiry_date' in df.columns:
        df['product_expiry_date'] = pd.to_datetime(df['product_expiry_date'], errors='coerce').dt.strftime('%Y-%m-%d')
    if 'sale_date' in df.columns:
        df['sale_date'] = pd.to_datetime(df['sale_date'], errors='coerce').dt.strftime('%Y-%m-%d')
    
    if 'id' in df.columns:
        df = df.drop(columns=['id'])

    return df

def connect_to_db(retries=10, delay=5):
    conn = None
    for i in range(retries):
        try:
            conn = psycopg2.connect(
                host="db",
                database=os.getenv("POSTGRES_DB", "mydatabase"),
                user=os.getenv("POSTGRES_USER", "user_bd"),
                password=os.getenv("POSTGRES_PASSWORD", "password_bd"),
                port="5432"
            )
            print("PostgreSQL connection successful.")
            return conn
        except psycopg2.OperationalError as e:
            sys.stderr.write(f"PostgreSQL connection failed (attempt {i+1}/{retries}): {e}\n")
            time.sleep(delay)
    sys.stderr.write("Failed to connect to PostgreSQL after multiple retries.\n")
    sys.exit(1)

def load_data_to_postgres(conn, file_path, table_name="public.mock_data"):
    print(f"Reading and cleaning {file_path}...")
    try:
        df = pd.read_csv(file_path)
    except pd.errors.ParserError:
        try:
            df = pd.read_csv(file_path, sep=',', quotechar='"', doublequote=True, on_bad_lines='warn', engine='python')
        except Exception as e:
            sys.stderr.write(f"Error reading CSV {file_path} even with lenient parsing: {e}\n")
            return
    except FileNotFoundError:
        sys.stderr.write(f"Error: File not found {file_path}\n")
        return

    df_cleaned = clean_dataframe(df)

    csv_buffer = StringIO()
    df_cleaned.to_csv(csv_buffer, index=False, header=False, sep=',') 
    csv_buffer.seek(0)

    columns_for_copy = [
        "customer_first_name", "customer_last_name", "customer_age", "customer_email",
        "customer_country", "customer_postal_code", "customer_pet_type", "customer_pet_name",
        "customer_pet_breed", "seller_first_name", "seller_last_name", "seller_email",
        "seller_country", "seller_postal_code", "product_name", "product_category",
        "product_price", "product_quantity", "sale_date", "sale_customer_id",
        "sale_seller_id", "sale_product_id", "sale_quantity", "sale_total_price",
        "store_name", "store_location", "store_city", "store_state", "store_country",
        "store_phone", "store_email", "pet_category", "product_weight", "product_color",
        "product_size", "product_brand", "product_material", "product_description",
        "product_rating", "product_reviews", "product_release_date", "product_expiry_date",
        "supplier_name", "supplier_contact", "supplier_email", "supplier_phone",
        "supplier_address", "supplier_city", "supplier_country"
    ]
    
    if len(df_cleaned.columns) != len(columns_for_copy):
        sys.stderr.write(f"Column mismatch: DataFrame has {len(df_cleaned.columns)} columns, but COPY expects {len(columns_for_copy)}.\n")
        sys.stderr.write(f"DataFrame columns: {df_cleaned.columns.tolist()}\n")
        sys.stderr.write(f"Expected COPY columns: {columns_for_copy}\n")
        sys.exit(1)

    copy_cmd = sql.SQL("COPY {} ({}) FROM STDIN WITH (FORMAT CSV, DELIMITER {}, HEADER FALSE)").format(
        sql.Identifier(table_name),
        sql.SQL(', ').join(map(sql.Identifier, columns_for_copy)),
        sql.Literal(',')
    )

    with conn.cursor() as cur:
        try:
            print(f"Copying data from {file_path} to {table_name} with {len(df_cleaned)} rows...")
            cur.copy_expert(copy_cmd, csv_buffer)
            conn.commit()
            print(f"Successfully loaded {file_path}.")
        except psycopg2.Error as e:
            conn.rollback()
            sys.stderr.write(f"Error loading {file_path}: {e}\n")


if __name__ == "__main__":
    CSV_DIR = os.getenv("CSV_DATA_PATH", "/data_csv")
    TABLE_NAME = "public.mock_data"

    conn = connect_to_db()

    try:
        with conn.cursor() as cur:
            print(f"Truncating table {TABLE_NAME}...")
            cur.execute(sql.SQL("TRUNCATE TABLE {} RESTART IDENTITY CASCADE;").format(sql.Identifier(TABLE_NAME)))
            conn.commit()
            print(f"Table {TABLE_NAME} truncated.")

        csv_pattern_wildcard = os.path.join(CSV_DIR, "MOCK_DATA (*).csv")
        csv_files = sorted(glob.glob(csv_pattern_wildcard))
        
        single_mock_data_csv_path = os.path.join(CSV_DIR, "MOCK_DATA.csv")
        if os.path.exists(single_mock_data_csv_path) and single_mock_data_csv_path not in csv_files:
            csv_files.append(single_mock_data_csv_path)

        if not csv_files:
            print(f"Warning: No 'MOCK_DATA (*).csv' or 'MOCK_DATA.csv' files found in {CSV_DIR}.")
            print(f"Please ensure CSV files are present in the '{CSV_DIR}' directory inside the container.")
            print(f"Current content of {CSV_DIR}: {os.listdir(CSV_DIR) if os.path.exists(CSV_DIR) else 'Directory not found'}")
        else:
            print(f"Found {len(csv_files)} CSV files: {csv_files}. Starting data load...")
            for file_path in csv_files:
                load_data_to_postgres(conn, file_path, TABLE_NAME)
            print("All found mock_data CSV files loaded.")

        print("Data loading for mock_data completed. Other SQL scripts will run automatically if present in initdb.d.")

    finally:
        if conn:
            conn.close()
            print("PostgreSQL connection closed.")