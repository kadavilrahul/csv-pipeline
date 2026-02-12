# Alibaba CSV Cleaning Pipeline

A Python-based tool that cleans and transforms Alibaba product data CSV files by removing unwanted columns, filtering blank rows, and preparing data for HTML product page generation.

## 🚀 Quick Start

### Clone Repository

```bash
git clone https://github.com/kadavilrahul/csv-pipeline
```

```bash
cd csv-pipeline
```

```bash
bash run.sh
```

The script will automatically clean your CSV file and show you a menu with options.

## Prerequisites

Before you begin, make sure you have:

1. Python 3.6 or higher installed on your computer
2. Bash shell (comes with Linux/Mac, use Git Bash on Windows)
3. Git for downloading the code

## What This Tool Does

This tool transforms messy Alibaba product CSV files into clean, organized data:

1. **Removes Unwanted Columns** - Keeps only 4 essential fields (product URL, image URL, price, title)
2. **Auto-Generates Fields** - Creates product_id, SKU, category, and tags using config.json
3. **Cleans Data** - Removes rows with missing information automatically
4. **Interactive Menu** - User-friendly interface to run cleaning, preview results, or view statistics

## How to Use

### Option 1: Interactive Menu (Recommended for Beginners)

Run the script without arguments to see a menu:

```bash
./run.sh
```

You'll see these options:
1. Clean CSV - Processes your alibaba.csv file
2. Preview cleaned output - Shows first 10 rows of results
3. Show statistics - Displays file information
4. Help - Shows usage instructions
0. Exit - Closes the program

### Option 2: Direct Commands (For Quick Tasks)

If you know exactly what you want to do:

```bash
./run.sh clean     # Clean the CSV file
./run.sh preview   # See the results
./run.sh stats     # View statistics
```

## Input and Output Files

1. **Input File**: `alibaba.csv` - Your raw Alibaba product data (30 columns)
2. **Output File**: `alibaba_cleaned.csv` - Clean data with 8 columns (product_id, product_url, image_url, price, title, sku, category, tags)
3. **Config File**: `config.json` - Controls product_id start, SKU generation, category, and tags
4. **Processing Plan**: `plan.txt` - Explains the data transformation strategy

## Project Structure

1. `clean_alibaba.py` - Python script that does the actual data cleaning
2. `run.sh` - Bash script with interactive menu and direct command support
3. `config.json` - Configuration for product_id, SKU, category, and tags (auto-created)
4. `plan.txt` - 50-line plan explaining the CSV cleaning strategy
5. `alibaba.csv` - Your source data file (you need to provide this)
6. `sample_products.csv` - Example of final format for HTML generation (23 columns)
7. `agent/` - Contains markdown files for various automation agents

## The Cleaning Process

When you run the cleaner, it does these steps:

1. Reads config.json for settings (product_id start, category, tags, SKU generation)
2. Reads your alibaba.csv file (30 columns with Alibaba scraped data)
3. Extracts these 4 columns and generates 4 new ones:
   - searchx-product-e-slider__link href → product_url
   - searchx-product-e-slider__img src → image_url
   - searchx-product-price-price-main → price
   - searchx-product-e-title → title
   - Auto-generates: product_id (sequential), sku (random hex), category, tags
4. Removes any rows that have empty cells in the extracted columns
5. Saves the cleaned data to alibaba_cleaned.csv (8 columns total)
6. Updates config.json with next product_id to prevent duplicates
7. Shows you a summary with row counts and configuration applied

## Troubleshooting

1. **Problem**: "File 'alibaba.csv' not found" error
   **Solution**: Make sure you have an alibaba.csv file in the same folder as run.sh

2. **Problem**: "Python script not found" error
   **Solution**: Check that clean_alibaba.py exists in the same folder

3. **Problem**: "Permission denied" when running run.sh
   **Solution**: Make the script executable with this command:
   ```bash
   chmod +x run.sh
   ```

4. **Problem**: Script says "Missing required columns"
   **Solution**: Your CSV file must have these exact column headers:
   - searchx-product-e-slider__link href
   - searchx-product-e-slider__img src
   - searchx-product-price-price-main
   - searchx-product-e-title

5. **Problem**: Python not installed or wrong version
   **Solution**: Install Python 3.6+ from python.org, then try again

## Configuration (config.json)

Edit `config.json` to customize output. The script auto-creates this file on first run:

1. **product_id_start** - Starting number for product IDs (auto-updates after each run)
2. **generate_random_sku** - Set `true` for random hex SKUs, `false` for SKU+product_id format
3. **category** - Category name applied to all products (e.g., "Camera Accessories")
4. **tags** - Comma-separated tags (e.g., "camera,alibaba,electronics")

Example: Change category before processing different product types.

## Understanding the Output

After cleaning, you'll see:

1. **Total rows** - How many products were in your original file
2. **Kept rows** - Products with complete information (these are saved)
3. **Product ID range** - Starting and ending product_id numbers
4. **Configuration applied** - Category, tags, and SKU generation method used

The cleaned CSV has 8 columns: product_id, product_url, image_url, price, title, sku, category, tags.

## License

This project is open source and free to use for cleaning Alibaba product data.
