#!/usr/bin/env bash

echo "FaviconBuster - Universal Edition"
echo "================================="
echo ""

# Detect operating system
OS_TYPE=$(uname -s)
echo "Detected OS: $OS_TYPE"
echo ""

# Set search paths based on OS
search_paths=()

case "$OS_TYPE" in
    Darwin*)
        echo "Running in macOS mode..."
        echo ""
        search_paths+=(
            "$HOME/Library/Application Support"
            "$HOME/Library/Safari"
        )
        ;;
    Linux*)
        echo "Running in Linux mode..."
        echo ""
        search_paths+=(
            "$HOME/.config"
            "$HOME/.cache"
            "$HOME/.var/app"
            "$HOME/snap"
            "$HOME/.mozilla"
            "$HOME/.local/share"
        )
        ;;
    *)
        echo "[ERROR] Unsupported operating system: $OS_TYPE"
        echo "This script supports macOS (Darwin) and Linux only."
        exit 1
        ;;
esac

echo "Searching for browser favicon databases..."
echo ""

sqlite_files=()
total_found=0

# Search for Chromium databases (named "Favicons")
for search_path in "${search_paths[@]}"; do
    if [ -d "$search_path" ]; then
        while IFS= read -r file; do
            ((total_found++))
            sqlite_files+=("$file")
        done < <(find "$search_path" -type f -iname "Favicons" 2>/dev/null)
    fi
done

# Search for Firefox databases (named "favicons.sqlite")
for search_path in "${search_paths[@]}"; do
    if [ -d "$search_path" ]; then
        while IFS= read -r file; do
            ((total_found++))
            sqlite_files+=("$file")
        done < <(find "$search_path" -type f -iname "favicons.sqlite" 2>/dev/null)
    fi
done

# Search for Safari databases (named "favicons.db") - macOS only
if [ "$OS_TYPE" = "Darwin" ]; then
    for search_path in "${search_paths[@]}"; do
        if [ -d "$search_path" ]; then
            while IFS= read -r file; do
                ((total_found++))
                sqlite_files+=("$file")
            done < <(find "$search_path" -type f -path "*/Safari/Favicon Cache/favicons.db" 2>/dev/null)
        fi
    done
fi

echo "Found $total_found favicon database(s)"
echo ""

if [ $total_found -eq 0 ]; then
    echo "[WARNING] No favicon databases found. Make sure you have supported browsers installed:"
    echo "   - Chromium-based: Chrome, Brave, Edge, Vivaldi, Opera"
    echo "   - Firefox-based: Firefox, Tor Browser"
    echo "   - Safari (macOS only)"
    exit 0
fi

# Validate SQLite files
echo "Validating SQLite3 databases..."
echo ""

valid_files=()
valid_count=0

for file in "${sqlite_files[@]}"; do
    echo "Checking: $file"

    if file "$file" | grep -qi "sqlite"; then
        ((valid_count++))
        echo "   [OK] Valid SQLite3 file"
        valid_files+=("$file")
    else
        echo "   [SKIP] Not a SQLite3 file"
    fi
    echo ""
done

echo "============================================================="
echo "Validation Summary:"
echo "   Total files found: $total_found"
echo "   Valid SQLite3 files: $valid_count"
echo "============================================================="
echo ""

if [ $valid_count -eq 0 ]; then
    echo "[WARNING] No valid SQLite3 favicon databases found."
    exit 0
fi

# Check database schema and categorize by browser type
echo "Checking database schemas and detecting browser types..."
echo ""

chromium_files=()
firefox_files=()
safari_files=()

