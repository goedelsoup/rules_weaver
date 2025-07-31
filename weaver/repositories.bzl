"""
Repository rules for OpenTelemetry Weaver.

This module provides repository rules for downloading and registering
Weaver binaries for hermetic Bazel builds with multi-platform support.
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load(":platform_constraints.bzl", 
     "get_supported_platforms", 
     "get_platform_metadata",
     "is_windows_platform",
     "get_platform_specific_binary_name",
     "normalize_path")
load(":checksums.bzl", "get_weaver_checksum")

# Weaver 0.16.1 SHA256 hashes for all supported platforms
# Note: These are placeholder values. For production use, provide actual SHA256 hashes.
# For now, we'll let Bazel compute the SHA256 automatically.
WEAVER_0_16_1_SHA256 = {
    # "linux-x86_64": "actual_sha256_here",
    # "linux-aarch64": "actual_sha256_here", 
    # "darwin-x86_64": "actual_sha256_here",
    # "darwin-aarch64": "actual_sha256_here",
    # "windows-x86_64": "actual_sha256_here",
}

def _detect_platform(repository_ctx):
    """Detect the current platform and architecture with multi-platform support."""
    os_name = repository_ctx.os.name
    arch = repository_ctx.os.arch
    
    # Enhanced platform detection for multi-platform environments
    if os_name == "linux":
        if arch == "x86_64":
            return "linux-x86_64"
        elif arch == "aarch64":
            return "linux-aarch64"
        else:
            fail("Unsupported Linux architecture: {}".format(arch))
    elif os_name == "mac os x":
        if arch == "x86_64":
            return "darwin-x86_64"
        elif arch == "aarch64":
            return "darwin-aarch64"
        else:
            fail("Unsupported macOS architecture: {}".format(arch))
    elif os_name == "windows":
        if arch == "x86_64":
            return "windows-x86_64"
        elif arch == "aarch64":
            return "windows-aarch64"
        else:
            fail("Unsupported Windows architecture: {}".format(arch))
    else:
        fail("Unsupported operating system: {}".format(os_name))

def _get_download_urls(version, platform, urls = None):
    """Get download URLs for the specified version and platform with multi-platform optimization."""
    if urls:
        return urls
    
    # Default URLs from GitHub releases optimized for multi-platform support
    # Based on actual Weaver release structure from GitHub API
    base_url = "https://github.com/open-telemetry/weaver/releases/download"
    
    # Map platform to actual Weaver binary names from releases
    platform_map = {
        "linux-x86_64": "x86_64-unknown-linux-gnu",
        "linux-aarch64": "aarch64-unknown-linux-gnu",  # Note: May not be available in all releases
        "darwin-x86_64": "x86_64-apple-darwin",
        "darwin-aarch64": "aarch64-apple-darwin",
        "windows-x86_64": "x86_64-pc-windows-msvc",
        "windows-aarch64": "aarch64-pc-windows-msvc",  # Note: May not be available in all releases
    }
    
    binary_suffix = platform_map.get(platform)
    if not binary_suffix:
        fail("Unsupported platform: {}".format(platform))
    
    # Construct URLs for Weaver binary with actual release format
    # Weaver uses .tar.xz for Unix-like systems and .zip for Windows
    if platform.startswith("windows"):
        return [
            "{}/v{}/weaver-{}.zip".format(
                base_url, version, binary_suffix
            ),
        ]
    else:
        return [
            "{}/v{}/weaver-{}.tar.xz".format(
                base_url, version, binary_suffix
            ),
        ]

def _get_sha256_for_platform(version, platform):
    """Get SHA256 hash for the specified version and platform."""
    # Use the new dynamic checksum system
    return get_weaver_checksum(version, platform)

def _find_weaver_binary(repository_ctx, platform):
    """Find the Weaver binary in the downloaded archive with multi-platform compatibility."""
    # Debug: List all files in the repository
    if is_windows_platform(platform):
        result = repository_ctx.execute(["cmd", "/c", "dir", "/s", "/b"])
    else:
        result = repository_ctx.execute(["find", ".", "-type", "f"])
    
    if result.return_code == 0:
        print("DEBUG: Files in repository: " + result.stdout)
    
    # Get platform-specific binary name
    binary_name = get_platform_specific_binary_name("weaver", platform)
    
    # Look for common binary names with enhanced detection
    # Based on actual Weaver binary structure
    binary_patterns = [
        "weaver-aarch64-apple-darwin/weaver",  # Direct path based on debug output
        "weaver-x86_64-apple-darwin/weaver",   # Direct path for x86_64
        "weaver-x86_64-unknown-linux-gnu/weaver",  # Direct path for Linux
        "weaver-x86_64-pc-windows-msvc/weaver.exe",  # Direct path for Windows
        binary_name,
        "weaver",
        "weaver.exe",
        "opentelemetry-weaver",
        "otlp-weaver",
        "weaver-*",
        "opentelemetry-weaver-*",
        "weaver-*-*-*",
        "weaver-*/weaver",  # Look for binary in subdirectory
    ]
    
    # Platform-specific search commands
    if is_windows_platform(platform):
        # Windows-specific search using dir command
        for pattern in binary_patterns:
            result = repository_ctx.execute([
                "cmd", "/c", "dir", "/s", "/b", pattern
            ], working_directory = ".")
            if result.return_code == 0 and result.stdout.strip():
                binary_path = result.stdout.strip().split("\n")[0]
                # Remove leading ./ if present
                if binary_path.startswith("./"):
                    binary_path = binary_path[2:]
                return binary_path
    else:
        # Unix-like systems using find command
        for pattern in binary_patterns:
            result = repository_ctx.execute([
                "find", ".", "-name", pattern, "-type", "f"
            ], working_directory = ".")
            if result.return_code == 0 and result.stdout.strip():
                binary_path = result.stdout.strip().split("\n")[0]
                # Remove leading ./ if present
                if binary_path.startswith("./"):
                    binary_path = binary_path[2:]
                return binary_path
    
    # If no binary found, fail with helpful error message
    fail("Could not find Weaver binary for platform {} in downloaded archive. Searched for patterns: {}".format(
        platform, binary_patterns
    ))

def _extract_archive(repository_ctx, archive_path, platform):
    """Extract archive with platform-specific handling."""
    if archive_path.endswith(".tar.gz") or archive_path.endswith(".tgz"):
        if is_windows_platform(platform):
            # Windows tar extraction
            result = repository_ctx.execute([
                "tar", "-xzf", archive_path
            ])
        else:
            # Unix tar extraction
            result = repository_ctx.execute([
                "tar", "-xzf", archive_path
            ])
    elif archive_path.endswith(".tar.xz"):
        if is_windows_platform(platform):
            # Windows tar.xz extraction
            result = repository_ctx.execute([
                "tar", "-xf", archive_path
            ])
        else:
            # Unix tar.xz extraction
            result = repository_ctx.execute([
                "tar", "-xf", archive_path
            ])
    elif archive_path.endswith(".zip"):
        if is_windows_platform(platform):
            # Windows zip extraction
            result = repository_ctx.execute([
                "powershell", "-Command", "Expand-Archive", "-Path", archive_path, "-DestinationPath", "."
            ])
        else:
            # Unix zip extraction
            result = repository_ctx.execute([
                "unzip", archive_path
            ])
    else:
        fail("Unsupported archive format: {}".format(archive_path))
    
    if result.return_code != 0:
        fail("Failed to extract archive: {}".format(result.stderr))

def _weaver_repository_impl(repository_ctx):
    """Implementation of the weaver_repository rule."""
    
    # Detect platform
    platform = _detect_platform(repository_ctx)
    
    # Get download URLs
    urls = _get_download_urls(
        repository_ctx.attr.version,
        platform,
        repository_ctx.attr.urls,
    )
    
    # Get SHA256 hash for the platform with fallback strategies
    sha256 = repository_ctx.attr.sha256 or _get_sha256_for_platform(
        repository_ctx.attr.version, platform
    )
    
    # Download the archive with enhanced error handling
    archive_path = None
    download_success = False
    
    for url in urls:
        output_name = "weaver-{}-{}.{}".format(
            repository_ctx.attr.version, 
            platform, 
            "zip" if url.endswith(".zip") else "tar.xz"
        )
        
        # Download the file
        if sha256:
            result = repository_ctx.download(
                url = url,
                sha256 = sha256,
                output = output_name,
            )
        else:
            # Auto-compute checksum if not provided
            result = repository_ctx.download(
                url = url,
                output = output_name,
            )
            
            # If download succeeded without checksum, compute and cache it
            if result.success and not sha256:
                computed_sha256 = _compute_file_checksum(repository_ctx, output_name)
                if computed_sha256:
                    # Cache the computed checksum for future use
                    _cache_checksum(repository_ctx, repository_ctx.attr.version, platform, computed_sha256)
                    print("Computed and cached checksum for {}: {}".format(platform, computed_sha256))
        
        if result.success:
            archive_path = output_name
            download_success = True
            break
        else:
            print("Failed to download from {}: {}".format(url, result.error))
            continue
    
    if not download_success:
        fail("Failed to download Weaver binary from any URL: {}. Please check network connectivity and try again.".format(urls))
    
    # Extract the archive
    _extract_archive(repository_ctx, archive_path, platform)
    
    # Find the Weaver binary
    binary_path = _find_weaver_binary(repository_ctx, platform)
    
    # Create BUILD file with platform-specific configuration
    build_content = _create_build_file(repository_ctx, binary_path, platform)
    repository_ctx.file("BUILD.bazel", build_content)
    
    # Create platform-specific metadata
    metadata = get_platform_metadata(platform)
    repository_ctx.file("platform_metadata.json", json.encode(metadata))

def _compute_file_checksum(repository_ctx, file_path):
    """Compute SHA256 checksum of a file."""
    
    # Use platform-appropriate checksum command
    if repository_ctx.os.name == "windows":
        # Windows: use PowerShell
        result = repository_ctx.execute([
            "powershell", "-Command", 
            "Get-FileHash -Algorithm SHA256 -Path '{}' | Select-Object -ExpandProperty Hash".format(file_path)
        ])
    else:
        # Unix-like: use shasum
        result = repository_ctx.execute([
            "shasum", "-a", "256", file_path
        ])
    
    if result.return_code != 0:
        print("Warning: Failed to compute checksum: {}".format(result.stderr))
        return None
    
    # Extract checksum from output
    if repository_ctx.os.name == "windows":
        checksum = result.stdout.strip()
    else:
        # shasum output format: "checksum filename"
        checksum = result.stdout.split()[0]
    
    return checksum

def _cache_checksum(repository_ctx, version, platform, checksum):
    """Cache computed checksum for future use."""
    
    # Create a cache file with the checksum
    cache_content = """
