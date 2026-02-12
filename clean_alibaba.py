#!/usr/bin/env python3
"""
Alibaba CSV Cleaner
-------------------
Removes unwanted columns, deletes rows with blank cells, and renames headers
to match the required format for HTML product page generation.

Features:
- Generates sequential product_id starting from config.json value
- Optionally generates random SKU codes
- Adds category and tags from config
- Removes rows with blank cells

Configuration: Edit config.json to customize behavior
"""

import csv
import sys
import json
import random
import string
from pathlib import Path


def load_config(config_file='config.json'):
    """Load configuration from JSON file."""
    try:
        with open(config_file, 'r', encoding='utf-8') as f:
            return json.load(f)
    except FileNotFoundError:
        print(f"ERROR: Config file '{config_file}' not found!")
        print("Creating default config.json...")
        
        # Create default config
        default_config = {
            "product_id_start": 1094100,
            "generate_random_sku": True,
            "category": "Camera Accessories",
            "tags": "camera,alibaba,electronics",
            "output_settings": {
                "remove_blank_rows": True,
                "encoding": "utf-8"
            },
            "column_mapping": {
                "source_product_url": "searchx-product-e-slider__link href",
                "source_image_url": "searchx-product-e-slider__img src",
                "source_price": "searchx-product-price-price-main",
                "source_title": "searchx-product-e-title"
            }
        }
        
        with open(config_file, 'w', encoding='utf-8') as f:
            json.dump(default_config, f, indent=2)
        
        print(f"Created {config_file} with default settings.")
        return default_config
    except json.JSONDecodeError as e:
        print(f"ERROR: Invalid JSON in config file: {e}")
        sys.exit(1)


def generate_random_sku(length=12):
    """Generate a random SKU code (hexadecimal)."""
    return ''.join(random.choices(string.hexdigits.lower(), k=length))