for file in "${valid_files[@]}"; do
    echo "Analyzing: $file"

    # Check for Chromium schema (favicons + icon_mapping tables)
    has_chromium_favicons=$(sqlite3 "$file" "SELECT name FROM sqlite_master WHERE type='table' AND name='favicons';" 2>/dev/null)
    has_chromium_icon_mapping=$(sqlite3 "$file" "SELECT name FROM sqlite_master WHERE type='table' AND name='icon_mapping';" 2>/dev/null)

    # Check for Firefox schema (moz_icons + moz_pages_w_icons tables)
    has_firefox_icons=$(sqlite3 "$file" "SELECT name FROM sqlite_master WHERE type='table' AND name='moz_icons';" 2>/dev/null)
    has_firefox_pages=$(sqlite3 "$file" "SELECT name FROM sqlite_master WHERE type='table' AND name='moz_pages_w_icons';" 2>/dev/null)

    # Check for Safari schema (icon_info + page_url + rejected_resources tables)
    has_safari_icon_info=$(sqlite3 "$file" "SELECT name FROM sqlite_master WHERE type='table' AND name='icon_info';" 2>/dev/null)
    has_safari_page_url=$(sqlite3 "$file" "SELECT name FROM sqlite_master WHERE type='table' AND name='page_url';" 2>/dev/null)
    has_safari_rejected=$(sqlite3 "$file" "SELECT name FROM sqlite_master WHERE type='table' AND name='rejected_resources';" 2>/dev/null)

    if [ -n "$has_chromium_favicons" ] && [ -n "$has_chromium_icon_mapping" ]; then
        # Verify columns exist
        has_url=$(sqlite3 "$file" "PRAGMA table_info(favicons);" 2>/dev/null | grep -i "url")
        has_page_url=$(sqlite3 "$file" "PRAGMA table_info(icon_mapping);" 2>/dev/null | grep -i "page_url")

        if [ -n "$has_url" ] && [ -n "$has_page_url" ]; then
            echo "   [OK] Chromium database (favicons.url + icon_mapping.page_url)"
            chromium_files+=("$file")
        else
            echo "   [WARN] Chromium schema incomplete"
        fi
    elif [ -n "$has_firefox_icons" ] && [ -n "$has_firefox_pages" ]; then
        # Verify columns exist
        has_icon_url=$(sqlite3 "$file" "PRAGMA table_info(moz_icons);" 2>/dev/null | grep -i "icon_url")
        has_page_url_ff=$(sqlite3 "$file" "PRAGMA table_info(moz_pages_w_icons);" 2>/dev/null | grep -i "page_url")

        if [ -n "$has_icon_url" ] && [ -n "$has_page_url_ff" ]; then
            echo "   [OK] Firefox database (moz_icons.icon_url + moz_pages_w_icons.page_url)"
            firefox_files+=("$file")
        else
            echo "   [WARN] Firefox schema incomplete"
        fi
    elif [ -n "$has_safari_icon_info" ] && [ -n "$has_safari_page_url" ] && [ -n "$has_safari_rejected" ]; then
        # Verify columns exist
        has_icon_info_url=$(sqlite3 "$file" "PRAGMA table_info(icon_info);" 2>/dev/null | grep -i "url")
        has_page_url_safari=$(sqlite3 "$file" "PRAGMA table_info(page_url);" 2>/dev/null | grep -i "url")
        has_rejected_page=$(sqlite3 "$file" "PRAGMA table_info(rejected_resources);" 2>/dev/null | grep -i "page_url")
        has_rejected_icon=$(sqlite3 "$file" "PRAGMA table_info(rejected_resources);" 2>/dev/null | grep -i "icon_url")

        if [ -n "$has_icon_info_url" ] && [ -n "$has_page_url_safari" ] && [ -n "$has_rejected_page" ] && [ -n "$has_rejected_icon" ]; then
            echo "   [OK] Safari database (icon_info.url + page_url.url + rejected_resources)"
            safari_files+=("$file")
        else
            echo "   [WARN] Safari schema incomplete"
        fi
    else
        echo "   [WARN] Unknown or incomplete database schema"
    fi
    echo ""
done

