# FaviconBuster - Universal Edition

[![GitHub](https://img.shields.io/badge/GitHub-akgunumit%2FFaviconBuster-blue?logo=github)](https://github.com/akgunumit/FaviconBuster)

A cross-platform bash script to extract and collect all URLs from browser Favicons SQLite databases on **macOS** and **Linux**.

## Overview

FaviconBuster automatically detects your operating system and searches for browser favicon databases in the appropriate directories, validates their structure, and extracts all unique URLs.

The script supports **Chromium-based browsers** (Chrome, Brave, Edge, etc.), **Firefox-based browsers** (Firefox, Tor Browser), and **Safari** (macOS only), automatically detecting the browser type and using the appropriate database schema.

This is useful for:
- Security auditing of browsing history
- Data recovery and analysis
- Privacy assessment
- Browser data migration
- Digital forensics

## Supported Platforms

✅ **macOS** (10.13+)  
✅ **Linux** (Ubuntu, Debian, Fedora, Arch, and most distributions)

## Supported Browsers

The script automatically detects and extracts URLs from:

### Chromium-based browsers:
- Google Chrome
- Chromium
- Brave Browser
- Microsoft Edge
- Vivaldi
- Opera
- Any other Chromium-based browsers

### Firefox-based browsers:
- Mozilla Firefox (all profiles)
- Tor Browser (uses Firefox schema)

### Safari:
- Safari (macOS only)

The script automatically detects the browser type based on database schema and uses the appropriate extraction method.

## How It Works

1. **OS Detection**: Automatically detects whether you're running macOS or Linux
2. **Recursive Search**: Searches parent directories recursively for favicon databases:
    - Chromium: Files named "Favicons"
    - Firefox/Tor Browser: Files named "favicons.sqlite"
    - Safari: Files named "favicons.db" (macOS only)
3. **Validate**: Checks if files are valid SQLite3 databases
4. **Browser Detection**: Identifies browser type by checking database schema:
    - **Chromium**: `favicons` and `icon_mapping` tables
    - **Firefox/Tor Browser**: `moz_icons` and `moz_pages_w_icons` tables
    - **Safari**: `icon_info`, `page_url`, and `rejected_resources` tables
5. **Extract**: Retrieves all URLs starting with "http" using browser-specific queries
6. **Process**: Sorts and removes duplicate URLs from all browsers
7. **Export**: Saves results to `buster_TIMESTAMP.txt`

## Requirements

### macOS
- macOS 10.13 or later
- Bash 3.2+ (pre-installed)
- SQLite3 (pre-installed)
- Standard Unix utilities

### Linux
- Any modern Linux distribution
- Bash 3.2+
- SQLite3
- Standard Unix utilities

#### Installing SQLite3 on Linux

**Debian/Ubuntu:**
```bash
sudo apt install sqlite3
```

**Fedora/RHEL:**
```bash
sudo dnf install sqlite
```

**Arch Linux:**
```bash
sudo pacman -S sqlite
```

## Installation

1. Download the script:

**Option A: Download directly**
```bash
# Using wget
wget https://raw.githubusercontent.com/akgunumit/FaviconBuster/main/favicon_buster.sh

# Or using curl
curl -O https://raw.githubusercontent.com/akgunumit/FaviconBuster/main/favicon_buster.sh
```

**Option B: Clone the repository**
```bash
git clone https://github.com/akgunumit/FaviconBuster.git
cd FaviconBuster
```

2. Make it executable:
```bash
chmod +x favicon_buster.sh
```

3. Run the script:
```bash
./favicon_buster.sh
```

## Usage

Simply run the script - it will automatically detect your OS and search the appropriate directories:

```bash
./favicon_buster.sh
```

### Example Output

**On macOS:**
```
🔍 FaviconBuster - Universal Edition
====================================

🖥️  Detected OS: Darwin

📱 Running in macOS mode...

🔍 Searching for browser favicon databases...

📊 Found 4 favicon database(s)

🔎 Validating SQLite3 databases...

📄 Checking: /Users/admin/Library/Application Support/Google/Chrome/Default/Favicons
   ✅ Valid SQLite3 file

📄 Checking: /Users/admin/Library/Application Support/Firefox/Profiles/abc123.default/favicons.sqlite
   ✅ Valid SQLite3 file

📄 Checking: /Users/admin/Library/Safari/Favicon Cache/favicons.db
   ✅ Valid SQLite3 file

═══════════════════════════════════════════════════════════
📊 Validation Summary:
   Total files found: 4
   Valid SQLite3 files: 3
═══════════════════════════════════════════════════════════

🔍 Checking database schemas and detecting browser types...

📋 Analyzing: /Users/admin/Library/Application Support/Google/Chrome/Default/Favicons
   ✅ Chromium database (favicons.url + icon_mapping.page_url)

📋 Analyzing: /Users/admin/Library/Application Support/Firefox/Profiles/abc123.default/favicons.sqlite
   ✅ Firefox database (moz_icons.icon_url + moz_pages_w_icons.page_url)

📋 Analyzing: /Users/admin/Library/Safari/Favicon Cache/favicons.db
   ✅ Safari database (icon_info.url + page_url.url + rejected_resources)

═══════════════════════════════════════════════════════════
📊 Schema Check Summary:
   Chromium databases: 1
   Firefox databases: 1
   Safari databases: 1
   Total valid: 3
═══════════════════════════════════════════════════════════

🔗 Extracting URLs from databases...

🔵 Processing Chromium databases...

📥 Extracting from: /Users/admin/Library/Application Support/Google/Chrome/Default/Favicons
   Found 847 URLs in favicons table
   Found 1203 URLs in icon_mapping table

🦊 Processing Firefox databases...

📥 Extracting from: /Users/admin/Library/Application Support/Firefox/Profiles/abc123.default/favicons.sqlite
   Found 432 URLs in moz_icons table
   Found 658 URLs in moz_pages_w_icons table

🧭 Processing Safari databases...

📥 Extracting from: /Users/admin/Library/Safari/Favicon Cache/favicons.db
   Found 324 URLs in icon_info table
   Found 512 URLs in page_url table
   Found 89 URLs in rejected_resources.page_url
   Found 45 URLs in rejected_resources.icon_url

✅ Processing complete!
   Total unique URLs collected: 2834

💾 Saving URLs to file...
✅ Saved 2834 unique URLs to: buster_20241118_143022.txt

🎉 Done!
```

**On Linux:**
```
🔍 FaviconBuster - Universal Edition
====================================

🖥️  Detected OS: Linux

🐧 Running in Linux mode...

🔍 Searching for Favicons files in browser directories...

📊 Found 3 Favicons file(s)

🔎 Validating SQLite3 databases...
...
✅ Saved 1823 unique URLs to: buster_20241118_143022.txt

🎉 Done!
```

## Search Locations

The script recursively searches the following parent directories for favicon databases:

### macOS
- `~/Library/Application Support/` (Chromium browsers, Firefox, and Tor Browser)
- `~/Library/Safari/Favicon Cache/` (Safari)
    - Finds databases from: Chrome, Chromium, Brave, Edge, Vivaldi, Opera, Firefox, Tor Browser, Safari, and other browsers

### Linux
- `~/.config/` (standard installations)
- `~/.cache/` (cached browser data)
- `~/.var/app/` (Flatpak installations)
- `~/snap/` (Snap installations)
- `~/.mozilla/` (Firefox profiles and Tor Browser)
- `~/.local/share/` (Tor Browser data)

### Database Files Detected:
- **Chromium browsers**: Files named "Favicons"
- **Firefox/Tor Browser**: Files named "favicons.sqlite"
- **Safari**: Files named "favicons.db" (macOS only)

**Note about Tor Browser:** Tor Browser uses the same Firefox database schema (`favicons.sqlite` with `moz_icons` and `moz_pages_w_icons` tables), so it's automatically detected and processed as a Firefox-based browser.

This approach automatically discovers favicon databases from any supported browser installed in these locations.

## Output File Format

The output file (`buster_TIMESTAMP.txt`) contains one URL per line, sorted alphabetically with duplicates removed:

```
https://example.com/
https://github.com/
https://www.google.com/
...
```

## Troubleshooting

### No favicon databases found
- Ensure you have supported browsers installed (Chrome, Brave, Edge, Firefox, Tor Browser, Safari)
- Check if your browser uses a non-standard data directory
- Verify the browser has been used to visit websites (databases are empty on fresh install)
- For Firefox/Tor Browser, ensure you have at least one profile with browsing history
- For Safari (macOS), ensure Safari has been used to browse websites

### Database locked error
Close your browsers before running the script:

**macOS:**
```bash
pkill "Google Chrome"
pkill Chromium
pkill "Brave Browser"
pkill Firefox
pkill "Tor Browser"
pkill Safari
```

**Linux:**
```bash
pkill chrome
pkill chromium
pkill brave
pkill firefox
pkill tor
```

### Permission denied
Ensure you have read access to the browser directories:

**macOS:**
```bash
ls -la ~/Library/Application\ Support/
```

**Linux:**
```bash
ls -la ~/.config/
```

### Unsupported OS
If you see "Unsupported operating system", you're running on a system other than macOS or Linux (e.g., Windows, BSD). This script currently only supports macOS and Linux.

For **Windows users**: Consider using WSL (Windows Subsystem for Linux) to run this script.

### Missing SQLite3 (Linux)
Install SQLite3 using your package manager (see Requirements section).

## Privacy & Security Notes

**Important considerations:**

### Sensitive Data in URLs
Favicon databases store complete URLs including query parameters, which can reveal:
- Search queries (e.g., `?q=sensitive+search`)
- Session tokens and tracking IDs
- User identifiers
- Form data passed via GET requests
- API keys in URLs
- Personal information in query strings
- OAuth tokens and authentication data

### Data Persistence
Favicon caches can survive:
- Regular browser cache clearing
- Private/Incognito mode (in some cases)
- Cookie deletion
- Browser restarts

## Use Cases

- **Security Research**: Understanding browser data persistence mechanisms
- **Digital Forensics**: Recovering browsing history from favicon databases
- **Privacy Auditing**: Checking what data persists after cache clearing
- **Data Recovery**: Retrieving lost browsing history

## Technical Details

### OS Detection
The script uses `uname -s` to detect the operating system:
- Returns `Darwin` for macOS
- Returns `Linux` for Linux systems

### Database Structure
The script expects the following database schemas:

**Chromium browsers:**
```sql
-- favicons table
CREATE TABLE favicons (
    id INTEGER PRIMARY KEY,
    url LONGVARCHAR NOT NULL,
    ...
);

-- icon_mapping table
CREATE TABLE icon_mapping (
    id INTEGER PRIMARY KEY,
    page_url LONGVARCHAR NOT NULL,
    ...
);
```

**Firefox/Tor Browser:**
```sql
-- moz_icons table
CREATE TABLE moz_icons (
    id INTEGER PRIMARY KEY,
    icon_url TEXT,
    ...
);

-- moz_pages_w_icons table
CREATE TABLE moz_pages_w_icons (
    id INTEGER PRIMARY KEY,
    page_url TEXT,
    ...
);
```
*Note: Tor Browser uses the same database schema as Firefox.*

**Safari (macOS only):**
```sql
-- icon_info table
CREATE TABLE icon_info (
    uuid TEXT PRIMARY KEY,
    url TEXT,
    ...
);

-- page_url table
CREATE TABLE page_url (
    id INTEGER PRIMARY KEY,
    url TEXT,
    ...
);

-- rejected_resources table
CREATE TABLE rejected_resources (
    id INTEGER PRIMARY KEY,
    page_url TEXT,
    icon_url TEXT,
    ...
);
```

### Compatibility
- Compatible with older bash versions found on macOS
- Uses temporary files for deduplication to avoid memory issues with large datasets

## Inspired By

This tool was inspired by the [supercookie](https://github.com/jonasstrehle/supercookie) project, which demonstrates how favicons can be used for persistent tracking.

## License

MIT License - Feel free to use and modify as needed.

## Contributing

Issues and pull requests are welcome at [github.com/akgunumit/FaviconBuster](https://github.com/akgunumit/FaviconBuster)! Please ensure cross-platform compatibility when contributing.

## Disclaimer

This tool is for educational, research, and legitimate security purposes only. Always:
- Respect privacy laws and regulations
- Obtain proper authorization before analyzing systems you don't own
- Use responsibly and ethically
- Handle extracted data securely

## Support

For issues, questions, or contributions:
- Open an issue on [GitHub](https://github.com/akgunumit/FaviconBuster/issues)
- Submit a pull request on [GitHub](https://github.com/akgunumit/FaviconBuster/pulls)
- Check [existing issues](https://github.com/akgunumit/FaviconBuster/issues) for solutions