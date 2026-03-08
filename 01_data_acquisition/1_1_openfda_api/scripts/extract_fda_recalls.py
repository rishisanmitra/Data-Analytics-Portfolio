import requests
import json
import time

# 1. API Configuration
base_url = "https://api.fda.gov/drug/enforcement.json"
search_query = "report_date:[20230101+TO+20251231]"
limit = 100 
skip = 0    
max_pages = 5 

print("Starting openFDA API extraction...")

# 2. Loop through the pages
for page in range(1, max_pages + 1):
    
    # Construct the exact URL for the current page
    url = f"{base_url}?search={search_query}&limit={limit}&skip={skip}"
    print(f"Fetching page {page}...")
    
    try:
        # 3. Request the data from the API
        response = requests.get(url)
        response.raise_for_status() # Throws an error if the URL fails
        
        # Convert the response into a Python dictionary
        data = response.json()
        
        # 4. Save the data to our raw folder
        # This path assumes your terminal is in the 'data-analytics-portfolio' root folder
        file_path = f"01_data_acquisition/1_1_openfda_api/data/raw/fda_recalls_page_{page}.json"
        
        with open(file_path, "w", encoding="utf-8") as file:
            json.dump(data, file, indent=4)
            
        print(f"   -> Success! Saved {file_path}")
        
        # 5. Update the 'skip' variable for the next loop (Pagination)
        skip = skip + limit
        
        # Pause for 1.5 seconds to respect the FDA's servers and avoid getting blocked
        time.sleep(1.5) 
        
    except Exception as e:
        print(f"   -> An error occurred on page {page}: {e}")
        break # Stop the loop if something goes wrong

print("Extraction complete! Check your data/raw folder.")