#!/usr/bin/env python3
"""
Automated checksum updater for Weaver binaries.

This script fetches the latest Weaver release checksums from GitHub
and updates the checksums.bzl file automatically.
"""

import json
import re
import sys
import urllib.request
from pathlib import Path
from typing import Dict, List, Optional

# GitHub API configuration
GITHUB_API_BASE = "https://api.github.com"
WEAVER_REPO = "open-telemetry/weaver"

def fetch_latest_releases(limit: int = 5) -> List[Dict]:
    """Fetch the latest Weaver releases from GitHub API."""
    
    url = f"{GITHUB_API_BASE}/repos/{WEAVER_REPO}/releases"
    
    try:
        with urllib.request.urlopen(url) as response:
            releases = json.loads(response.read().decode())
            return releases[:limit]
    except Exception as e:
        print(f"Error fetching releases: {e}")
        return []

def fetch_release_checksums(release_tag: str) -> Dict[str, str]:
    """Fetch checksums for a specific release."""
    
    # Try to find checksums file in release assets
    url = f"{GITHUB_API_BASE}/repos/{WEAVER_REPO}/releases/tags/{release_tag}"
    
    try:
        with urllib.request.urlopen(url) as response:
            release_data = json.loads(response.read().decode())
            
            checksums = {}
            
            # Look for checksums file in assets
            for asset in release_data.get("assets", []):
                asset_name = asset["name"]
                
                if "checksums" in asset_name.lower() or "sha256" in asset_name.lower():
                    # Download and parse checksums file
                    checksums.update(parse_checksums_file(asset["browser_download_url"]))
                    break
            
            # If no checksums file found, try to compute from individual assets
            if not checksums:
                checksums = compute_checksums_from_assets(release_data.get("assets", []))
            
            return checksums
            
    except Exception as e:
        print(f"Error fetching release {release_tag}: {e}")
        return {}

def parse_checksums_file(url: str) -> Dict[str, str]:
    """Parse a checksums file from URL."""
    
    checksums = {}
    
    try:
        with urllib.request.urlopen(url) as response:
            content = response.read().decode()
            
            # Parse common checksum file formats
            for line in content.splitlines():
                line = line.strip()
                if not line or line.startswith("#"):
                    continue
                
                # Try different formats
                # Format: checksum filename
                match = re.match(r'^([a-fA-F0-9]{64})\s+(.+)$', line)
                if match:
                    checksum, filename = match.groups()
                    platform = extract_platform_from_filename(filename)
                    if platform:
                        checksums[platform] = checksum
                        
    except Exception as e:
        print(f"Error parsing checksums file {url}: {e}")
    
    return checksums

def compute_checksums_from_assets(assets: List[Dict]) -> Dict[str, str]:
    """Compute checksums from individual release assets."""
    
    checksums = {}
    
    for asset in assets:
        asset_name = asset["name"]
        platform = extract_platform_from_filename(asset_name)
        
        if platform:
            # Download and compute checksum
            checksum = compute_file_checksum(asset["browser_download_url"])
            if checksum:
                checksums[platform] = checksum
    
    return checksums

def extract_platform_from_filename(filename: str) -> Optional[str]:
    """Extract platform from Weaver binary filename."""
    
    # Weaver binary naming patterns
    patterns = [
        (r'weaver-(\d+\.\d+\.\d+)-x86_64-unknown-linux-gnu\.tar\.xz', 'linux-x86_64'),
        (r'weaver-(\d+\.\d+\.\d+)-aarch64-unknown-linux-gnu\.tar\.xz', 'linux-aarch64'),
        (r'weaver-(\d+\.\d+\.\d+)-x86_64-apple-darwin\.tar\.xz', 'darwin-x86_64'),
        (r'weaver-(\d+\.\d+\.\d+)-aarch64-apple-darwin\.tar\.xz', 'darwin-aarch64'),
        (r'weaver-(\d+\.\d+\.\d+)-x86_64-pc-windows-msvc\.zip', 'windows-x86_64'),
        (r'weaver-(\d+\.\d+\.\d+)-aarch64-pc-windows-msvc\.zip', 'windows-aarch64'),
    ]
    
    for pattern, platform in patterns:
        if re.match(pattern, filename):
            return platform
    
    return None

def compute_file_checksum(url: str) -> Optional[str]:
    """Compute SHA256 checksum of a file from URL."""
    
    import hashlib
    
    try:
        with urllib.request.urlopen(url) as response:
            sha256_hash = hashlib.sha256()
            
            # Read file in chunks to handle large files
            for chunk in iter(lambda: response.read(4096), b""):
                sha256_hash.update(chunk)
            
            return sha256_hash.hexdigest()
            
    except Exception as e:
        print(f"Error computing checksum for {url}: {e}")
        return None

def update_checksums_file(checksums_data: Dict[str, Dict[str, str]], output_path: str):
    """Update the checksums.bzl file with new checksums."""
    
    checksums_file = Path(output_path)
    
    if not checksums_file.exists():
        print(f"Checksums file not found: {output_path}")
        return
    
    # Read current content
    with open(checksums_file, 'r') as f:
        content = f.read()
    
    # Update the WEAVER_CHECKSUMS dictionary
    for version, platform_checksums in checksums_data.items():
        version_key = version.replace(".", "_")
        
        # Create the new checksum entries
        checksum_entries = []
        for platform, checksum in platform_checksums.items():
            checksum_entries.append(f'        "{platform}": "{checksum}",')
        
        if checksum_entries:
            # Format the new version entry
            version_entry = f'''    "{version}": {{
{chr(10).join(checksum_entries)}
    }},'''
            
            # Replace or add the version entry
            pattern = rf'(\s*)"{version}":\s*{{[^}}]+}},'
            replacement = f'\n    {version_entry}'
            
            if re.search(pattern, content):
                content = re.sub(pattern, replacement, content, flags=re.MULTILINE | re.DOTALL)
            else:
                # Add new version entry before the closing brace
                content = re.sub(
                    r'(\s*)(},?\s*# Add more versions as needed\s*)(\s*})',
                    rf'\1{version_entry}\n\1\2\3',
                    content
                )
    
    # Write updated content
    with open(checksums_file, 'w') as f:
        f.write(content)
    
    print(f"Updated checksums file: {output_path}")

def main():
    """Main function to update checksums."""
    
    # Configuration
    output_path = "weaver/checksums.bzl"
    max_releases = 3  # Number of recent releases to process
    
    print("Fetching latest Weaver releases...")
    releases = fetch_latest_releases(max_releases)
    
    if not releases:
        print("No releases found. Exiting.")
        sys.exit(1)
    
    checksums_data = {}
    
    for release in releases:
        version = release["tag_name"].lstrip("v")  # Remove 'v' prefix
        print(f"Processing release {version}...")
        
        release_checksums = fetch_release_checksums(release["tag_name"])
        if release_checksums:
            checksums_data[version] = release_checksums
            print(f"  Found checksums for {len(release_checksums)} platforms")
        else:
            print(f"  No checksums found for {version}")
    
    if checksums_data:
        update_checksums_file(checksums_data, output_path)
        print("Checksums updated successfully!")
    else:
        print("No checksums found for any releases.")
        sys.exit(1)

if __name__ == "__main__":
    main() 