#!/bin/bash

# archive_logs.sh - Interactive log archival script
# Archives selected log files with timestamps

# Directory configuration
ACTIVE_LOGS_DIR="hospital_data/active_logs"
ARCHIVED_LOGS_DIR="hospital_data/archived_logs"
HEART_ARCHIVE_DIR="${ARCHIVED_LOGS_DIR}/heart_data_archive"
TEMP_ARCHIVE_DIR="${ARCHIVED_LOGS_DIR}/temperature_data_archive"
WATER_ARCHIVE_DIR="${ARCHIVED_LOGS_DIR}/water_usage_data_archive"

# Log file names
HEART_LOG="heart_rate.log"
TEMP_LOG="temperature.log"
WATER_LOG="water_usage.log"

# Function to display menu and get user choice
display_menu() {
    echo "Select log to archive:"
    echo "1) Heart Rate"
    echo "2) Temperature"
    echo "3) Water Usage"
    echo -n "Enter choice (1-3): "
}

# Function to archive a log file
archive_log() {
    local log_file=$1
    local archive_dir=$2
    local log_name=$3
    local source_path="${ACTIVE_LOGS_DIR}/${log_file}"
    
    # Check if archive directory exists, create if not
    if [ ! -d "$archive_dir" ]; then
        echo "Creating archive directory: $archive_dir"
        mkdir -p "$archive_dir"
        if [ $? -ne 0 ]; then
            echo "Error: Failed to create archive directory."
            exit 1
        fi
    fi
    
    # Check if source log file exists
    if [ ! -f "$source_path" ]; then
        echo "Error: Log file '$source_path' does not exist."
        echo "Make sure the monitoring device is running and has generated logs."
        exit 1
    fi
    
    # Check if log file is empty
    if [ ! -s "$source_path" ]; then
        echo "Warning: Log file is empty. Nothing to archive."
        exit 0
    fi
    
    # Generate timestamp for archive filename
    timestamp=$(date +"%Y-%m-%d_%H:%M:%S")
    archive_filename="${log_name}_${timestamp}.log"
    archive_path="${archive_dir}/${archive_filename}"
    
    echo ""
    echo "Archiving ${log_file}..."
    
    # Move the log file to archive
    mv "$source_path" "$archive_path"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to move log file to archive."
        exit 1
    fi
    
    # Create new empty log file for continued monitoring
    touch "$source_path"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to create new log file."
        exit 1
    fi
    
    echo "Successfully archived to ${archive_path}"
    echo "New empty log file created at ${source_path}"
}

# Main script execution
display_menu
read choice

case $choice in
    1)
        archive_log "$HEART_LOG" "$HEART_ARCHIVE_DIR" "heart_rate"
        ;;
    2)
        archive_log "$TEMP_LOG" "$TEMP_ARCHIVE_DIR" "temperature"
        ;;
    3)
        archive_log "$WATER_LOG" "$WATER_ARCHIVE_DIR" "water_usage"
        ;;
    *)
        echo "Error: Invalid choice. Please enter 1, 2, or 3."
        exit 1
        ;;
esac

exit 0
