#!/bin/bash

# Function to update the version in the manifest file for the given ECU directory
update_version() {
    ECU_ID=$1
    VERSION=""
    
    # Check different subdirectories for the version.txt file
    for container in afs_container front_container rear_container motorcontrol_container; do
        VERSION_FILE="./${ECU_ID}/${container}/version.txt"
        if [ -f "$VERSION_FILE" ]; then
            VERSION=$(cat "$VERSION_FILE")
            echo "Found version $VERSION in $container for ECU $ECU_ID"
            break
        fi
    done

    # Check if we found a version.txt file
    if [ -n "$VERSION" ]; then
        # Update mainfast.json with the new version
        jq --arg ecuid "$ECU_ID" --arg version "$VERSION" \
            '(.[] | select(.ecuid == $ecuid) | .version) = $version' \
            mainfast.json > temp.json && mv temp.json mainfast.json
        echo "Version for ECU $ECU_ID updated to $VERSION in mainfast.json."
    else
        echo "No version file found for $ECU_ID! Skipping update."
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
        update_version "$dir"
    fi
done
