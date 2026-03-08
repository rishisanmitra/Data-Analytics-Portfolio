import pandas as pd
import ast
import os
import re

# --- 1. SETUP PATHS ---
script_dir  = os.path.dirname(os.path.abspath(__file__))
input_path  = os.path.join(script_dir, '../data/raw/combined_raw_fda.csv')
output_main = os.path.join(script_dir, '../data/silver/silver_fda_recalls.csv')
output_fda  = os.path.join(script_dir, '../data/silver/silver_openfda.csv')

print("--- Phase 2: Simplified Silver Layer Normalization ---")

# --- 2. INGEST & DROP HEAVY TEXT ---
df = pd.read_csv(input_path, dtype=str)

# Drop problem-causing, heavy free-text columns immediately
cols_to_drop = ['product_description', 'code_info', 'distribution_pattern', 'address_1', 'address_2', 'more_code_info', 'product_type']
df = df.drop(columns=[c for c in cols_to_drop if c in df.columns])

# --- 3. THE 'OPENFDA' FLAG & SAFE PARSING ---
# Create a simple True/False flag for the main table
df['has_openfda'] = (df['openfda'].notna()) & (df['openfda'] != '{}')

# Isolate only the rows that actually have openfda data
df_openfda_raw = df[df['has_openfda'] == True].copy()

# Safely evaluate the stringified Python dictionary
def safe_parse_dict(val):
    try:
        return ast.literal_eval(val)
    except:
        return {}

# Apply the safe parser
parsed_series = df_openfda_raw['openfda'].apply(safe_parse_dict)

# Build the OpenFDA table (Linked by recall_number)
# The FDA API returns values as lists (e.g., ['Sandoz Inc']), so we grab the first item [0]
df_openfda = pd.DataFrame({
    'recall_number': df_openfda_raw['recall_number'],
    'brand_name': parsed_series.apply(lambda d: d.get('brand_name', ['UNKNOWN'])[0]).str.upper(),
    'generic_name': parsed_series.apply(lambda d: d.get('generic_name', ['UNKNOWN'])[0]).str.upper(),
    'manufacturer_name': parsed_series.apply(lambda d: d.get('manufacturer_name', ['UNKNOWN'])[0]).str.upper()
})

# Drop the raw openfda blob from the main dataframe now that we are done with it
df = df.drop(columns=['openfda'])

# --- 4. STANDARDIZE DATES ---
date_cols = ['recall_initiation_date', 'center_classification_date', 'report_date', 'termination_date']
for col in date_cols:
    df[col] = pd.to_datetime(df[col], format='%Y%m%d', errors='coerce')

# --- 5. STANDARDIZE CATEGORICALS ---
cat_cols = ['status', 'classification', 'recalling_firm', 'city', 'state', 'country']
for col in cat_cols:
    df[col] = df[col].fillna('UNKNOWN').str.strip().str.upper()

# --- 6. SIMPLE QUANTITY & REASON ---
# Quantity: remove commas, extract first continuous sequence of numbers
df['product_quantity_numeric'] = df['product_quantity'].str.replace(',', '', regex=False).str.extract(r'(\d+)')[0]
df['product_quantity_numeric'] = pd.to_numeric(df['product_quantity_numeric'], errors='coerce').fillna(0)

# Reason: Simple keyword mapping
df['reason_for_recall'] = df['reason_for_recall'].fillna('UNKNOWN')
reason_upper = df['reason_for_recall'].str.upper()

df['primary_recall_reason'] = 'OTHER / SPECIFIC'
df.loc[reason_upper.str.contains('STERILITY'), 'primary_recall_reason'] = 'STERILITY ISSUES'
df.loc[reason_upper.str.contains('CGMP|GOOD MANUFACTURING'), 'primary_recall_reason'] = 'CGMP DEVIATIONS'
df.loc[reason_upper.str.contains('IMPURIT|DEGRADATION'), 'primary_recall_reason'] = 'IMPURITIES / DEGRADATION'
df.loc[reason_upper.str.contains('LABEL'), 'primary_recall_reason'] = 'LABELING ISSUES'

# Drop raw quantity and raw reason now that we have clean, standardized versions
df = df.drop(columns=['product_quantity', 'reason_for_recall'])

# --- 7. DEDUPLICATE AND SAVE ---
df = df.drop_duplicates(subset=['recall_number'])
df_openfda = df_openfda.drop_duplicates(subset=['recall_number'])

os.makedirs(os.path.dirname(output_main), exist_ok=True)
df.to_csv(output_main, index=False)
df_openfda.to_csv(output_fda, index=False)

print(f"Success! Main Table saved: {output_main} ({len(df)} rows)")
print(f"Success! OpenFDA Table saved: {output_fda} ({len(df_openfda)} rows)")