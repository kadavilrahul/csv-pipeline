#!/usr/bin/env python3
"""
Alibaba CSV Cleaner
-------------------
Removes unwanted columns, deletes rows with blank cells, and renames headers
to match the required format for HTML product page generation.

Target columns:
- searchx-product-e-slider__link href → product_url
- searchx-product-e-slider__img src → image_url
- searchx-product-price-price-main → price
- searchx-product-e-title → title
"""

import csv
import sys
from pathlib import Path


def clean_alibaba_csv(input_file, output_file):
    """
    Clean the Alibaba CSV file by:
    1. Keeping only 4 required columns
    2. Removing rows with any blank cells
    3. Renaming headers to simple names
    """
    
    # Column mapping: original_name → new_name
    COLUMNS_TO_KEEP = {
        'searchx-product-e-slider__link href': 'product_url',
        'searchx-product-e-slider__img src': 'image_url',
        'searchx-product-price-price-main': 'price',
        'searchx-product-e-title': 'title'
    }
    
    stats = {
        'total_rows': 0,
        'kept_rows': 0,
        'deleted_rows': 0,
        'blank_cell_rows': 0
    }
    
    try:
        with open(input_file, 'r', encoding='utf-8') as infile:
            reader = csv.DictReader(infile)
            
            # Verify all required columns exist
            missing_cols = set(COLUMNS_TO_KEEP.keys()) - set(reader.fieldnames)
            if missing_cols:
                print(f"ERROR: Missing required columns: {missing_cols}")
                print(f"Available columns: {reader.fieldnames}")
                return False
            
            # Prepare output file
            with open(output_file, 'w', encoding='utf-8', newline='') as outfile:
                # Write new headers
                writer = csv.DictWriter(outfile, fieldnames=list(COLUMNS_TO_KEEP.values()))
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
                    
                    # Only write row if all cells have values
                    if not has_blank:
                        writer.writerow(cleaned_row)
                        stats['kept_rows'] += 1
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
        print(f"\nColumns kept:")
        for old_col, new_col in COLUMNS_TO_KEEP.items():
            print(f"  '{old_col}' → '{new_col}'")
        print("="*60 + "\n")
        
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
    
    # Default file paths
    input_file = 'alibaba.csv'
    output_file = 'alibaba_cleaned.csv'
    
    # Allow command line arguments
    if len(sys.argv) > 1:
        input_file = sys.argv[1]
    if len(sys.argv) > 2:
        output_file = sys.argv[2]
    
    print(f"\nAlibaba CSV Cleaner")
    print(f"{'='*60}")
    print(f"Processing: {input_file}")
    print(f"Output to:  {output_file}\n")
    
    # Run the cleaning
    success = clean_alibaba_csv(input_file, output_file)
    
    if success:
        print("✓ Cleaning completed successfully!")
        return 0
    else:
        print("✗ Cleaning failed!")
        return 1


if __name__ == "__main__":
    sys.exit(main())
