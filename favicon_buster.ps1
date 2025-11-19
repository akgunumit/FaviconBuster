# FaviconBuster - Windows Edition
# PowerShell script to extract URLs from browser favicon databases

Write-Host "FaviconBuster - Windows Edition"
Write-Host "==============================="
Write-Host ""

# Check if sqlite3.exe is available
$sqlite3Path = $null

# Check in current directory
if (Test-Path ".\sqlite3.exe") {
    $sqlite3Path = ".\sqlite3.exe"
}
# Check in PATH
elseif (Get-Command sqlite3.exe -ErrorAction SilentlyContinue) {
    $sqlite3Path = "sqlite3.exe"
}
else {
    Write-Host "[ERROR] sqlite3.exe not found!"
    Write-Host ""
    Write-Host "Please download sqlite3.exe from https://www.sqlite.org/download.html"
    Write-Host "Place it in the same directory as this script or add it to your PATH."
    Write-Host ""
    Write-Host "Windows downloads are in the 'Precompiled Binaries for Windows' section."
    exit 1
}

Write-Host "Using SQLite: $sqlite3Path"
Write-Host ""

# Define search paths for Windows browsers (parent directories)
$searchPaths = @(
    "$env:LOCALAPPDATA",
    "$env:APPDATA",
    "$env:USERPROFILE\Desktop"
)

Write-Host "Searching for browser favicon databases..."
Write-Host ""

$sqliteFiles = @()

# Search for Chromium databases (named "Favicons")
foreach ($searchPath in $searchPaths) {
    if (Test-Path $searchPath) {
        $files = Get-ChildItem -Path $searchPath -Filter "Favicons" -Recurse -ErrorAction SilentlyContinue -File
        foreach ($file in $files) {
            $sqliteFiles += $file.FullName
        }
    }
}

# Search for Firefox databases (named "favicons.sqlite")
foreach ($searchPath in $searchPaths) {
    if (Test-Path $searchPath) {
        $files = Get-ChildItem -Path $searchPath -Filter "favicons.sqlite" -Recurse -ErrorAction SilentlyContinue -File
        foreach ($file in $files) {
            $sqliteFiles += $file.FullName
        }
    }
}

$totalFound = $sqliteFiles.Count
Write-Host "Found $totalFound favicon database(s)"
Write-Host ""

if ($totalFound -eq 0) {
    Write-Host "[WARNING] No favicon databases found. Make sure you have supported browsers installed:"
    Write-Host "   - Chromium-based: Chrome, Brave, Edge, Vivaldi, Opera"
    Write-Host "   - Firefox-based: Firefox, Tor Browser"
    exit 0
}

# Validate SQLite files
Write-Host "Validating SQLite3 databases..."
Write-Host ""

$validFiles = @()

foreach ($file in $sqliteFiles) {
    Write-Host "Checking: $file"

    # Try to open the database and check if it's valid SQLite
    try {
        $testQuery = "SELECT name FROM sqlite_master LIMIT 1;"
        $result = & $sqlite3Path $file $testQuery 2>&1

        if ($LASTEXITCODE -eq 0) {
            Write-Host "   [OK] Valid SQLite3 file"
            $validFiles += $file
        }
        else {
            Write-Host "   [SKIP] Not a valid SQLite3 file"
        }
    }
    catch {
        Write-Host "   [SKIP] Not a valid SQLite3 file"
    }
    Write-Host ""
}

Write-Host "============================================================="
Write-Host "Validation Summary:"
Write-Host "   Total files found: $totalFound"
Write-Host "   Valid SQLite3 files: $($validFiles.Count)"
Write-Host "============================================================="
Write-Host ""

if ($validFiles.Count -eq 0) {
    Write-Host "[WARNING] No valid SQLite3 favicon databases found."
    exit 0
}

# Check database schema and categorize by browser type
Write-Host "Checking database schemas and detecting browser types..."
Write-Host ""

$chromiumFiles = @()
$firefoxFiles = @()

