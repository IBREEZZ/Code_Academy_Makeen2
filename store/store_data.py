# -*- coding: utf-8 -*-
"""
Created on Tue May 27 10:46:48 2025

@author: eboal
"""

import pandas as pd
import pymysql
import schedule
import time

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
        df['Total_Price'] = df['Qty'] * df['Unit_Price']
        df['Total_Price_OMR'] = df['Total_Price'] * 0.385
        df['StoreID'] = store_id
        return df

    transformed_dfs = [transform_data(df, i) for i, df in enumerate(dataframes, start=1)]
    all_data = pd.concat(transformed_dfs, ignore_index=True)

    print(all_data.head())

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

        # Insert distinct Products
        products = all_data[['ProductName']].drop_duplicates()
        for product in products['ProductName']:
            try:
                cursor.execute(
                    "INSERT INTO Product (ProductName) VALUES (%s)",
                    (product,)
                )
            except pymysql.err.IntegrityError:
                pass

        # Insert distinct Customers (only by CustomerID)
        customers = all_data[['CustomerID']].drop_duplicates()
        for _, row in customers.iterrows():
            try:
                cursor.execute(
                    "INSERT INTO Customer (CustomerID) VALUES (%s)",
                    (row['CustomerID'],)
                )
            except pymysql.err.IntegrityError:
                pass

        # Insert distinct Stores
        stores = all_data[['StoreID']].drop_duplicates()
        for _, row in stores.iterrows():
            try:
                cursor.execute(
                    "INSERT INTO Store (StoreID) VALUES (%s)",
                    (row['StoreID'],)
                )
            except pymysql.err.IntegrityError:
                pass

        # Get ProductID map
        cursor.execute("SELECT ProductID, ProductName FROM Product")
        product_map = {row['ProductName']: row['ProductID'] for row in cursor.fetchall()}

        # Insert Sales
        insert_sales_query = """
            INSERT INTO Sale 
            (ProductID, CustomerID, StoreID, Qty, Unit_Price, SaleDate, CurrencyType, Total_Price, Total_Price_OMR)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        """

        for _, row in all_data.iterrows():
            product_id = product_map.get(row['ProductName'])
            if product_id is None:
                continue
            try:
                cursor.execute(insert_sales_query, (
                    product_id,
                    row['CustomerID'],
                    row['StoreID'],
                    int(row['Qty']),
                    float(row['Unit_Price']),
                    row['SaleDate'].strftime('%Y-%m-%d %H:%M:%S'),
                    row.get('CurrencyType', None),
                    float(row.get('Total_Price', 0)),
                    float(row.get('Total_Price_OMR', 0))
                ))
            except Exception as e:
                print(f"Sale insert error for row {row}: {e}")

        connection.commit()
        print("Data loading successful!")

    except pymysql.MySQLError as e:
        print(f"Error during loading: {e}")

    finally:
        if connection:
            cursor.close()
            connection.close()
            print("MySQL connection closed.")

    print("ETL job completed")


# Schedule ETL to run every 1 minute
schedule.every(1).minutes.do(etl_job)

print("Scheduler started. Waiting for scheduled jobs...")

etl_job()

# Run scheduler loop
while True:
    schedule.run_pending()
    print("Waiting...")
    time.sleep(60)  # Wait for 1 minute
