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
2. **Cleans Data** - Removes rows with missing information automatically
3. **Renames Headers** - Simplifies column names for easier processing
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
2. **Output File**: `alibaba_cleaned.csv` - Clean data with 4 columns (product_url, image_url, price, title)
3. **Processing Plan**: `plan.txt` - Explains the data transformation strategy

## Project Structure

1. `clean_alibaba.py` - Python script that does the actual data cleaning
2. `run.sh` - Bash script with interactive menu and direct command support
3. `plan.txt` - 50-line plan explaining the CSV cleaning strategy
4. `alibaba.csv` - Your source data file (you need to provide this)
5. `sample_products.csv` - Example of final format for HTML generation (23 columns)
6. `agent/` - Contains markdown files for various automation agents

## The Cleaning Process

When you run the cleaner, it does these steps:

1. Reads your alibaba.csv file (30 columns with Alibaba scraped data)
2. Extracts these 4 columns only:
   - searchx-product-e-slider__link href → product_url
   - searchx-product-e-slider__img src → image_url
   - searchx-product-price-price-main → price
   - searchx-product-e-title → title
3. Removes any rows that have empty cells in these columns
4. Saves the cleaned data to alibaba_cleaned.csv
5. Shows you a summary with row counts and file sizes

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

## Understanding the Output

After cleaning, you'll see:

1. **Total rows** - How many products were in your original file
2. **Kept rows** - Products with complete information (these are saved)
3. **Deleted rows** - Products with missing data (these are removed)
4. **File sizes** - Original file size vs cleaned file size

The cleaned CSV will be much smaller because it only keeps 4 columns instead of 30.

## Next Steps

After cleaning your CSV:

1. The cleaned file (alibaba_cleaned.csv) can be used for HTML product page generation
2. To convert to the full 23-column format (sample_products.csv), you'll need additional transformation
3. Check plan.txt for details on converting to the final WordPress product format

## Getting Help

If you need assistance:

1. Read the troubleshooting section above for common issues
2. Check plan.txt for detailed information about the data transformation
3. Review the error messages carefully - they tell you what's wrong
4. Make sure your alibaba.csv file has the correct column headers

## License

This project is open source and free to use for cleaning Alibaba product data.
