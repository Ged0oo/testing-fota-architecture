#!/bin/bash

# Directory to watch
WATCH_DIR="/home/nagy/Desktop/grad/Embedded/jenkins"

# Log file
LOG_FILE="$WATCH_DIR/file_watcher.log"

echo "Starting file watcher for $WATCH_DIR" > $LOG_FILE
echo "Timestamp: $(date)" >> $LOG_FILE

# Function to update manifest when changes are detected
update_manifest() {
    echo "Change detected at $(date)" >> $LOG_FILE
    
    cd "$WATCH_DIR"
    
    # Run the update script for all ECU directories
    ./update_manifest.sh >> $LOG_FILE 2>&1
    
    echo "Manifest update completed" >> $LOG_FILE
    echo "----------------------------" >> $LOG_FILE
}

# Use inotifywait to monitor for changes
# First, make sure inotify-tools is installed
if ! command -v inotifywait &> /dev/null; then
    echo "inotifywait not found. Please install inotify-tools package." >> $LOG_FILE
    echo "Run: sudo apt-get install inotify-tools" >> $LOG_FILE
    exit 1
fi

# Monitor for changes in version.txt and description.txt files
echo "Watching for changes in ECU directories..." >> $LOG_FILE

while true; do
    # Watch for changes in any version.txt or description.txt file
    inotifywait -r -e modify,create "$WATCH_DIR/ecu_"*"/*/version.txt" "$WATCH_DIR/ecu_"*"/*/description.txt" 2>/dev/null
    
    # Wait a moment for any additional changes
    sleep 1
    
    # Update the manifest
    update_manifest
done
