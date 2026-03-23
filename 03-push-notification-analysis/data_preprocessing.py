"""
Push Notification Data Preprocessing
--------------------------------------
Ingests raw ThinQ app push notification exports, standardizes fields, and splits output by notification logic type for downstream analysis.
Raw data not included due to confidentiality.
"""

import os
import pandas as pd

# ---------------------------------------------------------------------------
# Paths — update before running
# ---------------------------------------------------------------------------

RAW_DATA_PATH = "data/raw"
OUTPUT_PATH   = "data/processed_logics"

# ---------------------------------------------------------------------------
# Mapping functions
# ---------------------------------------------------------------------------

def map_product(service_product_name: str) -> str:
    """Map raw SERVICE_PRODUCT_NAME to a standardized product category."""
    mapping = {
        "Range/Oven/Electric Cooktop": "Oven",
        "French Door":                 "Refrigerator",
        "Side by Side":                "Refrigerator",
        "Dish Washer":                 "Dishwasher",
        "Styler":                      "Styler",
        "Laundry Dryer":               "Dryer",
        "Front Loader":                "Washer",
        "Top Loader":                  "Washer",
    }
    return mapping.get(service_product_name, "")


def map_logic(diagnosis_type: str) -> str:
    """Normalize granular DIAGNOSIS_TYPE codes into grouped logic labels."""
    diagnosis_type = str(diagnosis_type)

    exact = {
        "IM_FAILURE":      "IM_FAILURE",
        "IM_FAILURE_FRD":  "IM_FAILURE",
        "FL_TUB_OVLD":     "TUB_OVLD",
        "TL_TUB_OVLD":     "TUB_OVLD",
        "FL_VALVE_CHANGE": "VALVE_CHANGE",
        "TL_VALVE_CHANGE": "VALVE_CHANGE",
    }
    if diagnosis_type in exact:
        return exact[diagnosis_type]

    substrings = [
        ("SELF_CLEAN",        "SELF_CLEAN"),
        ("IM_WATER_SUPPLY",   "IM_WATER_SUPPLY_FAILURE"),
        ("REF_LEAKAGE",       "REF_LEAKAGE"),
        ("LONG_PREHEAT_DOOR", "LONG_PREHEAT_DOOR_OPEN"),
        ("WaterFilter",       "WATERFILTER"),
        ("DISPENSING_LOCK",   "DISPENSING_LOCK"),
    ]
    for substring, label in substrings:
        if substring in diagnosis_type:
            return label

    return diagnosis_type


def map_status(status: str) -> str:
    """Convert raw delivery status to a human-readable engagement label."""
    return "Unread" if status == "DELIVERED" else "Read"


# ---------------------------------------------------------------------------
# Pipeline
# ---------------------------------------------------------------------------

def load_raw_data(folder: str) -> pd.DataFrame:
    """Read all CSVs in folder, handling UTF-8 and UTF-16 encodings."""
    csv_files = [f for f in os.listdir(folder) if f.endswith(".csv")]
    if not csv_files:
        raise FileNotFoundError(f"No CSV files found in: {folder}")

    frames = []
    for filename in csv_files:
        filepath = os.path.join(folder, filename)
        try:
            frames.append(pd.read_csv(filepath))
        except UnicodeDecodeError:
            try:
                frames.append(pd.read_csv(filepath, sep="\t", encoding="utf-16"))
            except Exception as e:
                print(f"  [WARNING] Skipped {filename}: {e}")
        except Exception as e:
            print(f"  [WARNING] Skipped {filename}: {e}")

    return pd.concat(frames, ignore_index=True)


def preprocess(df: pd.DataFrame) -> pd.DataFrame:
    """Select columns, engineer features, filter bad date window, deduplicate."""
    df = df[[
        "MBR_NO", "DEVICE_ID", "SERVICE_PRODUCT_NAME",
        "DIAGNOSIS_TYPE", "STATUS", "DELIVERY_DATE",
    ]].copy()

    df["PRODUCT"]      = df["SERVICE_PRODUCT_NAME"].apply(map_product)
    df["LOGIC"]        = df["DIAGNOSIS_TYPE"].apply(map_logic)
    df["STATUS_CLEAN"] = df["STATUS"].apply(map_status)

    df["DATE"]   = pd.to_datetime(df["DELIVERY_DATE"], errors="coerce").dt.strftime("%Y-%m-%d")
    df = df.dropna(subset=["DATE"])
    
    df["MONTH"]  = pd.to_datetime(df["DELIVERY_DATE"], errors="coerce").dt.month
    df["YEAR"]   = pd.to_datetime(df["DELIVERY_DATE"], errors="coerce").dt.year
    df["YYYYMM"] = pd.to_datetime(df["DATE"]).dt.strftime("%Y%m")

    df["DEVICE_LOGIC"]     = df["DEVICE_ID"] + df["DIAGNOSIS_TYPE"]
    df["MBR_DEVICE_LOGIC"] = df["MBR_NO"] + df["DEVICE_ID"] + df["DIAGNOSIS_TYPE"]

    # Exclude dates
    df = df[(df["DATE"] < "2024-02-05") | (df["DATE"] > "2024-02-17")]
    df = df.drop_duplicates()

    return df


def export_by_logic(df: pd.DataFrame, output_dir: str) -> None:
    """Write one CSV per notification logic type."""
    os.makedirs(output_dir, exist_ok=True)
    for logic, group in df.groupby("LOGIC"):
        out_path = os.path.join(output_dir, f"{logic.upper()}.csv")
        group.to_csv(out_path, index=False)
        print(f"  Exported {len(group):>7,} rows → {logic.upper()}.csv")


def main():
    print("=== Push Notification Preprocessing ===\n")

    raw = load_raw_data(RAW_DATA_PATH)
    df  = preprocess(raw)

    print(f"  {len(df):,} rows processed")
    print(f"  {df['MBR_NO'].nunique():,} unique members")
    print(f"  {df['LOGIC'].nunique()} logic types\n")

    print("Exporting by logic...")
    export_by_logic(df, OUTPUT_PATH)
    print("\nDone.")


if __name__ == "__main__":
    main()
