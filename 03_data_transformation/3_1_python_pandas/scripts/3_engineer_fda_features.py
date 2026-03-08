import pandas as pd
import numpy as np
import os

def engineer_features():
    print("Loading Silver FDA data from Phase 2.1...")
    
    silver_path = "02_data_cleaning/2_1_python_pandas/data/silver/silver_fda_recalls.csv"
    
    try:
        df = pd.read_csv(silver_path)
    except FileNotFoundError:
        print(f"Error: {silver_path} not found. Please ensure Project 2.1 is complete.")
        return

    print("Engineering Operational Duration features...")
    
    df['recall_initiation_date'] = pd.to_datetime(df['recall_initiation_date'], errors='coerce')
    df['report_date'] = pd.to_datetime(df['report_date'], errors='coerce')

    # Calculate operational lag (Duration in days)
    df['recall_duration_days'] = (df['report_date'] - df['recall_initiation_date']).dt.days

    # Extract Year-Month and Quarter for smooth BI trend analysis
    df['recall_month_year'] = df['recall_initiation_date'].dt.to_period('M')
    df['recall_quarter'] = df['recall_initiation_date'].dt.to_period('Q')

    print("Mapping primary recall reasons to Business Risk Tiers...")
    
    # Define the mapping logic (Domain-specific categorizations)
    high_risk_categories = ['STERILITY ISSUES', 'CONTAMINATION', 'PATHOGEN', 'ALLERGEN']
    medium_risk_categories = ['CGMP DEVIATIONS', 'SUBPOTENT', 'SUPERPOTENT', 'IMPURITIES']
    
    # Ensure the column exists and is uppercase for accurate matching
    if 'primary_recall_reason' in df.columns:
        df['primary_recall_reason'] = df['primary_recall_reason'].astype(str).str.upper()
        
        conditions = [
            df['primary_recall_reason'].isin(high_risk_categories),
            df['primary_recall_reason'].isin(medium_risk_categories)
        ]
        
        choices = ['High Risk', 'Medium Risk']
        
        # Apply mapping, defaulting to Low Risk for labeling/administrative issues
        df['risk_tier'] = np.select(conditions, choices, default='Low Risk')
    else:
        print("Warning: 'primary_recall_reason' column not found in Silver data.")
        print("Available columns are:", df.columns.tolist())

    print("Exporting analytical matrix to project Gold folder...")
    
    gold_dir = "03_data_transformation/3_1_python_pandas/data"
    gold_path = f"{gold_dir}/gold_fda_analytical_matrix.csv"
    
    os.makedirs(gold_dir, exist_ok=True)
    df.to_csv(gold_path, index=False)
    print(f"Success! Gold data saved to: {gold_path}")

if __name__ == "__main__":
    engineer_features()