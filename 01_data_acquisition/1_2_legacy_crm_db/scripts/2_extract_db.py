import pandas as pd
import pyodbc
import os
from dotenv import load_dotenv, find_dotenv

# 1. Automatically find the .env file in your portfolio folder
load_dotenv(find_dotenv())

SERVER_NAME = os.getenv('SQL_SERVER_NAME')
DATABASE_NAME = os.getenv('SQL_DATABASE_NAME')
DB_USER = os.getenv('SQL_USER')
DB_PASS = os.getenv('SQL_PASSWORD')

# 2. Connect to SQL Server
print("Connecting to SQL Server...")
conn_str = f'DRIVER={{SQL Server}};SERVER={SERVER_NAME};DATABASE={DATABASE_NAME};UID={DB_USER};PWD={DB_PASS};'
conn = pyodbc.connect(conn_str)
print("Connection successful!")

# 3. The Query
query = """
    SELECT 
        o.OrderID, o.OrderDate, o.OrderTotal,
        c.ClientID, c.ClientName, c.State, c.Phone
    FROM Orders o
    LEFT JOIN Clients c ON o.ClientID = c.ClientID
"""

# 4. Extract and Save
# Pointing to the specific raw data folder for Project 1.2
output_dir = '01_data_acquisition/1_2_legacy_crm_db/data/raw'
os.makedirs(output_dir, exist_ok=True)
output_file = f'{output_dir}/legacy_extract.csv'

print("Extracting 80,000 rows in chunks...")
first_chunk = True

# Using chunksize of 5000 to process the 80k rows efficiently
for chunk in pd.read_sql(query, conn, chunksize=5000):
    mode = 'w' if first_chunk else 'a'
    header = first_chunk
    
    chunk.to_csv(output_file, mode=mode, header=header, index=False)
    print(f" -> Saved chunk of {len(chunk)} rows.")
    
    first_chunk = False

print(f"Done! Data saved to {output_file}")
conn.close()