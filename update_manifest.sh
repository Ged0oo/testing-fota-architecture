#!/bin/bash

# Ensure an ECU ID is provided
if [ -z "$1" ]; then
    echo "No ECU ID provided!"
    exit 1
fi

ECU_ID=$1
MANIFEST_FILE="mainfast.json"
TEMP_FILE=$(mktemp)

# Extract current version of the ECU from the manifest
current_version=$(jq --arg ecuId "$ECU_ID" '.[] | select(.ecuid == $ecuId) | .version' $MANIFEST_FILE)

# Check if the ECU ID exists in the manifest
if [ "$current_version" == "null" ]; then
    echo "ECU ID $ECU_ID not found in $MANIFEST_FILE!"
    exit 1
fi

# Read current version and increment it (assuming version format is X.Y)
IFS='.' read -r major minor patch <<< "$current_version"
new_version="$major.$((minor + 1))"  # Increment the minor version, no patch update

# Update the version and description in the manifest file
jq --arg ecuId "$ECU_ID" --arg newVersion "$new_version" \
   'map(if .ecuid == $ecuId then .version = $newVersion else . end)' $MANIFEST_FILE > $TEMP_FILE && mv $TEMP_FILE $MANIFEST_FILE

echo "Updated $ECU_ID version from $current_version to $new_version in $MANIFEST_FILE"
