# Generic CSV Pipeline

A flexible, configuration-driven CSV transformation tool that works with any CSV file. Transform, filter, and enhance your data with ease.

## 🚀 Quick Start

### Clone Repository

```bash
git clone https://github.com/kadavilrahul/csv-pipeline
```

```bash
cd csv-pipeline
```

```bash
./run.sh
```

Choose option 1 to process your CSV file.

## Prerequisites

Before you begin, make sure you have:

1. Python 3.6 or higher installed
2. Bash shell (Linux/Mac/Git Bash on Windows)
3. Git for downloading the code

## What This Tool Does

This generic CSV processor allows you to:

1. **Map Columns** - Extract specific columns from any CSV file
2. **Generate Columns** - Auto-create product IDs, SKUs, UUIDs, timestamps
3. **Apply Filters** - Remove blank rows, duplicates, and invalid data
4. **Transform Data** - Process any CSV structure via config.json

## Setup

### Step 1: Place Your CSV File

```bash
cp /path/to/your/data.csv input/source.csv
```

### Step 2: Configure

Edit `config.json` to match your CSV structure:

```json
{
  "files": {
    "input_file": "input/source.csv",
    "output_file": "output/cleaned.csv"
  },
  "columns": {
    "source_mapping": {
      "new_column_name": "Original Column Name From CSV"
    }
  }
}
```

### Step 3: Run

```bash
./run.sh clean
```

## Configuration Guide

All settings are in `config.json`. See `config.example.json` for detailed examples.

### File Paths

```json
"files": {
  "input_file": "input/your-file.csv",
  "output_file": "output/result.csv"
}
```

### Column Mapping

Map source columns to output columns:

```json
"columns": {
  "source_mapping": {
    "id": "Product ID",
    "name": "Product Name",
    "price": "Price (USD)"
  }
}
```

### Generated Columns

Auto-generate new columns:

```json
"generated_columns": {
  "row_id": {
    "type": "sequential",
    "start": 1
  },
  "sku": {
    "type": "random_hex",
    "length": 12
  },
  "category": {
    "type": "static",
    "value": "Electronics"
  }
}
```

**Available types**: `sequential`, `random_hex`, `uuid`, `static`, `timestamp`

### Filters

Control data quality:

```json
"filters": {
  "remove_blank_rows": true,
  "remove_duplicates": false,
  "duplicate_check_column": "url"
}
```

## Usage

### Interactive Menu

```bash
./run.sh
```

Menu options:
1. Clean CSV - Process the file
2. Preview output - See first 10 rows
3. Show statistics - View file info
4. Get max product_id - Sync with existing data
5. Help - Show usage

### Direct Commands

```bash
./run.sh clean    # Process CSV
./run.sh preview  # Preview results
./run.sh stats    # Show statistics
./run.sh maxid    # Update product_id from products.csv
```

## Project Structure

1. `input/` - Place your source CSV files here
2. `output/` - Processed files are saved here
3. `process_csv.py` - Main processing script
4. `config.json` - Your configuration
5. `config.example.json` - Template with all options
6. `run.sh` - Interactive menu and commands

## Column Types Explained

1. **sequential** - Auto-incrementing numbers (1, 2, 3, 4...)
2. **random_hex** - Random codes (a1b2c3d4e5f6)
3. **uuid** - UUID format (550e8400-e29b-41d4-a716-446655440000)
4. **static** - Same value for all rows
5. **timestamp** - Current date/time

## Examples

### Example 1: Product Data

Input CSV has: "Product Link", "Image URL", "Cost", "Product Title"

Config:
```json
"source_mapping": {
  "url": "Product Link",
  "image": "Image URL",
  "price": "Cost",
  "name": "Product Title"
}
```

### Example 2: Generate IDs and SKUs

```json
"generated_columns": {
  "product_id": {
    "type": "sequential",
    "start": 1000
  },
  "sku": {
    "type": "random_hex",
    "length": 8
  }
}
```

Output: product_id (1000, 1001...), sku (f3a9b2c1, 8d4e5f6a...)

## Troubleshooting

1. **"Config file not found"**
   Copy config.example.json to config.json and edit

2. **"Missing source columns"**
   Check your CSV headers match the source_mapping values

3. **"No data in output"**
   Disable remove_blank_rows if your data has some empty fields

4. **Wrong file paths**
   Edit files section in config.json with correct paths

## License

This project is open source and free to use.
