# FaviconBuster - Cross-Platform Edition

[![GitHub](https://img.shields.io/badge/GitHub-akgunumit%2FFaviconBuster-blue?logo=github)](https://github.com/akgunumit/FaviconBuster)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20Windows-lightgrey)]()
[![License](https://img.shields.io/badge/license-MIT-green)]()

A cross-platform tool to extract and collect all URLs from browser Favicons SQLite databases.

## Overview

FaviconBuster automatically detects your operating system, searches for browser favicon databases in the appropriate directories, validates their structure, and extracts all unique URLs.

The tool supports **Chromium-based browsers** (Chrome, Brave, Edge, etc.), **Firefox-based browsers** (Firefox, Tor Browser), and **Safari** (macOS only), automatically detecting the browser type and using the appropriate database schema.

This is useful for:
- Security auditing of browsing history
- Data recovery and analysis
- Privacy assessment
- Digital forensics

## Supported Platforms

- ✅ **macOS** (10.13+)
- ✅ **Linux** (Ubuntu, Debian, Fedora, Arch, and most distributions)
- ✅ **Windows** (10/11, Server 2016+)

## Supported Browsers

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
- Tor Browser

### Safari:
- Safari (macOS only)

The script automatically detects the browser type based on database schema and uses the appropriate extraction method.

## Quick Start

### macOS / Linux

```bash
# Download the script
wget https://raw.githubusercontent.com/akgunumit/FaviconBuster/main/favicon_buster.sh

# Make it executable
chmod +x favicon_buster.sh

# Run it
./favicon_buster.sh
```

### Windows

```powershell
# Download the script
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/akgunumit/FaviconBuster/main/favicon_buster.ps1" -OutFile "favicon_buster.ps1"

# Download sqlite3.exe from https://www.sqlite.org/download.html
# Place sqlite3.exe in the same directory as the script

# Run it
.\favicon_buster.ps1
```

## Requirements

### macOS
- Bash 3.2+ (pre-installed)
- SQLite3 (pre-installed)

### Linux
- Bash 3.2+
- SQLite3 (install if needed: `sudo apt install sqlite3`)

### Windows
- PowerShell 5.1+ (pre-installed on Windows 10/11)
- **sqlite3.exe** - [Download from sqlite.org](https://www.sqlite.org/download.html)

## Installation

### Option 1: Download Scripts Directly

**macOS / Linux:**
```bash
wget https://raw.githubusercontent.com/akgunumit/FaviconBuster/main/favicon_buster.sh
chmod +x favicon_buster.sh
```

**Windows:**
```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/akgunumit/FaviconBuster/main/favicon_buster.ps1" -OutFile "favicon_buster.ps1"
```

### Option 2: Clone Repository

```bash
git clone https://github.com/akgunumit/FaviconBuster.git
cd FaviconBuster
```

**Then run:**
- **macOS/Linux**: `./favicon_buster.sh`
- **Windows**: `.\favicon_buster.ps1`

## Usage

### macOS / Linux

```bash
# Simply run the script
./favicon_buster.sh
```

The script will:
1. Auto-detect your OS (macOS or Linux)
2. Search for favicon databases recursively
3. Validate and identify browser types
4. Extract URLs from all supported browsers
5. Save results to `buster_TIMESTAMP.txt`

### Windows

**First time only:** Allow script execution
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Run the script:**
```powershell
.\favicon_buster.ps1
```

Or right-click `favicon_buster.ps1` and select **"Run with PowerShell"**

### Windows: Getting sqlite3.exe

1. Go to https://www.sqlite.org/download.html
2. Download "Precompiled Binaries for Windows"
3. Look for: `sqlite-tools-win-x64-XXXXXXX.zip`
4. Extract `sqlite3.exe` to the same directory as the script

## Search Locations

The tool recursively searches parent directories for favicon databases:

### macOS
- `~/Library/Application Support/` - Chromium browsers, Firefox, Tor Browser
- `~/Library/Safari/` - Safari

### Linux
- `~/.config/` - Standard installations
- `~/.cache/` - Cached browser data
- `~/.var/app/` - Flatpak installations
- `~/snap/` - Snap installations
- `~/.mozilla/` - Firefox profiles
- `~/.local/share/` - Tor Browser data

### Windows
- `%LOCALAPPDATA%` - Chrome, Edge, Brave, Vivaldi, Chromium
- `%APPDATA%` - Firefox, Opera
- `%USERPROFILE%\Desktop` - Tor Browser portable

### Database Files Detected:
- **Chromium browsers**: Files named "Favicons"
- **Firefox/Tor Browser**: Files named "favicons.sqlite"
- **Safari** (macOS): Files named "favicons.db"

This approach automatically discovers favicon databases from any supported browser installed in these locations.

## Output File Format

The output file (`buster_TIMESTAMP.txt`) contains one URL per line, sorted alphabetically with duplicates removed:

```
https://example.com/
https://github.com/
https://www.google.com/
...
```

## Platform-Specific Notes

### macOS / Linux
- Uses Bash shell script
- Native SQLite3 support
- No additional dependencies

### Windows
- Uses PowerShell script
- Requires `sqlite3.exe` download
- May need execution policy change on first run

### Safari (macOS only)
Safari favicon databases have a unique schema with additional tables:
- `icon_info` table
- `page_url` table
- `rejected_resources` table (contains both `page_url` and `icon_url`)

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

## Common Issues

### Database locked error
Close your browsers before running the script.

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

**Windows:**
```powershell
Stop-Process -Name chrome -ErrorAction SilentlyContinue
Stop-Process -Name msedge -ErrorAction SilentlyContinue
Stop-Process -Name firefox -ErrorAction SilentlyContinue
Stop-Process -Name brave -ErrorAction SilentlyContinue
```

### Windows: sqlite3.exe not found

Download SQLite from https://www.sqlite.org/download.html and place `sqlite3.exe` in the script directory.

### Windows: Script execution disabled

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Linux: Missing SQLite3

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

## Files in Repository

- `favicon_buster.sh` - Bash script for macOS and Linux
- `favicon_buster.ps1` - PowerShell script for Windows
- `README.md` - This file