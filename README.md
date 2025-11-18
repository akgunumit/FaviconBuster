# FaviconBuster

A bash script to extract and collect all URLs from browser Favicons SQLite databases on macOS.

## Overview

FaviconBuster searches for browser favicon databases in your macOS Application Support directory, validates their structure, and extracts all unique URLs. This is useful for:
- Security auditing of browsing history
- Data recovery and analysis
- Privacy assessment
- Browser data migration

## How It Works

The script performs the following steps:

1. **Search**: Finds all files named "Favicons" in `~/Library/Application Support/`
2. **Validate**: Checks if files are valid SQLite3 databases
3. **Schema Check**: Verifies required tables and columns exist:
    - `favicons` table with `url` column
    - `icon_mapping` table with `page_url` column
4. **Extract**: Retrieves all URLs starting with "http" from both tables
5. **Process**: Sorts and removes duplicate URLs
6. **Export**: Saves results to `buster_TIMESTAMP.txt`

## Requirements

- macOS (tested on macOS 10.13+)
- Bash 3.2+ (default macOS bash)
- SQLite3 (pre-installed on macOS)
- Standard Unix utilities: `find`, `file`, `grep`, `sort`

## Installation

1. Download or clone the script:
```bash
git clone https://github.com/akgunumit/FaviconBuster.git
cd FaviconBuster
```

2. Make the script executable:
```bash
chmod +x run.sh
```

## Usage

Run the script:
```bash
./run.sh
```

The script will:
- Display progress messages for each step
- Show validation results for each database found
- Create an output file named `buster_YYYYMMDD_HHMMSS.txt`

### Example Output

```
🔍 Searching for Favicons files in Application Support...

📄 Found: /Users/username/Library/Application Support/Google/Chrome/Default/Favicons
   ✅ Valid SQLite3 file

═══════════════════════════════════════════════════════════
📊 First Pass Summary:
   Total files found: 3
   SQLite3 files: 2
═══════════════════════════════════════════════════════════

🔎 Validating database schemas...

🗄️  Checking: /Users/username/Library/Application Support/Google/Chrome/Default/Favicons
   ✅ Found 'favicons' table with 'url' column
   ✅ Found 'icon_mapping' table with 'page_url' column
   ✨ Database structure validated!

═══════════════════════════════════════════════════════════
📊 Final Summary:
   Total files found: 3
   SQLite3 files: 2
   Valid databases: 1
═══════════════════════════════════════════════════════════

🔗 Extracting URLs from databases...

📥 Extracting from: /Users/username/Library/Application Support/Google/Chrome/Default/Favicons
   Found 1523 URLs in favicons table
   Found 2847 URLs in icon_mapping table

🔄 Sorting and removing duplicates...
✅ Processing complete!
   Total unique URLs collected: 3142

💾 Saving URLs to file...
✅ Saved 3142 unique URLs to: buster_20241118_143022.txt
```

## Output Format

The output file contains one URL per line:
```
http://example.com
http://github.com
https://www.google.com
https://stackoverflow.com
...
```

## Browsers Supported

This script works with any browser that stores favicons in SQLite format with the standard schema, including:
- Google Chrome
- Chromium
- Microsoft Edge
- Brave
- Opera
- Vivaldi

## Troubleshooting

### No files found
If the script finds no files, browsers might store their data in different locations. Common alternatives:
- `~/Library/Application Support/BraveSoftware/Brave-Browser/`
- `~/Library/Application Support/Microsoft Edge/`

### Database locked error
Close your browser before running the script, as databases may be locked while the browser is running.

### Permission denied
Ensure you have read access to the Application Support directory:
```bash
ls -la ~/Library/Application\ Support/
```

## Cybersecurity Significance

### Why Favicons Are Important for Security Research

Favicon databases are particularly valuable in cybersecurity and digital forensics for several critical reasons:

#### 1. **Persistence and Retention**
Favicon caches are stored in separate local databases and exhibit unique characteristics that make them particularly persistent - they are not affected by users clearing their browser data, survive system reboots, and even persist across incognito/private browsing sessions. Unlike regular browser history:

- **Not cleared with regular cache**: Standard "Clear browsing data" operations often leave favicon databases intact
- **Survives private browsing**: Favicons are fetched even in private browsing modes, making them ideal for persistent tracking
- **Separate storage**: Stored in dedicated SQLite databases (F-Cache) independent of browsing history
- **Long retention**: May retain URLs that have been purged or deleted from the History database

#### 2. **Forensic Value**
Favicon databases are indispensable for investigators as they can help reconstruct user activities, trace behaviors, and establish timelines:

- **Recovers deleted history**: In some instances, favicon databases retain URLs that have been purged or deleted from the History database
- **Timeline reconstruction**: Contains timestamps and visit patterns
- **Cross-browser analysis**: Similar structure across Chromium-based browsers (Chrome, Edge, Brave, Opera, Vivaldi)
- **Unallocated space recovery**: Fragments of purged or deleted data may remain in the unallocated space of SQLite database pages
- **URL parameters included**: Favicon databases store complete URLs including parameters, which can reveal:
    - Search queries (e.g., `google.com/search?q=sensitive+search+term`)
    - Session tokens and tracking IDs
    - User identifiers and account information
    - Form data passed via GET requests
    - API keys or authentication tokens in URLs
    - Personal information in query strings

#### 3. **Inspiration: The Supercookie Project**

This project was inspired by the [supercookie](https://github.com/jonasstrehle/supercookie) project by Jonas Strehle, which demonstrates how favicon caches can be exploited for persistent tracking. His research, based on work by the University of Illinois at Chicago, revealed the security implications of favicon persistence and highlighted why these databases are valuable for both security research and privacy auditing.

#### 4. **Use Cases in Security**

- **Incident Response**: Trace malicious website visits and phishing attempts
- **Threat Intelligence**: Identify patterns of suspicious browsing behavior
- **Privacy Auditing**: Assess tracking exposure and data collection
- **Legal Investigations**: Recover browsing history for evidence
- **Security Research**: Analyze browser behavior and privacy vulnerabilities

## Privacy Note

This script reads local browser databases. The extracted URLs represent websites you've visited and can reveal detailed browsing patterns.

**Important considerations:**
- Favicon data persists longer than regular browsing history
- May contain URLs from incognito/private browsing sessions
- Can reveal sites visited even after "clearing" browser data
- Handle output files securely and delete them when no longer needed
- Be aware that this data can be used for tracking and fingerprinting

**Defensive measures:**
- Regularly clear favicon caches manually (browser-specific procedures)
- Use privacy-focused browsers with enhanced tracking protection
- Consider disabling favicon caching if your browser supports it
- Be aware that standard privacy tools may not protect against favicon-based tracking

## License

MIT License - Feel free to use and modify as needed.

## Contributing

Issues and pull requests are welcome!
