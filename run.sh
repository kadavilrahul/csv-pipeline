#!/bin/bash

# Generic CSV Pipeline Runner
# Runs the Python script to process any CSV file
# File paths are configured in config.json

# Configuration
PYTHON_SCRIPT="process_csv.py"
CONFIG_FILE="config.json"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to display header
display_header() {
    clear
    echo "========================================"
    echo "     GENERIC CSV PIPELINE              "
    echo "========================================"
    echo ""
}

# Function to check if file exists
check_file() {
    local file=$1
    if [ ! -f "$file" ]; then
        echo -e "${RED}[ERROR]${NC} File '$file' not found!"
        return 1
    fi
    return 0
}

# Function to get file paths from config
get_file_paths() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo -e "${RED}[ERROR]${NC} Config file '$CONFIG_FILE' not found!"
        return 1
    fi
    
    INPUT_FILE=$(python3 -c "import json; print(json.load(open('$CONFIG_FILE'))['files']['input_file'])" 2>/dev/null)
    OUTPUT_FILE=$(python3 -c "import json; print(json.load(open('$CONFIG_FILE'))['files']['output_file'])" 2>/dev/null)
    
    if [ -z "$INPUT_FILE" ] || [ -z "$OUTPUT_FILE" ]; then
        echo -e "${RED}[ERROR]${NC} Could not read file paths from config.json"
        return 1
    fi
    
    return 0
}

# Function to check if Python script exists
check_python_script() {
    if [ ! -f "$PYTHON_SCRIPT" ]; then
        echo -e "${RED}[ERROR]${NC} Python script '$PYTHON_SCRIPT' not found!"
        exit 1
    fi
}

# Function to run cleaning script
run_cleaning() {
    display_header
    
    # Get file paths from config
    get_file_paths || return 1
    
    echo "Configuration:"
    echo "  Input:  $INPUT_FILE"
    echo "  Output: $OUTPUT_FILE"
    echo "  Script: $PYTHON_SCRIPT"
    echo ""
    
    # Check if input file exists
    if ! check_file "$INPUT_FILE"; then
        exit 1
    fi
    
    # Check if Python script exists
    check_python_script
    
    echo -e "${YELLOW}[INFO]${NC} Starting CSV cleaning process..."
    echo ""
    
    # Run the Python script
    python3 "$PYTHON_SCRIPT" "$INPUT_FILE" "$OUTPUT_FILE"
    
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        echo ""
        echo -e "${GREEN}[SUCCESS]${NC} CSV cleaning completed!"
        echo ""
        
        # Show file sizes
        if [ -f "$OUTPUT_FILE" ]; then
            local input_size=$(du -h "$INPUT_FILE" | cut -f1)
            local output_size=$(du -h "$OUTPUT_FILE" | cut -f1)
            echo "File sizes:"
            echo "  Original: $input_size"
            echo "  Cleaned:  $output_size"
            echo ""
        fi
    else
        echo ""
        echo -e "${RED}[ERROR]${NC} CSV cleaning failed!"
        exit 1
    fi
}

# Function to preview cleaned file
preview_output() {
    get_file_paths || return 1
    
    if ! check_file "$OUTPUT_FILE"; then
        echo -e "${RED}[ERROR]${NC} Cleaned file not found. Run cleaning first."
        exit 1
    fi
    
    display_header
    echo "Preview of cleaned CSV (first 10 rows):"
    echo ""
    
    head -11 "$OUTPUT_FILE" | column -t -s ',' | head -11
    
    echo ""
    local total_rows=$(wc -l < "$OUTPUT_FILE")
    echo "Total rows in cleaned file: $total_rows (including header)"
    echo ""
}

# Function to show statistics
show_stats() {
    get_file_paths || return 1
    
    if ! check_file "$OUTPUT_FILE"; then
        echo -e "${RED}[ERROR]${NC} Cleaned file not found. Run cleaning first."
        exit 1
    fi
    
    display_header
    echo "Statistics for cleaned CSV:"
    echo ""
    
    # Count rows
    local total_rows=$(($(wc -l < "$OUTPUT_FILE") - 1))
    echo "Total products: $total_rows"
    echo ""
    
    # Show column headers
    echo "Columns:"
    head -1 "$OUTPUT_FILE" | tr ',' '\n' | nl
    echo ""
    
    # Price statistics
    echo "Price range:"
    tail -n +2 "$OUTPUT_FILE" | cut -d',' -f3 | head -5
    echo "... (showing first 5 prices)"
    echo ""
}

