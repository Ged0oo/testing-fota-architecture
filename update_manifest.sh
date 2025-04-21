#!/bin/bash

# Ensure an argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <ecu_directory_name>"
    exit 1
fi

ECU_DIR="$1"
MANIFEST="mainfast.json"

# Extract ecuid (assumes format: ecu_XX_name)
ECUID=$(echo "$ECU_DIR" | cut -d'_' -f2)

# Backup the original manifest
cp "$MANIFEST" "${MANIFEST}.bak"

# Use jq to increment the version of the matching ecuid
UPDATED=$(jq --arg ecuid "$ECUID" '
    map(
        if .ecuid == $ecuid then
            .version = (
                (.version | split(".") | 
                if length == 2 then
                    "\((.[0]|tonumber)).\((.[1]|tonumber) + 1)"
                else
                    "1.0"
                end)
            )
        else
            .
        end
    )' "$MANIFEST")

# Save the updated content back
echo "$UPDATED" > "$MANIFEST"

echo "Updated ecuid $ECUID version in $MANIFEST"
