#!/bin/bash

echo "=== Testing CLI argument parsing ==="
echo "Argument 1: '$1'"
echo "Argument 2: '$2'"
echo "Argument 3: '$3'"
echo ""

new_item_text="$2"
new_item_url="$3"

echo "Text: '$new_item_text'"
echo "URL: '$new_item_url'"
echo ""

if [ -n "$new_item_url" ]; then
    new_item="{\"text\":\"$new_item_text\",\"url\":\"$new_item_url\"}"
    echo "Creating item WITH URL"
else
    new_item="{\"text\":\"$new_item_text\"}"
    echo "Creating item WITHOUT URL"
fi

echo ""
echo "Generated JSON:"
echo "$new_item"