total_valid=$((${#chromium_files[@]} + ${#firefox_files[@]} + ${#safari_files[@]}))

if [ $total_valid -eq 0 ]; then
    echo "[ERROR] No databases with valid schema found."
    exit 1
fi

echo "============================================================="
echo "Schema Check Summary:"
echo "   Chromium databases: ${#chromium_files[@]}"
echo "   Firefox databases: ${#firefox_files[@]}"
echo "   Safari databases: ${#safari_files[@]}"
echo "   Total valid: $total_valid"
echo "============================================================="
echo ""

# Extract all URLs from valid databases
echo "Extracting URLs from databases..."
echo ""

all_urls=()

# Process Chromium databases
if [ ${#chromium_files[@]} -gt 0 ]; then
    echo "[CHROMIUM] Processing Chromium databases..."
    echo ""

    for file in "${chromium_files[@]}"; do
        echo "Extracting from: $file"

        # Extract URLs from favicons table (only those starting with "http")
        url_count=0
        while IFS= read -r url; do
            [ -n "$url" ] && all_urls+=("$url") && ((url_count++))
        done < <(sqlite3 "$file" "SELECT url FROM favicons WHERE url LIKE 'http%';" 2>/dev/null)
        echo "   Found $url_count URLs in favicons table"

        # Extract page_urls from icon_mapping table (only those starting with "http")
        page_url_count=0
        while IFS= read -r page_url; do
            [ -n "$page_url" ] && all_urls+=("$page_url") && ((page_url_count++))
        done < <(sqlite3 "$file" "SELECT page_url FROM icon_mapping WHERE page_url LIKE 'http%';" 2>/dev/null)
        echo "   Found $page_url_count URLs in icon_mapping table"
        echo ""
    done
fi

# Process Firefox databases
if [ ${#firefox_files[@]} -gt 0 ]; then
    echo "[FIREFOX] Processing Firefox databases..."
    echo ""

    for file in "${firefox_files[@]}"; do
        echo "Extracting from: $file"

        # Extract URLs from moz_icons table (only those starting with "http")
        icon_url_count=0
        while IFS= read -r url; do
            [ -n "$url" ] && all_urls+=("$url") && ((icon_url_count++))
        done < <(sqlite3 "$file" "SELECT icon_url FROM moz_icons WHERE icon_url LIKE 'http%';" 2>/dev/null)
        echo "   Found $icon_url_count URLs in moz_icons table"

        # Extract page_urls from moz_pages_w_icons table (only those starting with "http")
        page_url_count=0
        while IFS= read -r page_url; do
            [ -n "$page_url" ] && all_urls+=("$page_url") && ((page_url_count++))
        done < <(sqlite3 "$file" "SELECT page_url FROM moz_pages_w_icons WHERE page_url LIKE 'http%';" 2>/dev/null)
        echo "   Found $page_url_count URLs in moz_pages_w_icons table"
        echo ""
    done
fi

# Process Safari databases
if [ ${#safari_files[@]} -gt 0 ]; then
    echo "[SAFARI] Processing Safari databases..."
    echo ""

    for file in "${safari_files[@]}"; do
        echo "Extracting from: $file"

        # Extract URLs from icon_info table (only those starting with "http")
        icon_info_count=0
        while IFS= read -r url; do
            [ -n "$url" ] && all_urls+=("$url") && ((icon_info_count++))
        done < <(sqlite3 "$file" "SELECT url FROM icon_info WHERE url LIKE 'http%';" 2>/dev/null)
        echo "   Found $icon_info_count URLs in icon_info table"

        # Extract URLs from page_url table (only those starting with "http")
        page_url_count=0
        while IFS= read -r url; do
            [ -n "$url" ] && all_urls+=("$url") && ((page_url_count++))
        done < <(sqlite3 "$file" "SELECT url FROM page_url WHERE url LIKE 'http%';" 2>/dev/null)
        echo "   Found $page_url_count URLs in page_url table"

        # Extract page_url from rejected_resources table (only those starting with "http")
        rejected_page_count=0
        while IFS= read -r url; do
            [ -n "$url" ] && all_urls+=("$url") && ((rejected_page_count++))
        done < <(sqlite3 "$file" "SELECT page_url FROM rejected_resources WHERE page_url LIKE 'http%';" 2>/dev/null)
        echo "   Found $rejected_page_count URLs in rejected_resources.page_url"

        # Extract icon_url from rejected_resources table (only those starting with "http")
        rejected_icon_count=0
        while IFS= read -r url; do
            [ -n "$url" ] && all_urls+=("$url") && ((rejected_icon_count++))
        done < <(sqlite3 "$file" "SELECT icon_url FROM rejected_resources WHERE icon_url LIKE 'http%';" 2>/dev/null)
        echo "   Found $rejected_icon_count URLs in rejected_resources.icon_url"
        echo ""
    done
fi

if [ ${#all_urls[@]} -eq 0 ]; then
    echo "[WARNING] No URLs found in any database."
    exit 0
fi

# Sort and remove duplicates using compatible method for older bash
echo "Sorting and removing duplicates..."
temp_file=$(mktemp)
printf '%s\n' "${all_urls[@]}" | sort -u > "$temp_file"

# Read back into array
all_urls=()
while IFS= read -r line; do
    all_urls+=("$line")
done < "$temp_file"
rm "$temp_file"

echo "[OK] Processing complete!"
echo "   Total unique URLs collected: ${#all_urls[@]}"
echo ""

# Save to file with timestamp
timestamp=$(date +"%Y%m%d_%H%M%S")
output_file="buster_${timestamp}.txt"

echo "Saving URLs to file..."
printf '%s\n' "${all_urls[@]}" > "$output_file"
echo "[OK] Saved ${#all_urls[@]} unique URLs to: $output_file"
echo ""
echo "Done!"