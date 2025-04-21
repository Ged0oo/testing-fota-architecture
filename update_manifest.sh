#!/bin/bash

# Function to update the version and description in the manifest file for the given ECU directory
update_version() {
    ECU_DIR=$1
    
    # Extract the ECU ID more reliably using parameter expansion
    ECU_ID=$(basename "$ECU_DIR" | sed -n 's/ecu_$$[0-9]\+$$.*/\1/p')
    
    if [ -z "$ECU_ID" ]; then
        echo "Could not extract ECU ID from directory name: $ECU_DIR"
        return 1
    fi
    
    echo "Processing ECU ID: $ECU_ID from directory: $ECU_DIR"
    
    # Find the container directory more efficiently
    CONTAINER_DIR=$(find "./$ECU_DIR" -maxdepth 1 -type d -not -name "$ECU_DIR" | head -1)
    
    if [ -z "$CONTAINER_DIR" ]; then
        echo "No container directory found in $ECU_DIR"
        return 1
    fi
    
    echo "Found container directory: $CONTAINER_DIR"
    
    # Check for version.txt
    VERSION_FILE="$CONTAINER_DIR/version.txt"
    if [ -f "$VERSION_FILE" ]; then
        VERSION=$(cat "$VERSION_FILE")
        echo "Found version: $VERSION"
    else
        echo "No version.txt found in $CONTAINER_DIR"
        return 1
    fi
    
    # Check for description.txt
    DESCRIPTION_FILE="$CONTAINER_DIR/description.txt"
    if [ -f "$DESCRIPTION_FILE" ]; then
        DESCRIPTION=$(cat "$DESCRIPTION_FILE")
        echo "Found description: $DESCRIPTION"
    else
        # If no description file, keep the existing description
        DESCRIPTION=$(jq -r --arg ecuid "$ECU_ID" '.[] | select(.ecuid == $ecuid) | .description // "No description available"' mainfast.json)
        echo "No description.txt found, using existing description: $DESCRIPTION"
    fi
    
    # Create a backup of the manifest file
    cp mainfast.json mainfast.json.bak
    
    # Use jq to update the version and description in the mainfast.json file
    jq --arg ecuid "$ECU_ID" --arg version "$VERSION" --arg desc "$DESCRIPTION" '
        map(if .ecuid == $ecuid then 
            .version = $version | 
            if $desc != "" then .description = $desc else . end 
        else . end)
    ' mainfast.json > temp.json && mv temp.json mainfast.json
    
    echo "Updated mainfast.json for ECU ID: $ECU_ID"
    return 0
}

# Check if mainfast.json exists before proceeding
if [ ! -f "mainfast.json" ]; then
    echo "mainfast.json file not found! Creating empty manifest."
    echo '[]' > mainfast.json
fi

# Track if any updates were made
UPDATES_MADE=0

# If a specific ECU directory is provided as an argument, update only that one
if [ $# -eq 1 ]; then
    echo "Updating version for specified ECU directory: $1"
    if update_version "$1"; then
        UPDATES_MADE=1
    fi
else
    # Otherwise, loop through all ECU directories
    for dir in ecu_*; do
        if [ -d "$dir" ]; then
            echo "Updating version for ECU directory: $dir"
            if update_version "$dir"; then
                UPDATES_MADE=1
            fi
        else
            echo "Skipping non-directory: $dir"
        fi
    done
fi

if [ $UPDATES_MADE -eq 1 ]; then
    echo "Manifest update completed with changes."
else
    echo "Manifest update completed. No changes were made."
fi

exit 0