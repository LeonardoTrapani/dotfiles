#!/bin/bash
# Fix Python treesitter query issue with except*
# The query includes "except*" but the parser doesn't support it yet

QUERY_FILE="$HOME/.local/share/nvim/lazy/nvim-treesitter/queries/python/highlights.scm"

if [ -f "$QUERY_FILE" ]; then
    # Check if except* is in the file
    if grep -q '"except\*"' "$QUERY_FILE"; then
        echo "Fixing Python treesitter query..."
        # Comment out the except* line
        sed -i 's/"except\*"/; "except*" ; Not supported by parser yet/' "$QUERY_FILE"
        echo "Fixed!"
    else
        echo "Query already fixed or doesn't contain except*"
    fi
else
    echo "Query file not found: $QUERY_FILE"
fi