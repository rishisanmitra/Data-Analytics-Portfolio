import os
import requests
import zipfile
import io

# 1. Define the AWS S3 URLs for the Jersey City data 
# Dec 2020 & Jan 2021 = Old Schema. Feb 2021 = New Schema.
urls = [
    "https://s3.amazonaws.com/tripdata/JC-202012-citibike-tripdata.csv.zip",
    "https://s3.amazonaws.com/tripdata/JC-202101-citibike-tripdata.csv.zip",
    "https://s3.amazonaws.com/tripdata/JC-202102-citibike-tripdata.csv.zip"
]

# 2. Setup dynamic pathing to your data/raw folder
script_dir = os.path.dirname(os.path.abspath(__file__))
raw_data_dir = os.path.abspath(os.path.join(script_dir, '../data/raw'))

print("Starting automated data pipeline from AWS S3...")

# 3. Loop through URLs, download, and extract directly to the raw folder
for url in urls:
    filename = url.split('/')[-1]
    print(f"Fetching {filename}...")
    
    try:
        # Download the ZIP file into memory
        response = requests.get(url)
        response.raise_for_status() 
        
        # Read the ZIP file and extract its contents
        with zipfile.ZipFile(io.BytesIO(response.content)) as z:
            z.extractall(raw_data_dir)
            print(f" -> Successfully extracted CSV to data/raw/")
            
    except Exception as e:
        print(f" -> Error downloading {filename}: {e}")

print("\nData Acquisition Complete! You now have 3 messy CSV files ready for Stage 2.")