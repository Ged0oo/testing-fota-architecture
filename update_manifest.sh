#!/bin/bash

# Function to update the version and description in the manifest file for the given ECU directory
update_version() {
    ECU_DIR=$1
    
    # Extract the ECU ID from the directory name (e.g., "ecu_00_central" -> "00")
    ECU_ID=$(echo "$ECU_DIR" | grep -o -E 'ecu_[0-9]+' | cut -d'_' -f2)
    
    if [ -z "$ECU_ID" ]; then
        echo "Could not extract ECU ID from directory name: $ECU_DIR"
        return
    fi
    
    echo "Processing ECU ID: $ECU_ID from directory: $ECU_DIR"
    
    # Find the container directory within the ECU directory
    CONTAINER_DIR=$(find "./$ECU_DIR" -maxdepth 1 -type d | grep -v "^./$ECU_DIR$" | head -1)
    
    if [ -z "$CONTAINER_DIR" ]; then
        echo "No container directory found in $ECU_DIR"
        return
    fi
    
    echo "Found container directory: $CONTAINER_DIR"
    
    # Check for version.txt
    VERSION_FILE="$CONTAINER_DIR/version.txt"
    if [ -f "$VERSION_FILE" ]; then
        VERSION=$(cat "$VERSION_FILE")
        echo "Found version: $VERSION"
    else
        echo "No version.txt found in $CONTAINER_DIR"
        return
    fi
    
    # Check for description.txt
    DESCRIPTION_FILE="$CONTAINER_DIR/description.txt"
    if [ -f "$DESCRIPTION_FILE" ]; then
        DESCRIPTION=$(cat "$DESCRIPTION_FILE")
        echo "Found description: $DESCRIPTION"
    else
        # If no description file, keep the existing description
        DESCRIPTION=$(jq -r --arg ecuid "$ECU_ID" '.[] | select(.ecuid == $ecuid) | .description' mainfast.json)
        echo "No description.txt found, using existing description: $DESCRIPTION"
    fi
    
    # Use jq to update the version and description in the mainfast.json file
    jq --arg ecuid "$ECU_ID" --arg version "$VERSION" --arg desc "$DESCRIPTION" '
        map(if .ecuid == $ecuid then 
            .version = $version | 
            if $desc != "" then .description = $desc else . end 
        else . end)
    ' mainfast.json > temp.json && mv temp.json mainfast.json
    
    echo "Updated mainfast.json for ECU ID: $ECU_ID"
}

# Check if mainfast.json exists before proceeding
if [ ! -f "mainfast.json" ]; then
    echo "mainfast.json file not found! Aborting script."
    exit 1
fi

# If a specific ECU directory is provided as an argument, update only that one
if [ $# -eq 1 ]; then
    echo "Updating version for specified ECU directory: $1"
    update_version "$1"
else
    # Otherwise, loop through all ECU directories
    for dir in ecu_*; do
        if [ -d "$dir" ]; then
            echo "Updating version for ECU directory: $dir"
            update_version "$dir"
        else
            echo "Skipping non-directory: $dir"
        fi
    done
fi

echo "Manifest update completed."