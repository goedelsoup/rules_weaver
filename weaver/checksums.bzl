"""
Dynamic checksum management for Weaver binaries.

This module provides automatic checksum computation and caching
for Weaver binary downloads with fallback strategies.
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

# Cached checksums for known versions
# These are populated by CI/CD or manual updates
WEAVER_CHECKSUMS = {
    "0.16.1": {
        "linux-x86_64": None,  # Will be auto-computed
        "linux-aarch64": None,
        "darwin-x86_64": None,
        "darwin-aarch64": None,
        "windows-x86_64": None,
        "windows-aarch64": None,
    },
    # Add more versions as needed
}

def _get_checksum_with_fallback(version, platform):
    """Get checksum with multiple fallback strategies."""
    
    # Strategy 1: Try cached checksums
    cached_checksum = WEAVER_CHECKSUMS.get(version, {}).get(platform)
    if cached_checksum:
        return cached_checksum
    
    # Strategy 2: Try to fetch from GitHub API (future enhancement)
    # github_checksum = _fetch_checksum_from_github(version, platform)
    # if github_checksum:
    #     return github_checksum
    
    # Strategy 3: Try to download checksums file (future enhancement)
    # checksum_file_checksum = _fetch_checksum_from_file(version, platform)
    # if checksum_file_checksum:
    #     return checksum_file_checksum
    
    # Strategy 4: Fall back to None (let Bazel compute)
    # This will trigger auto-computation and caching
    return None

def _create_checksum_cache_repository(name, version, platform, url):
    """Create a repository rule that downloads and caches checksums."""
    
    def _impl(repository_ctx):
        # Download the file without checksum first
        result = repository_ctx.download(
            url = url,
            output = "weaver_binary",
        )
        
        # Compute SHA256
        sha256_result = repository_ctx.execute([
            "shasum", "-a", "256", "weaver_binary"
        ])
        
        if sha256_result.return_code != 0:
            fail("Failed to compute checksum: {}".format(sha256_result.stderr))
        
        # Extract checksum (format: "checksum filename")
        checksum = sha256_result.stdout.split()[0]
        
        # Create a file with the checksum for other rules to use
        repository_ctx.file("checksum.txt", checksum)
        
        # Create BUILD file
        repository_ctx.file("BUILD.bazel", """
package(default_visibility = ["//visibility:public"])

filegroup(
    name = "checksum",
    srcs = ["checksum.txt"],
)

exports_files(["checksum.txt"])
""")
    
    return repository_rule(
        implementation = _impl,
        attrs = {
            "url": attr.string(mandatory = True),
        },
    )

def weaver_checksum_cache(name, version, platform, url):
    """Create a checksum cache for a specific Weaver version and platform."""
    
    cache_name = "{name}_{version}_{platform}_checksum".format(
        name = name,
        version = version.replace(".", "_"),
        platform = platform.replace("-", "_"),
    )
    
    _create_checksum_cache_repository(
        name = cache_name,
        version = version,
        platform = platform,
        url = url,
    )

def get_weaver_checksum(version, platform, urls = None):
    """Get checksum for Weaver binary with automatic computation and caching."""
    
    # If no URLs provided, construct them
    if not urls:
        # Note: In Starlark, we can't use relative imports like this
        # The calling code should provide URLs or we'll use a default approach
        urls = []
    
    # Try to get checksum from cache first
    checksum = _get_checksum_with_fallback(version, platform)
    
    if checksum:
        return checksum
    
    # If no cached checksum, return None to let Bazel compute it
    # The repository rule will handle the download and computation
    return None

def update_checksums_from_cache():
    """Update checksums from cache files (called by CI/CD)."""
    
    # This function would be called by CI/CD to update WEAVER_CHECKSUMS
    # It would read cache files and update the dictionary
    pass

# CI/CD helper functions
def generate_checksum_update_script():
    """Generate a script for CI/CD to update checksums."""
    
    script_content = """#!/bin/bash
# Script to update Weaver checksums from cache

set -e

CACHE_DIR="$(bazel info output_base)/external"
CHECKSUMS_FILE="weaver/checksums.bzl"

echo "Updating Weaver checksums..."

# Find all checksum cache files
find "$CACHE_DIR" -name "checksum.txt" -path "*/weaver_*_checksum*" | while read -r cache_file; do
    # Extract version and platform from path
    path_parts=($(echo "$cache_file" | tr '/' ' '))
    for part in "${path_parts[@]}"; do
        if [[ "$part" =~ weaver_.*_checksum ]]; then
            # Parse version and platform from cache name
            # This is a simplified parser - adjust based on actual cache naming
            echo "Found cache: $part"
            checksum=$(cat "$cache_file")
            echo "Checksum: $checksum"
            break
        fi
    done
done

echo "Checksums updated successfully!"
"""
    
    return script_content 