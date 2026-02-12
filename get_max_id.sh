#!/bin/bash

# Get Maximum Product ID from products.csv
# Simple script to find the highest product_id value

CSV_FILE="${1:-/var/www/nilgiristores.in/csv-pipeline/products.csv}"

if [ ! -f "$CSV_FILE" ]; then
    echo "ERROR: File '$CSV_FILE' not found!"
    exit 1
fi

echo "Analyzing: $CSV_FILE"
echo ""

# Get the highest product_id (skip header, extract column 1, find max)
MAX_ID=$(tail -n +2 "$CSV_FILE" | cut -d',' -f1 | sort -n | tail -1)

if [ -z "$MAX_ID" ]; then
    echo "ERROR: Could not find product_id values!"
    exit 1
fi

# Count total rows (excluding header)
TOTAL_ROWS=$(tail -n +2 "$CSV_FILE" | wc -l)

# Calculate next available ID
NEXT_ID=$((MAX_ID + 1))

echo "============================================================"
echo "RESULTS"
echo "============================================================"
echo "Total products:      $TOTAL_ROWS"
echo "Highest product_id:  $MAX_ID"
echo "Next available ID:   $NEXT_ID"
echo "============================================================"
echo ""

# Optionally update config.json
if [ -f "config.json" ]; then
    echo -n "Update config.json with next ID ($NEXT_ID)? (y/n): "
    read -r UPDATE
    
    if [ "$UPDATE" = "y" ] || [ "$UPDATE" = "Y" ]; then
        # Update config.json using Python one-liner
        python3 -c "
import json
with open('config.json', 'r') as f:
    config = json.load(f)
old = config.get('product_id_start', 0)
config['product_id_start'] = $NEXT_ID
with open('config.json', 'w') as f:
    json.dump(config, f, indent=2)
print(f'✓ Updated config.json: {old} → $NEXT_ID')
"
    else
        echo "Config.json not updated."
    fi
fi
