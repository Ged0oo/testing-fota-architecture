#!/bin/bash

# Function to update the version in the manifest file for the given ECU directory
update_version() {
    ECU_ID=$1
    VERSION=""

    # Iterate through possible container directories for version.txt
    for container in afs_container front_container rear_container motorcontrol_container; do
        VERSION_FILE="./${ECU_ID}/${container}/version.txt"
        
        echo "Checking for version file at: $VERSION_FILE"
        
        if [ -f "$VERSION_FILE" ]; then
            VERSION=$(cat "$VERSION_FILE")
            echo "Found version $VERSION in $container for ECU $ECU_ID"
            break
        fi
    done

    # If version is found, update mainfast.json
    if [ -n "$VERSION" ]; then
        echo "Version for ECU $ECU_ID: $VERSION"
        
        
        # Use jq to update the version in the mainfast.json file
        jq --arg ecuid "$ECU_ID" --arg version "$VERSION" \
            '(.[] | select(.ecuid == $ecuid) | .version) = $version' \
            mainfast.json > temp.json && mv temp.json mainfast.json

    else
        echo "No version file found for ECU $ECU_ID! Skipping update."
    fi
}

# Check if mainfast.json exists before proceeding
if [ ! -f "mainfast.json" ]; then
    echo "mainfast.json file not found! Aborting script."
    exit 1
fi

# Loop through all ECU directories and update the version in the manifest accordingly
for dir in ecu_*; do
    if [ -d "$dir" ]; then
        echo "Updating version for ECU directory: $dir"
        update_version "$dir"
    else
        echo "Skipping non-directory: $dir"
    fi
done
