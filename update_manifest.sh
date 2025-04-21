#!/bin/bash

# Function to update the version in the manifest file for the given ECU directory
update_version() {
    ECU_ID=$1
    ECU_DIR="./${ECU_ID}/afs_container"
    VERSION_FILE="${ECU_DIR}/version.txt"

    if [ -f "$VERSION_FILE" ]; then
        # Read version from version.txt
        VERSION=$(cat "$VERSION_FILE")
        # Update mainfast.json with the new version
        jq --arg ecuid "$ECU_ID" --arg version "$VERSION" \
            '(.[] | select(.ecuid == $ecuid) | .version) = $version' \
            mainfast.json > temp.json && mv temp.json mainfast.json
        echo "Version for ECU $ECU_ID updated to $VERSION in mainfast.json."
    else
        echo "Version file for $ECU_ID not found!"
        exit 1
    fi
}

# List all ECU directories and update the version in the manifest accordingly
for dir in ecu_*; do
    if [ -d "$dir" ]; then
        update_version "$dir"
    fi
done
