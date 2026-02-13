#!/usr/bin/env python3
"""
Generic CSV Processor
---------------------
A flexible CSV transformation tool that works with any CSV file.

Features:
- Column mapping from source to output
- Auto-generate columns (sequential, random, static, UUID)
- Filter blank rows and duplicates
- Configurable via config.json

Usage:
    python3 process_csv.py
    python3 process_csv.py input.csv output.csv
"""

import csv
import sys
import json
import random
import string
import uuid
from pathlib import Path
from datetime import datetime


def clean_config(data):
    """Recursively remove fields starting with underscore."""
    if isinstance(data, dict):
        return {k: clean_config(v) for k, v in data.items() if not k.startswith('_')}
    elif isinstance(data, list):
        return [clean_config(item) for item in data]
    else:
        return data


def load_config(config_file='config.json'):
    """Load configuration from JSON file."""
    try:
        with open(config_file, 'r', encoding='utf-8') as f:
            config = json.load(f)
            # Remove comment fields recursively
            return clean_config(config)
    except FileNotFoundError:
        print(f"ERROR: Config file '{config_file}' not found!")
        print(f"Please create config.json or copy from config.example.json")
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"ERROR: Invalid JSON in config file: {e}")
        sys.exit(1)


def generate_value(column_config, row_number, previous_value=None):
    """Generate a value based on column configuration."""
    col_type = column_config.get('type', 'static')
    
    if col_type == 'sequential':
        start = column_config.get('start', 1)
        return start + row_number
    
    elif col_type == 'random_hex':
        length = column_config.get('length', 12)
        return ''.join(random.choices(string.hexdigits.lower(), k=length))
    
    elif col_type == 'uuid':
        return str(uuid.uuid4())
    
    elif col_type == 'static':
        return column_config.get('value', '')
    
    elif col_type == 'timestamp':
        fmt = column_config.get('format', '%Y-%m-%d %H:%M:%S')
        return datetime.now().strftime(fmt)
    
    else:
        return ''


