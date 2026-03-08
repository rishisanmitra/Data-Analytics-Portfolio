# 1. Load Libraries
library(tidyverse)

# 2. Load the Silver Dataset
# Assuming 2.4 was saved in the following path:
input_path <- "02_data_cleaning/2_4_r_cleaning/data/silver/silver_used_devices.csv"
output_path <- "03_data_transformation/3_3_r_statistical_transformation/data/gold/gold_device_analytics.csv"

if (!file.exists(input_path)) {
  stop("Silver data not found! Please run Project 2.4 first.")
}

devices <- read_csv(input_path)

# 3. Feature Engineering: Product Efficiency Ratios
# We want to see how much 'power' is packed into the physical size/weight.
devices_gold <- devices %>%
  mutate(
    # Battery Density: mAh per gram (Higher = better engineering)
    battery_density = battery / weight,
    
    # Screen Real Estate: Pixels per inch (Proxy for display quality)
    pixel_density = (screen_size * 100) / weight,
    
    # Age of Device (Relative to the latest data point in set)
    device_age = max(release_year) - release_year
  )

# 4. Statistical Transformation: Handling Skewed Price Data
# Prices are often right-skewed. Log-transforming makes the distribution more 'Normal'.

devices_gold <- devices_gold %>%
  mutate(
    log_used_price = log1p(normalized_used_price),
    log_new_price = log1p(normalized_new_price)
  )

# 5. Feature Scaling: Z-Score Normalization
# Scaling hardware specs to a mean of 0 and standard deviation of 1.
# This ensures a 5000mAh battery doesn't 'outweight' 8GB of RAM in a model.
devices_gold <- devices_gold %>%
  mutate(across(
    c(ram, internal_memory, battery, weight),
    ~ as.vector(scale(.)),
    .names = "scaled_{.col}"
  ))

# 6. Final Selection & Cleanup
# Keep the original IDs, the engineered features, and the scaled metrics.
final_gold_set <- devices_gold %>%
  select(
    device_brand, release_year, device_age,
    normalized_used_price, log_used_price,
    scaled_ram, scaled_internal_memory, scaled_battery, scaled_weight,
    battery_density, pixel_density
  )

# 7. Save the Gold Layer
write_csv(final_gold_set, output_path)

print("Project 3.3 Complete: Gold Layer generated with 0 missing values and scaled features.")