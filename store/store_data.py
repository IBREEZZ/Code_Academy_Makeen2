# -*- coding: utf-8 -*-
"""
Created on Tue May 27 10:46:48 2025

@author: eboal
"""

import pandas as pd
import pymysql
import schedule
import time
import math

def etl_job():
    print("Starting ETL job...")

    # Step 1: Extract
    file_paths = [
        "C:/Users/eboal/Desktop/Makeen2/store/store_sales_1.csv",
        "C:/Users/eboal/Desktop/Makeen2/store/store_sales_2.csv",
        "C:/Users/eboal/Desktop/Makeen2/store/store_sales_3.csv"
    ]
    dataframes = [pd.read_csv(path) for path in file_paths]

    # Step 2: Transform
    def transform_data(df, store_id):
        df = df.dropna(subset=['Qty', 'Unit_Price', 'CustomerID']).copy()
        df['Qty'] = df['Qty'].astype(int)
        df['Unit_Price'] = df['Unit_Price'].astype(float)
        df['SaleDate'] = pd.to_datetime(df['SaleDate'])

        # Clean CurrencyType
        if 'CurrencyType' in df.columns:
            df['CurrencyType'] = df['CurrencyType'].astype(str).str.strip().str.upper()
            df.loc[df['CurrencyType'].isin(['NAN', 'NONE', '', 'NA', 'N/A']), 'CurrencyType'] = None
        else:
            df['CurrencyType'] = None

        # Total price
        df['Total_Price'] = df['Qty'] * df['Unit_Price']

        # Convert to OMR
        def convert_to_omr(row):
            if row['CurrencyType'] == 'OMR' or row['CurrencyType'] is None:
                return row['Total_Price']
            else:
                return row['Total_Price'] * 0.385

        df['Total_Price_OMR'] = df.apply(convert_to_omr, axis=1)
        df['StoreID'] = store_id

        return df

    # Transform all files
    transformed_dfs = [transform_data(df, i + 1) for i, df in enumerate(dataframes)]
    all_data = pd.concat(transformed_dfs, ignore_index=True)

    print("Sample data after transform:")
    print(all_data[['ProductName', 'Qty', 'Unit_Price', 'CurrencyType', 'Total_Price', 'Total_Price_OMR']].head(10))

    # Step 3: Load to SQL
    try:
        connection = pymysql.connect(
            host='localhost',
            user='root',
            password='root',
            database='store',
            cursorclass=pymysql.cursors.DictCursor
        )
        cursor = connection.cursor()

        # === ✅ DELETE old Sale records BEFORE insert (for clean re-run) ===
        print("Deleting old records from Sale table...")
        cursor.execute("DELETE FROM Sale")
        connection.commit()

        # Insert products
        products = all_data[['ProductName']].drop_duplicates()
        for product in products['ProductName']:
            try:
                cursor.execute("INSERT INTO Product (ProductName) VALUES (%s)", (product,))
            except pymysql.err.IntegrityError:
                pass  # Skip duplicates

        # Insert customers
        customers = all_data[['CustomerID']].drop_duplicates()
        for _, row in customers.iterrows():
            try:
                cursor.execute("INSERT INTO Customer (CustomerID) VALUES (%s)", (row['CustomerID'],))
            except pymysql.err.IntegrityError:
                pass

        # Insert stores
        stores = all_data[['StoreID']].drop_duplicates()
        for _, row in stores.iterrows():
            try:
                cursor.execute("INSERT INTO Store (StoreID) VALUES (%s)", (row['StoreID'],))
            except pymysql.err.IntegrityError:
                pass

        # Map ProductName → ProductID
        cursor.execute("SELECT ProductID, ProductName FROM Product")
        product_map = {row['ProductName']: row['ProductID'] for row in cursor.fetchall()}

        def safe_value(value):
            if value is None or (isinstance(value, float) and math.isnan(value)):
                return None
            return value

        # Insert sales
        insert_sales_query = """
            INSERT INTO Sale 
            (ProductID, CustomerID, StoreID, Qty, Unit_Price, SaleDate, CurrencyType, Total_Price, Total_Price_OMR)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        """

        for _, row in all_data.iterrows():
            product_id = product_map.get(row['ProductName'])
            if product_id is None:
                continue  # Skip if product not found
            try:
                cursor.execute(insert_sales_query, (
                    product_id,
                    row['CustomerID'],
                    row['StoreID'],
                    int(row['Qty']),
                    float(row['Unit_Price']),
                    row['SaleDate'].strftime('%Y-%m-%d %H:%M:%S'),
                    safe_value(row.get('CurrencyType')),
                    float(row.get('Total_Price', 0)),
                    float(row.get('Total_Price_OMR', 0))
                ))
            except Exception as e:
                print(f"Sale insert error for row {row}: {e}")

        connection.commit()
        print("✅ Data loading completed successfully!")

    except pymysql.MySQLError as e:
        print(f"❌ MySQL error during load: {e}")

    finally:
        if connection:
            cursor.close()
            connection.close()
            print("MySQL connection closed.")

    print("ETL job finished.\n")

# Schedule ETL every 1 minute
schedule.every(1).minutes.do(etl_job)

print("Scheduler started. Waiting for scheduled jobs...\n")

# Run first job immediately
etl_job()

# Loop forever
while True:
    schedule.run_pending()
    print("Waiting for next run...\n")
    time.sleep(60)