def process_csv(input_file, output_file, config):
    """
    Process CSV file according to configuration.
    
    Steps:
    1. Load source CSV
    2. Map columns from source to output
    3. Generate new columns
    4. Apply filters
    5. Save to output file
    """
    
    # Get configuration sections
    files_config = config.get('files', {})
    columns_config = config.get('columns', {})
    generated_config = config.get('generated_columns', {})
    filters_config = config.get('filters', {})
    output_config = config.get('output_settings', {})
    processing_config = config.get('processing', {})
    
    # Get source column mapping
    source_mapping = columns_config.get('source_mapping', {})
    
    # Get settings
    remove_blank = filters_config.get('remove_blank_rows', True)
    remove_duplicates = filters_config.get('remove_duplicates', False)
    dup_column = filters_config.get('duplicate_check_column', '')
    encoding = output_config.get('encoding', 'utf-8')
    column_order = output_config.get('column_order', [])
    verbose = processing_config.get('verbose_logging', True)
    
    # Statistics
    stats = {
        'total_rows': 0,
        'kept_rows': 0,
        'blank_rows': 0,
        'duplicate_rows': 0
    }
    
    seen_values = set()
    row_number = 0
    generated_values = {}
    
    try:
        # Read input CSV
        with open(input_file, 'r', encoding=encoding) as infile:
            reader = csv.DictReader(infile)
            
            if reader.fieldnames is None:
                print("ERROR: No headers found in input file!")
                return False
            
            # Verify source columns exist
            missing_cols = set(source_mapping.values()) - set(reader.fieldnames)
            if missing_cols:
                print(f"ERROR: Missing source columns: {missing_cols}")
                print(f"Available columns: {list(reader.fieldnames)}")
                return False
            
            # Prepare output columns
            if column_order:
                output_columns = column_order
            else:
                output_columns = list(source_mapping.keys()) + list(generated_config.keys())
            
            # Write output CSV
            with open(output_file, 'w', encoding=encoding, newline='') as outfile:
                writer = csv.DictWriter(outfile, fieldnames=output_columns)
                writer.writeheader()
                
                # Process each row
                for row in reader:
                    stats['total_rows'] += 1
                    
                    # Map source columns
                    output_row = {}
                    has_blank = False
                    
                    for out_col, src_col in source_mapping.items():
                        value = row.get(src_col, '').strip()
                        
                        if not value and remove_blank:
                            has_blank = True
                            stats['blank_rows'] += 1
                            break
                        
                        output_row[out_col] = value
                    
                    # Skip if blank row
                    if has_blank:
                        continue
                    
                    # Check for duplicates
                    if remove_duplicates and dup_column in output_row:
                        dup_value = output_row[dup_column]
                        if dup_value in seen_values:
                            stats['duplicate_rows'] += 1
                            continue
                        seen_values.add(dup_value)
                    
                    # Generate new columns
                    for col_name, col_config in generated_config.items():
                        prev_val = generated_values.get(col_name)
                        generated_val = generate_value(col_config, row_number, prev_val)
                        output_row[col_name] = generated_val
                        generated_values[col_name] = generated_val
                    
                    # Write row
                    writer.writerow(output_row)
                    stats['kept_rows'] += 1
                    row_number += 1
        
        # Print summary
        print("\n" + "="*60)
        print("PROCESSING SUMMARY")
        print("="*60)
        print(f"Input file:       {input_file}")
        print(f"Output file:      {output_file}")
        print(f"Total rows:       {stats['total_rows']}")
        print(f"Kept rows:        {stats['kept_rows']}")
        print(f"Blank rows:       {stats['blank_rows']}")
        if remove_duplicates:
            print(f"Duplicate rows:   {stats['duplicate_rows']}")
        print("="*60)
        
        if verbose:
            print(f"\nColumn Mapping:")
            for out_col, src_col in source_mapping.items():
                print(f"  '{src_col}' → '{out_col}'")
            
            print(f"\nGenerated Columns:")
            for col_name, col_config in generated_config.items():
                col_type = col_config.get('type', 'static')
                desc = col_config.get('description', '')
                print(f"  {col_name} ({col_type}) - {desc}")
        
        print("="*60 + "\n")
        
        # Update config if needed
        if processing_config.get('update_product_id_start', False):
            update_sequential_starts(config, row_number)
        
        return True
        
    except FileNotFoundError:
        print(f"ERROR: Input file '{input_file}' not found!")
        return False
    except Exception as e:
        print(f"ERROR: {str(e)}")
        import traceback
        traceback.print_exc()
        return False


def update_sequential_starts(config, rows_processed):
    """Update sequential column start values in config."""
    generated = config.get('generated_columns', {})
    updated = False
    
    for col_name, col_config in generated.items():
        if col_config.get('type') == 'sequential':
            old_start = col_config.get('start', 1)
            new_start = old_start + rows_processed
            col_config['start'] = new_start
            updated = True
            print(f"✓ Updated {col_name} start: {old_start} → {new_start}")
    
    if updated and config.get('processing', {}).get('auto_update_config', True):
        try:
            with open('config.json', 'w', encoding='utf-8') as f:
                json.dump(config, f, indent=2)
            print(f"✓ Config file updated")
        except Exception as e:
            print(f"WARNING: Could not update config: {e}")


def main():
    """Main function."""
    
    # Load config
    config = load_config()
    
    # Get file paths from config or command line
    files_config = config.get('files', {})
    input_file = files_config.get('input_file', 'input/source.csv')
    output_file = files_config.get('output_file', 'output/cleaned.csv')
    
    # Allow command line override
    if len(sys.argv) > 1:
        input_file = sys.argv[1]
    if len(sys.argv) > 2:
        output_file = sys.argv[2]
    
    print(f"\nGeneric CSV Processor")
    print(f"{'='*60}")
    print(f"Processing: {input_file}")
    print(f"Output to:  {output_file}")
    print(f"Config:     config.json\n")
    
    # Process CSV
    success = process_csv(input_file, output_file, config)
    
    if success:
        print("✓ Processing completed successfully!")
        return 0
    else:
        print("✗ Processing failed!")
        return 1


if __name__ == "__main__":
    sys.exit(main())
