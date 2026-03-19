# =========================================
# Push Notification Data Preprocessing
# =========================================

import pandas as pd
import os

# -------------------------------
# 1. Load and Combine Raw Files
# -------------------------------
folder_path = "data/raw"
result_path = "data/processed"

csv_files = [f for f in os.listdir(folder_path) if f.endswith('.csv')]

df_list = []
for file in csv_files:
    file_path = os.path.join(folder_path, file)
    try:
        df_list.append(pd.read_csv(file_path))
    except UnicodeDecodeError:
        df_list.append(pd.read_csv(file_path, sep='\t', encoding='utf-16'))

if not df_list:
    raise ValueError("No CSV files found in the specified directory.")

big_df = pd.concat(df_list, ignore_index=True)

# -------------------------------
# 2. Select Relevant Columns
# -------------------------------
df = big_df[['MBR_NO','DEVICE_ID','SERVICE_PRODUCT_NAME','DIAGNOSIS_TYPE','STATUS','DELIVERY_DATE']].copy()

# -------------------------------
# 3. Feature Engineering
# -------------------------------

def map_product(x):
    if x == 'Range/Oven/Electric Cooktop': return 'Oven'
    elif x in ['French Door','Side by Side']: return 'Refrigerator'
    elif x == 'Dish Washer': return 'Dishwasher'
    elif x == 'Styler': return 'Styler'
    elif x == 'Laundry Dryer': return 'Dryer'
    elif x in ['Front Loader','Top Loader']: return 'Washer'
    return ''

df['PRODUCT'] = df['SERVICE_PRODUCT_NAME'].apply(map_product)

def map_logic(x):
    x = str(x)
    if "CLEAN" in x:
        return "CLEANING"
    elif "CRAFT" in x or "FAILURE" in x:
        return "FAILURE"
    elif "WATER" in x:
        return "WATER_ISSUE"
    elif "TEMP" in x:
        return "TEMPERATURE"
    elif "FILTER" in x:
        return "FILTER"
    elif "LOCK" in x:
        return "LOCK"
    elif "MISUSE" in x:
        return "MISUSE"
    else:
        return "OTHER"

df['LOGIC'] = df['DIAGNOSIS_TYPE'].apply(map_logic)

df['STATUS_CLEAN'] = df['STATUS'].apply(lambda x: 'Unread' if x == 'DELIVERED' else 'Read')

# -------------------------------
# 4. Date Processing
# -------------------------------
df['DATE'] = pd.to_datetime(df['DELIVERY_DATE'], errors='coerce')
df['YYYYMM'] = df['DATE'].dt.strftime('%Y%m')

# Remove abnormal date range
df = df[(df['DATE'] < '2024-02-05') | (df['DATE'] > '2024-02-17')]

df = df.drop_duplicates()

# -------------------------------
# 5. Split Data by Notification Logic
# -------------------------------
os.makedirs(result_path, exist_ok=True)

for logic, group in df.groupby('LOGIC'):
    output_path = os.path.join(result_path, f"{logic.upper()}.csv")
    group.to_csv(output_path, index=False)

# -------------------------------
# 6. Summary
# -------------------------------
print("Total rows processed:", len(df))
print("Unique users:", df['MBR_NO'].nunique())
print("Number of logic groups:", df['LOGIC'].nunique())