foreach ($file in $validFiles) {
    Write-Host "Analyzing: $file"

    # Check for Chromium schema (favicons + icon_mapping tables)
    $chromiumFavicons = & $sqlite3Path $file "SELECT name FROM sqlite_master WHERE type='table' AND name='favicons';" 2>$null
    $chromiumIconMapping = & $sqlite3Path $file "SELECT name FROM sqlite_master WHERE type='table' AND name='icon_mapping';" 2>$null

    # Check for Firefox schema (moz_icons + moz_pages_w_icons tables)
    $firefoxIcons = & $sqlite3Path $file "SELECT name FROM sqlite_master WHERE type='table' AND name='moz_icons';" 2>$null
    $firefoxPages = & $sqlite3Path $file "SELECT name FROM sqlite_master WHERE type='table' AND name='moz_pages_w_icons';" 2>$null

    if ($chromiumFavicons -and $chromiumIconMapping) {
        # Verify columns exist
        $hasUrl = & $sqlite3Path $file "PRAGMA table_info(favicons);" 2>$null | Select-String -Pattern "url" -Quiet
        $hasPageUrl = & $sqlite3Path $file "PRAGMA table_info(icon_mapping);" 2>$null | Select-String -Pattern "page_url" -Quiet

        if ($hasUrl -and $hasPageUrl) {
            Write-Host "   [OK] Chromium database (favicons.url + icon_mapping.page_url)"
            $chromiumFiles += $file
        }
        else {
            Write-Host "   [WARN] Chromium schema incomplete"
        }
    }
    elseif ($firefoxIcons -and $firefoxPages) {
        # Verify columns exist
        $hasIconUrl = & $sqlite3Path $file "PRAGMA table_info(moz_icons);" 2>$null | Select-String -Pattern "icon_url" -Quiet
        $hasPageUrlFF = & $sqlite3Path $file "PRAGMA table_info(moz_pages_w_icons);" 2>$null | Select-String -Pattern "page_url" -Quiet

        if ($hasIconUrl -and $hasPageUrlFF) {
            Write-Host "   [OK] Firefox database (moz_icons.icon_url + moz_pages_w_icons.page_url)"
            $firefoxFiles += $file
        }
        else {
            Write-Host "   [WARN] Firefox schema incomplete"
        }
    }
    else {
        Write-Host "   [WARN] Unknown or incomplete database schema"
    }
    Write-Host ""
}

$totalValid = $chromiumFiles.Count + $firefoxFiles.Count

if ($totalValid -eq 0) {
    Write-Host "[ERROR] No databases with valid schema found."
    exit 1
}

Write-Host "============================================================="
Write-Host "Schema Check Summary:"
Write-Host "   Chromium databases: $($chromiumFiles.Count)"
Write-Host "   Firefox databases: $($firefoxFiles.Count)"
Write-Host "   Total valid: $totalValid"
Write-Host "============================================================="
Write-Host ""

# Extract all URLs from valid databases
Write-Host "Extracting URLs from databases..."
Write-Host ""

$allUrls = @()

# Process Chromium databases
if ($chromiumFiles.Count -gt 0) {
    Write-Host "[CHROMIUM] Processing Chromium databases..."
    Write-Host ""

    foreach ($file in $chromiumFiles) {
        Write-Host "Extracting from: $file"

        # Extract URLs from favicons table (only those starting with "http")
        $urls = & $sqlite3Path $file "SELECT url FROM favicons WHERE url LIKE 'http%';" 2>$null
        $urlCount = 0
        if ($urls) {
            $urlCount = ($urls | Measure-Object).Count
            $allUrls += $urls
        }
        Write-Host "   Found $urlCount URLs in favicons table"

        # Extract page_urls from icon_mapping table (only those starting with "http")
        $pageUrls = & $sqlite3Path $file "SELECT page_url FROM icon_mapping WHERE page_url LIKE 'http%';" 2>$null
        $pageUrlCount = 0
        if ($pageUrls) {
            $pageUrlCount = ($pageUrls | Measure-Object).Count
            $allUrls += $pageUrls
        }
        Write-Host "   Found $pageUrlCount URLs in icon_mapping table"
        Write-Host ""
    }
}

# Process Firefox databases
if ($firefoxFiles.Count -gt 0) {
    Write-Host "[FIREFOX] Processing Firefox databases..."
    Write-Host ""

    foreach ($file in $firefoxFiles) {
        Write-Host "Extracting from: $file"

        # Extract URLs from moz_icons table (only those starting with "http")
        $iconUrls = & $sqlite3Path $file "SELECT icon_url FROM moz_icons WHERE icon_url LIKE 'http%';" 2>$null
        $iconUrlCount = 0
        if ($iconUrls) {
            $iconUrlCount = ($iconUrls | Measure-Object).Count
            $allUrls += $iconUrls
        }
        Write-Host "   Found $iconUrlCount URLs in moz_icons table"

        # Extract page_urls from moz_pages_w_icons table (only those starting with "http")
        $pageUrls = & $sqlite3Path $file "SELECT page_url FROM moz_pages_w_icons WHERE page_url LIKE 'http%';" 2>$null
        $pageUrlCount = 0
        if ($pageUrls) {
            $pageUrlCount = ($pageUrls | Measure-Object).Count
            $allUrls += $pageUrls
        }
        Write-Host "   Found $pageUrlCount URLs in moz_pages_w_icons table"
        Write-Host ""
    }
}

if ($allUrls.Count -eq 0) {
    Write-Host "[WARNING] No URLs found in any database."
    exit 0
}

# Sort and remove duplicates
Write-Host "Sorting and removing duplicates..."
$uniqueUrls = $allUrls | Where-Object { $_ -ne "" } | Sort-Object -Unique

Write-Host "[OK] Processing complete!"
Write-Host "   Total unique URLs collected: $($uniqueUrls.Count)"
Write-Host ""

# Save to file with timestamp
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$outputFile = "buster_$timestamp.txt"

Write-Host "Saving URLs to file..."
$uniqueUrls | Out-File -FilePath $outputFile -Encoding UTF8
Write-Host "[OK] Saved $($uniqueUrls.Count) unique URLs to: $outputFile"
Write-Host ""
Write-Host "Done!"