def clean_alibaba_csv(input_file, output_file, config):
    """
    Clean the Alibaba CSV file by:
    1. Keeping only 4 required columns
    2. Adding product_id, SKU, category, tags columns
    3. Removing rows with any blank cells
    4. Renaming headers to simple names
    """
    
    # Get column mapping from config
    col_map = config.get('column_mapping', {})
    
    # Column mapping: original_name → new_name
    COLUMNS_TO_KEEP = {
        col_map.get('source_product_url', 'searchx-product-e-slider__link href'): 'product_url',
        col_map.get('source_image_url', 'searchx-product-e-slider__img src'): 'image_url',
        col_map.get('source_price', 'searchx-product-price-price-main'): 'price',
        col_map.get('source_title', 'searchx-product-e-title'): 'title'
    }
    
    # New output columns including generated fields
    output_columns = ['product_id', 'product_url', 'image_url', 'price', 'title', 'sku', 'category', 'tags']
    
    # Get settings from config
    product_id_start = config.get('product_id_start', 1094100)
    generate_sku = config.get('generate_random_sku', True)
    category = config.get('category', 'Uncategorized')
    tags = config.get('tags', '')
    remove_blank_rows = config.get('output_settings', {}).get('remove_blank_rows', True)
    
    stats = {
        'total_rows': 0,
        'kept_rows': 0,
        'deleted_rows': 0,
        'blank_cell_rows': 0
    }
    
    current_product_id = product_id_start
    
    try:
        with open(input_file, 'r', encoding='utf-8') as infile:
            reader = csv.DictReader(infile)
            
            # Verify all required columns exist
            if reader.fieldnames is None:
                print("ERROR: No headers found in input file!")
                return False
                
            missing_cols = set(COLUMNS_TO_KEEP.keys()) - set(reader.fieldnames)
            if missing_cols:
                print(f"ERROR: Missing required columns: {missing_cols}")
                print(f"Available columns: {reader.fieldnames}")
                return False
            
            # Prepare output file
            with open(output_file, 'w', encoding='utf-8', newline='') as outfile:
                # Write new headers
                writer = csv.DictWriter(outfile, fieldnames=output_columns)
                writer.writeheader()
                
                # Process each row
                for row in reader:
                    stats['total_rows'] += 1
                    
                    # Extract only the columns we need
                    cleaned_row = {}
                    has_blank = False
                    
                    for old_col, new_col in COLUMNS_TO_KEEP.items():
                        value = row.get(old_col, '').strip()
                        
                        # Check if cell is blank
                        if not value:
                            has_blank = True
                            stats['blank_cell_rows'] += 1
                            break
                        
                        cleaned_row[new_col] = value
                    
                    # Only write row if all cells have values (or if blank removal is disabled)
                    if not has_blank or not remove_blank_rows:
                        # Add generated fields
                        cleaned_row['product_id'] = current_product_id
                        cleaned_row['sku'] = generate_random_sku() if generate_sku else f"SKU{current_product_id}"
                        cleaned_row['category'] = category
                        cleaned_row['tags'] = tags
                        
                        writer.writerow(cleaned_row)
                        stats['kept_rows'] += 1
                        current_product_id += 1
                    else:
                        stats['deleted_rows'] += 1
        
        # Print summary
        print("\n" + "="*60)
        print("CLEANING SUMMARY")
        print("="*60)
        print(f"Input file:       {input_file}")
        print(f"Output file:      {output_file}")
        print(f"Total rows:       {stats['total_rows']}")
        print(f"Kept rows:        {stats['kept_rows']}")
        print(f"Deleted rows:     {stats['deleted_rows']}")
        print(f"Rows with blanks: {stats['blank_cell_rows']}")
        print("="*60)
        print(f"\nConfiguration Applied:")
        print(f"  Product ID start: {product_id_start}")
        print(f"  Product ID end:   {current_product_id - 1}")
        print(f"  Generate SKU:     {generate_sku}")
        print(f"  Category:         {category}")
        print(f"  Tags:             {tags}")
        print("="*60)
        print(f"\nColumns kept:")
        for old_col, new_col in COLUMNS_TO_KEEP.items():
            print(f"  '{old_col}' → '{new_col}'")
        print(f"\nGenerated columns:")
        print(f"  product_id - Sequential ID starting from {product_id_start}")
        print(f"  sku - {'Random 12-char hex' if generate_sku else 'SKU + product_id'}")
        print(f"  category - {category}")
        print(f"  tags - {tags}")
        print("="*60 + "\n")
        
        # Update config with next product_id
        config['product_id_start'] = current_product_id
        with open('config.json', 'w', encoding='utf-8') as f:
            json.dump(config, f, indent=2)
        print(f"✓ Updated config.json: next product_id will start at {current_product_id}")
        
        return True
        
    except FileNotFoundError:
        print(f"ERROR: Input file '{input_file}' not found.")
        return False
    except Exception as e:
        print(f"ERROR: {str(e)}")
        import traceback
        traceback.print_exc()
        return False


def main():
    """Main function to run the CSV cleaner."""
    
    # Load configuration
    config = load_config()
    
    # Default file paths
    input_file = 'alibaba.csv'
    output_file = 'alibaba_cleaned.csv'
    
    # Allow command line arguments
    if len(sys.argv) > 1:
        input_file = sys.argv[1]
    if len(sys.argv) > 2:
        output_file = sys.argv[2]
    
    print(f"\nAlibaba CSV Cleaner with Config")
    print(f"{'='*60}")
    print(f"Processing: {input_file}")
    print(f"Output to:  {output_file}")
    print(f"Config:     config.json")
    print()
    
    # Run the cleaning
    success = clean_alibaba_csv(input_file, output_file, config)
    
    if success:
        print("\n✓ Cleaning completed successfully!")
        return 0
    else:
        print("\n✗ Cleaning failed!")
        return 1


if __name__ == "__main__":
    sys.exit(main())