# Cached checksum for Weaver {} on {}
# Generated automatically on {}
{}

# Usage: Add this checksum to weaver/checksums.bzl
""".format(
        version,
        platform,
        repository_ctx.execute(["date"]).stdout.strip(),
        checksum
    )
    
    cache_file = "checksum_cache_{}_{}.txt".format(
        version.replace(".", "_"),
        platform.replace("-", "_")
    )
    
    repository_ctx.file(cache_file, cache_content)

def _create_build_file(repository_ctx, binary_path, platform):
    """Create BUILD file with platform-specific configuration."""
    metadata = get_platform_metadata(platform)
    
    return """
# Generated BUILD file for Weaver binary on {platform}

package(default_visibility = ["//visibility:public"])

filegroup(
    name = "weaver_binary",
    srcs = ["{binary_path}"],
    data = ["platform_metadata.json"],
)

filegroup(
    name = "weaver_executable",
    srcs = ["{binary_path}"],
    data = ["platform_metadata.json"],
)

exports_files([
    "{binary_path}",
    "platform_metadata.json",
])

# Platform-specific constraints
platform(
    name = "weaver_platform",
    constraint_values = [
        "{os_constraint}",
        "{cpu_constraint}",
    ],
)

# Toolchain implementation
load("@rules_weaver//weaver:toolchains.bzl", "weaver_toolchain")

weaver_toolchain(
    name = "weaver_toolchain_impl",
    weaver_binary = "{binary_path}",
    version = "{version}",
    platform = "{platform}",
)

# Toolchain configuration
toolchain(
    name = "weaver_toolchain",
    toolchain = ":weaver_toolchain_impl",
    toolchain_type = "//weaver:toolchain_type",
    target_compatible_with = [
        "{os_constraint}",
        "{cpu_constraint}",
    ],
)
""".format(
        platform = platform,
        binary_path = binary_path,
        version = repository_ctx.attr.version,
        os_constraint = metadata["os_constraint"],
        cpu_constraint = metadata["cpu_constraint"],
    )

# Repository rule definition
weaver_repository = repository_rule(
    implementation = _weaver_repository_impl,
    attrs = {
        "version": attr.string(mandatory = True),
        "sha256": attr.string(),
        "urls": attr.string_list(),
    },
)

def weaver_dependencies():
    """Set up Weaver dependencies with multi-platform support."""
    # Add any required dependencies here
    pass

def weaver_register_toolchains():
    """Register Weaver toolchains for all supported platforms."""
    # Register the toolchain from the real_weaver repository
    native.register_toolchains("@rules_weaver//:weaver_toolchain") 