# Function to get max product ID from products.csv
get_max_product_id() {
    display_header
    
    local PRODUCTS_CSV="/var/www/nilgiristores.in/csv-pipeline/products.csv"
    
    if [ ! -f "$PRODUCTS_CSV" ]; then
        echo -e "${RED}[ERROR]${NC} File 'products.csv' not found!"
        echo ""
        echo "The products.csv file is required to find the highest product_id."
        echo ""
        echo "Please follow these steps:"
        echo ""
        echo "1. Locate your products.csv file (it should contain existing products)"
        echo "2. Copy it to this directory:"
        echo "   ${YELLOW}cp /path/to/your/products.csv $PRODUCTS_CSV${NC}"
        echo ""
        echo "3. Run this command again"
        echo ""
        echo -n "Do you want to specify a custom path to products.csv? (y/n): "
        read -r USE_CUSTOM
        
        if [ "$USE_CUSTOM" = "y" ] || [ "$USE_CUSTOM" = "Y" ]; then
            echo -n "Enter full path to products.csv: "
            read -r CUSTOM_PATH
            
            if [ -f "$CUSTOM_PATH" ]; then
                echo ""
                echo -e "${YELLOW}[INFO]${NC} Copying $CUSTOM_PATH to $PRODUCTS_CSV..."
                cp "$CUSTOM_PATH" "$PRODUCTS_CSV"
                
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}[SUCCESS]${NC} File copied successfully!"
                    echo ""
                else
                    echo -e "${RED}[ERROR]${NC} Failed to copy file!"
                    return 1
                fi
            else
                echo -e "${RED}[ERROR]${NC} File '$CUSTOM_PATH' not found!"
                return 1
            fi
        else
            return 1
        fi
    fi
    
    echo "Analyzing: $PRODUCTS_CSV"
    echo ""
    
    # Get the highest product_id
    local MAX_ID=$(tail -n +2 "$PRODUCTS_CSV" | cut -d',' -f1 | sort -n | tail -1)
    
    if [ -z "$MAX_ID" ]; then
        echo -e "${RED}[ERROR]${NC} Could not find product_id values!"
        return 1
    fi
    
    # Count total rows
    local TOTAL_ROWS=$(tail -n +2 "$PRODUCTS_CSV" | wc -l)
    local NEXT_ID=$((MAX_ID + 1))
    
    echo "========================================"
    echo "RESULTS"
    echo "========================================"
    echo "Total products:      $TOTAL_ROWS"
    echo "Highest product_id:  $MAX_ID"
    echo "Next available ID:   $NEXT_ID"
    echo "========================================"
    echo ""
    
    # Update config.json
    if [ -f "config.json" ]; then
        echo -e "${YELLOW}[INFO]${NC} Updating config.json with next ID: $NEXT_ID"
        
        python3 -c "
import json
with open('config.json', 'r') as f:
    config = json.load(f)
if 'generated_columns' in config and 'product_id' in config['generated_columns']:
    old = config['generated_columns']['product_id'].get('start', 0)
    config['generated_columns']['product_id']['start'] = $NEXT_ID
    with open('config.json', 'w') as f:
        json.dump(config, f, indent=2)
    print(f'✓ Updated: {old} → $NEXT_ID')
else:
    print('ERROR: generated_columns.product_id not found in config.json')
"
        echo ""
        echo -e "${GREEN}[SUCCESS]${NC} Config updated! Next cleaning will start at ID $NEXT_ID"
    else
        echo -e "${YELLOW}[WARNING]${NC} config.json not found. Create it to enable auto-update."
    fi
    
    echo ""
}

# Function to show menu
show_menu() {
    echo "========================================"
    echo "         MAIN MENU                      "
    echo "========================================"
    echo ""
    echo "1. Clean CSV (Run Python script)"
    echo "2. Preview cleaned output"
    echo "3. Show statistics"
    echo "4. Get max product_id from products.csv"
    echo "5. Help"
    echo "0. Exit"
    echo ""
    echo "========================================"
    echo ""
    echo -n "Enter your choice [0-5]: "
}

# Function to show usage
show_usage() {
    echo "========================================"
    echo "    GENERIC CSV PIPELINE - USAGE       "
    echo "========================================"
    echo ""
    echo "INTERACTIVE MODE:"
    echo "  ./run.sh             # Launch interactive menu"
    echo ""
    echo "DIRECT COMMANDS:"
    echo "  ./run.sh clean       # Process CSV (paths from config.json)"
    echo "  ./run.sh preview     # Preview output file"
    echo "  ./run.sh stats       # Show statistics"
    echo "  ./run.sh maxid       # Get max product_id and update config"
    echo "  ./run.sh help        # Show this help message"
    echo ""
    echo "CONFIGURATION:"
    echo "  Edit config.json to set:"
    echo "  - Input/output file paths"
    echo "  - Column mappings"
    echo "  - Generated columns"
    echo "  - Filters and options"
    echo ""
}

# Interactive menu loop
interactive_menu() {
    while true; do
        display_header
        
        # Get and show current file info from config
        get_file_paths
        if [ $? -eq 0 ]; then
            echo "Configuration (from config.json):"
            echo "  Input:  $INPUT_FILE"
            echo "  Output: $OUTPUT_FILE"
        else
            echo "Configuration: Check config.json"
        fi
        echo ""
        
        show_menu
        read -r choice
        
        case $choice in
            1|clean)
                run_cleaning
                echo ""
                read -p "Press Enter to continue..."
                ;;
            2|preview)
                preview_output
                echo ""
                read -p "Press Enter to continue..."
                ;;
            3|stats)
                show_stats
                echo ""
                read -p "Press Enter to continue..."
                ;;
            4|maxid)
                get_max_product_id
                echo ""
                read -p "Press Enter to continue..."
                ;;
            5|help)
                display_header
                show_usage
                echo ""
                read -p "Press Enter to continue..."
                ;;
            0|exit|quit)
                echo ""
                echo "Thank you for using Alibaba CSV Pipeline!"
                exit 0
                ;;
            *)
                echo -e "${RED}[ERROR]${NC} Invalid choice! Please select 0-5."
                sleep 2
                ;;
        esac
    done
}

# Main program
main() {
    local command="${1:-interactive}"
    
    case "$command" in
        interactive)
            interactive_menu
            ;;
        clean|run)
            run_cleaning
            ;;
        preview|view)
            preview_output
            ;;
        stats|statistics)
            show_stats
            ;;
        maxid|getmax|max)
            get_max_product_id
            ;;
        help|--help|-h)
            show_usage
            ;;
        *)
            echo -e "${RED}[ERROR]${NC} Unknown command '$command'"
            echo ""
            show_usage
            exit 1
            ;;
    esac
}

# Run main program
if [ $# -eq 0 ]; then
    # No arguments - run interactive mode
    interactive_menu
else
    # Arguments provided - run direct command
    main "$@"
fi
