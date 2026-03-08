import pandas as pd
import json
import os

# 1. Setup paths
script_dir = os.path.dirname(os.path.abspath(__file__))
raw_dir = os.path.abspath(os.path.join(script_dir, '../data/raw'))

print("--- Phase 1: Explicit Ingestion & Profiling ---")

# 2. Hardcode the expected files
expected_files = [
    'fda_recalls_page_1.json',
    'fda_recalls_page_2.json',
    'fda_recalls_page_3.json',
    'fda_recalls_page_4.json',
    'fda_recalls_page_5.json'
]

all_results = []
files_processed = 0

# 3. Load and append the data 
for filename in expected_files:
    filepath = os.path.join(raw_dir, filename)
    
    if not os.path.exists(filepath):
        print(f"WARNING: Expected file {filename} is missing! Skipping...")
        continue
        
    with open(filepath, 'r', encoding='utf-8') as f:
        data = json.load(f)
        if 'results' in data:
            all_results.extend(data['results'])
            files_processed += 1

# 4. Flatten JSON to DataFrame and save raw combined CSV
df = pd.DataFrame(all_results)
combined_raw_path = os.path.join(raw_dir, 'combined_raw_fda.csv')
df.to_csv(combined_raw_path, index=False)

print(f"Successfully processed {files_processed}/{len(expected_files)} files.")
print(f"Combined {len(df)} rows and saved to: {combined_raw_path}")

# 5. EXPLORATORY DATA ANALYSIS (INSPECTION)
print("\n--- DATA INSPECTION RESULTS ---")

print("\n1. DataFrame Info (Column Names and Data Types):")
df.info()

print("\n2. Sample of Date Columns (Checking formatting):")
date_cols = [col for col in ['recall_initiation_date', 'report_date'] if col in df.columns]
if date_cols:
    print(df[date_cols].head(5))

print("\n3. Sample of Quantity Column (Checking for text/inconsistencies):")
if 'product_quantity' in df.columns:
    print(df['product_quantity'].dropna().head(10))

print("\n4. Sample of Categorical Columns (Checking for casing/whitespace):")
cat_cols = [col for col in ['recalling_firm', 'status', 'city'] if col in df.columns]
if cat_cols:
    print(df[cat_cols].head(5))

print("\n--- EDA COMPLETE ---")