# -*- coding: utf-8 -*-
"""
Created on Tue May 27 13:37:16 2025

@author: eboal
"""

import streamlit as st
import pymysql
import pandas as pd

# Database connection
conn = pymysql.connect(
    host='localhost',
    user='root',
    password='root',
    database='store'
)

st.set_page_config(page_title="Store Sales Dashboard", layout="wide")
st.title("📊 Store Sales Dashboard")

# Load data
df = pd.read_sql("SELECT * FROM SalesFact", conn)
products = pd.read_sql("SELECT * FROM dim_product", conn)
stores = pd.read_sql("SELECT * FROM dim_store", conn)
dates = pd.read_sql("SELECT * FROM dim_date", conn)

# Merge for visuals
df = df.merge(products, on="ProductID").merge(stores, on="StoreID").merge(dates, left_on="DateKey", right_on="DateKey")

# KPIs
col1, col2, col3 = st.columns(3)
col1.metric("Total Sales (OMR)", f"{df['Total_Price_OMR'].sum():,.2f}")
col2.metric("Total Quantity Sold", int(df['Qty'].sum()))
col3.metric("Total Transactions", len(df))

# Sales by Product
st.subheader("💡 Sales by Product")
product_sales = df.groupby("ProductName")["Total_Price_OMR"].sum().sort_values(ascending=False)
st.bar_chart(product_sales)

# Monthly Sales Trend
st.subheader("📈 Monthly Sales Trend")
df["Month"] = pd.to_datetime(df[['Year', 'Month']].assign(DAY=1))
monthly_sales = df.groupby("Month")["Total_Price_OMR"].sum()
st.line_chart(monthly_sales)

# Sales by Store
st.subheader("🏪 Sales by Store")
store_sales = df.groupby("StoreID")["Total_Price_OMR"].sum()
st.bar_chart(store_sales)
