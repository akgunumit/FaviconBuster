#!/usr/bin/env bash

echo "🔍 Searching for Favicons files in Application Support..."
echo ""

temp_files=()
valid_files=()
total_found=0
sqlite_count=0
valid_count=0

# First pass: Find files and check if they're SQLite
while IFS= read -r file; do
    ((total_found++))
    echo "📄 Found: $file"

    if file "$file" | grep -qi "sqlite"; then
        ((sqlite_count++))
        echo "   ✅   Valid SQLite3 file"
        temp_files+=("$file")
    else
        echo "   ❌ Not a SQLite3 file"
    fi
    echo ""
done < <(find "$HOME/Library/Application Support/" -type f -iname "Favicons" 2>/dev/null)

echo "═══════════════════════════════════════════════════════════"
echo "📊 First Pass Summary:"
echo "   Total files found: $total_found"
echo "   SQLite3 files: $sqlite_count"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Second pass: Validate database schema
if [ ${#temp_files[@]} -gt 0 ]; then
    echo "🔎 Validating database schemas..."
    echo ""

    for file in "${temp_files[@]}"; do
        echo "🗄️  Checking: $file"

        # Try to open the database
        if ! sqlite3 "$file" "SELECT 1;" &>/dev/null; then
            echo "   ❌ Cannot open database (locked or corrupted)"
            echo ""
            continue
        fi

        # Check for favicons table and url column
        favicons_check=$(sqlite3 "$file" "SELECT sql FROM sqlite_master WHERE type='table' AND name='favicons';" 2>/dev/null)
        if [ -z "$favicons_check" ]; then
            echo "   ❌ Missing 'favicons' table"
            echo ""
            continue
        fi

        if ! echo "$favicons_check" | grep -qi "url"; then
            echo "   ❌ 'favicons' table missing 'url' column"
            echo ""
            continue
        fi
        echo "   ✅  Found 'favicons' table with 'url' column"

        # Check for icon_mapping table and page_url column
        icon_mapping_check=$(sqlite3 "$file" "SELECT sql FROM sqlite_master WHERE type='table' AND name='icon_mapping';" 2>/dev/null)
        if [ -z "$icon_mapping_check" ]; then
            echo "   ❌ Missing 'icon_mapping' table"
            echo ""
            continue
        fi

        if ! echo "$icon_mapping_check" | grep -qi "page_url"; then
            echo "   ❌ 'icon_mapping' table missing 'page_url' column"
            echo ""
            continue
        fi
        echo "   ✅  Found 'icon_mapping' table with 'page_url' column"

        # All checks passed
        ((valid_count++))
        valid_files+=("$file")
        echo "   ✨ Database structure validated!"
        echo ""
    done
fi

echo "═══════════════════════════════════════════════════════════"
echo "📊 Final Summary:"
echo "   Total files found: $total_found"
echo "   SQLite3 files: $sqlite_count"
echo "   Valid databases: $valid_count"
echo "═══════════════════════════════════════════════════════════"

if [ ${#valid_files[@]} -eq 0 ]; then
    echo ""
    echo "⚠️  No valid Favicons databases found."
    exit 1
fi

echo ""
echo "✨ Valid Favicons databases ready for processing:"
printf '   %s\n' "${valid_files[@]}"
echo ""

# Extract all URLs from valid databases
echo "🔗 Extracting URLs from databases..."
echo ""

all_urls=()

for file in "${valid_files[@]}"; do
    echo "📥 Extracting from: $file"

    # Extract URLs from favicons table
    url_count=0
    while IFS= read -r url; do
        [ -n "$url" ] && all_urls+=("$url") && ((url_count++))
    done < <(sqlite3 "$file" "SELECT url FROM favicons WHERE url LIKE 'http%';" 2>/dev/null)
    echo "   Found $url_count URLs in favicons table"

    # Extract page_urls from icon_mapping table
    page_url_count=0
    while IFS= read -r page_url; do
        [ -n "$page_url" ] && all_urls+=("$page_url") && ((page_url_count++))
    done < <(sqlite3 "$file" "SELECT page_url FROM icon_mapping WHERE page_url LIKE 'http%';" 2>/dev/null)
    echo "   Found $page_url_count URLs in icon_mapping table"
    echo ""
done

echo "🔄 Sorting and removing duplicates..."
# Sort and remove duplicates
sorted_urls=()
while IFS= read -r url; do
    sorted_urls+=("$url")
done < <(printf '%s\n' "${all_urls[@]}" | sort -u)
all_urls=("${sorted_urls[@]}")

echo "✅  Processing complete!"
echo "   Total unique URLs collected: ${#all_urls[@]}"
echo ""

# Save to file with timestamp
timestamp=$(date +"%Y%m%d_%H%M%S")
output_file="buster_${timestamp}.txt"

echo "💾 Saving URLs to file..."
printf '%s\n' "${all_urls[@]}" > "$output_file"
echo "✅ Saved ${#all_urls[@]} unique URLs to: $output_file"