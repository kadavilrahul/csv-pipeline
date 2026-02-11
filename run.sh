#!/bin/bash

# Alibaba CSV Pipeline Runner
# Runs the Python cleaning script to transform alibaba.csv

# Configuration
INPUT_FILE="alibaba.csv"
OUTPUT_FILE="alibaba_cleaned.csv"
PYTHON_SCRIPT="clean_alibaba.py"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to display header
display_header() {
    clear
    echo "========================================"
    echo "   ALIBABA CSV CLEANING PIPELINE       "
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

# Function to show menu
show_menu() {
    echo "========================================"
    echo "         MAIN MENU                      "
    echo "========================================"
    echo ""
    echo "1. Clean CSV (Run Python script)"
    echo "2. Preview cleaned output"
    echo "3. Show statistics"
    echo "4. Help"
    echo "0. Exit"
    echo ""
    echo "========================================"
    echo ""
    echo -n "Enter your choice [0-4]: "
}

# Function to show usage
show_usage() {
    echo "========================================"
    echo "   ALIBABA CSV PIPELINE - USAGE        "
    echo "========================================"
    echo ""
    echo "INTERACTIVE MODE:"
    echo "  ./run.sh             # Launch interactive menu"
    echo ""
    echo "DIRECT COMMANDS:"
    echo "  ./run.sh clean       # Run cleaning process"
    echo "  ./run.sh preview     # Preview cleaned output"
    echo "  ./run.sh stats       # Show statistics"
    echo "  ./run.sh help        # Show this help message"
    echo ""
    echo "EXAMPLES:"
    echo "  ./run.sh             # Interactive menu"
    echo "  ./run.sh clean       # Run cleaning directly"
    echo "  ./run.sh preview     # Preview output"
    echo "  ./run.sh stats       # Show statistics"
    echo ""
}

# Interactive menu loop
interactive_menu() {
    while true; do
        display_header
        
        # Show current file info
        echo "Configuration:"
        echo "  Input:  $INPUT_FILE"
        echo "  Output: $OUTPUT_FILE"
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
            4|help)
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
                echo -e "${RED}[ERROR]${NC} Invalid choice! Please select 0-4."
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
