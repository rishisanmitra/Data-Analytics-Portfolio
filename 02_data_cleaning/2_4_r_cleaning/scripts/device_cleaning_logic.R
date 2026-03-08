# 1. Load necessary libraries
library(dplyr)
library(ggplot2)

# 2. Load the dataset
device.df <- read.csv("C:/Users/RINA/Desktop/data-analytics-portfolio/02_data_cleaning/2_4_r_cleaning/data/raw/used_device_data.csv")

# 3. Categorical Standardization
device.df$device_brand <- as.factor(device.df$device_brand)
device.df$os <- as.factor(device.df$os)
device.df$X4g <- as.factor(device.df$X4g)
device.df$X5g <- as.factor(device.df$X5g)

# 4. INITIAL IMPUTATION (Two-Stage Fallback)
# Pass 1: Impute with median grouped by Brand
device.df <- device.df %>%
  group_by(device_brand) %>%
  mutate(
    rear_camera_mp = ifelse(is.na(rear_camera_mp), median(rear_camera_mp, na.rm = TRUE), rear_camera_mp),
    front_camera_mp = ifelse(is.na(front_camera_mp), median(front_camera_mp, na.rm = TRUE), front_camera_mp),
    internal_memory = ifelse(is.na(internal_memory), median(internal_memory, na.rm = TRUE), internal_memory),
    ram = ifelse(is.na(ram), median(ram, na.rm = TRUE), ram),
    battery = ifelse(is.na(battery), median(battery, na.rm = TRUE), battery),
    weight = ifelse(is.na(weight), median(weight, na.rm = TRUE), weight)
  ) %>%
  ungroup() %>%
  # Pass 2: Fallback to median grouped by OS and Release Year for any remaining NAs
  group_by(os, release_year) %>%
  mutate(
    rear_camera_mp = ifelse(is.na(rear_camera_mp), median(rear_camera_mp, na.rm = TRUE), rear_camera_mp),
    front_camera_mp = ifelse(is.na(front_camera_mp), median(front_camera_mp, na.rm = TRUE), front_camera_mp),
    internal_memory = ifelse(is.na(internal_memory), median(internal_memory, na.rm = TRUE), internal_memory),
    ram = ifelse(is.na(ram), median(ram, na.rm = TRUE), ram),
    battery = ifelse(is.na(battery), median(battery, na.rm = TRUE), battery),
    weight = ifelse(is.na(weight), median(weight, na.rm = TRUE), weight)
  ) %>%
  ungroup()

# 5. LOGICAL OUTLIER HANDLING (Identifying and Nullifying Impossible Specs)

# A. Rear Camera: Flag impossible low values for modern devices
device.df$rear_camera_mp[device.df$rear_camera_mp < 0.1 | 
                           (device.df$rear_camera_mp < 3 & (device.df$internal_memory > 4 | device.df$ram > 1))] <- NA

# B. Front Camera: Must not exceed rear; flag low specs on high-spec hardware
device.df$front_camera_mp[device.df$front_camera_mp > device.df$rear_camera_mp | 
                            (device.df$front_camera_mp < 2 & (device.df$internal_memory > 4 | device.df$ram > 1 | device.df$rear_camera_mp >= 5))] <- NA

# C. Internal Memory: Cannot be less than RAM; flag era-inconsistent high specs
device.df$internal_memory[device.df$internal_memory < device.df$ram | 
                            (device.df$internal_memory > 64 & device.df$release_year < 2015) | 
                            (device.df$internal_memory < 1 & (device.df$rear_camera_mp > 5 | device.df$front_camera_mp > 2 | device.df$ram > 0.5))] <- NA

# D. RAM: Cannot exceed internal memory; flag low RAM on high-spec devices
device.df$ram[device.df$ram > device.df$internal_memory | 
                (device.df$ram < 1 & (device.df$internal_memory >= 4 | device.df$rear_camera_mp > 5))] <- NA

# E. Physical Constraint: Standard mobile devices should not exceed 350g
device.df$weight[device.df$weight > 350 & device.df$screen_size < 15] <- NA

# 6. FINAL RE-IMPUTATION OF OUTLIERS (Matching Grouping Logic)

# Re-impute Rear Camera, Internal Memory, and Weight by BRAND
device.df <- device.df %>%
  group_by(device_brand) %>%
  mutate(
    rear_camera_mp = ifelse(is.na(rear_camera_mp), median(rear_camera_mp, na.rm = TRUE), rear_camera_mp),
    internal_memory = ifelse(is.na(internal_memory), median(internal_memory, na.rm = TRUE), internal_memory),
    weight = ifelse(is.na(weight), median(weight, na.rm = TRUE), weight)
  ) %>%
  ungroup()

# Re-impute Front Camera and RAM by RELEASE YEAR
device.df <- device.df %>%
  group_by(release_year) %>%
  mutate(
    front_camera_mp = ifelse(is.na(front_camera_mp), median(front_camera_mp, na.rm = TRUE), front_camera_mp),
    ram = ifelse(is.na(ram), median(ram, na.rm = TRUE), ram)
  ) %>%
  ungroup()

# 7. FEATURE ENGINEERING & FINAL EXPORT
median_price <- median(device.df$normalized_new_price, na.rm = TRUE)
device.df$price_tier <- ifelse(device.df$normalized_new_price <= median_price, "Low", "High")
device.df$price_tier <- as.factor(device.df$price_tier)

# Save cleaned data to Silver Layer
write.csv(device.df, "C:/Users/RINA/Desktop/data-analytics-portfolio/02_data_cleaning/2_4_r_cleaning/data/silver/silver_used_devices.csv", row.names = FALSE)

# 8. VERIFICATION
print("Missing Value Summary (Total NAs should be 0):")
print(colSums(is.na(device.df)))