# weaver_repository Rule

The `weaver_repository` rule downloads and registers OpenTelemetry Weaver binaries for hermetic Bazel builds.

## Overview

This rule automatically detects the current platform, downloads the appropriate Weaver binary, verifies its integrity, and creates the necessary BUILD files for use in your Bazel workspace.

## Features

- **Automatic Platform Detection**: Supports Linux (x86_64, aarch64), macOS (x86_64, aarch64), and Windows (x86_64)
- **SHA256 Integrity Verification**: Optional but recommended for production builds
- **Custom Download URLs**: Support for custom download sources with fallback URLs
- **Platform-Specific Overrides**: Fine-grained control over platform-specific settings
- **Toolchain Integration**: Seamless integration with Bazel's toolchain system
- **Hermetic Builds**: All dependencies are properly declared for reproducible builds

## Usage

### Basic Usage

```python
load("@rules_weaver//weaver:repositories.bzl", "weaver_repository")

weaver_repository(
    name = "weaver",
    version = "0.1.0",
)
```

### With SHA256 Verification

```python
weaver_repository(
    name = "weaver",
    version = "0.1.0",
    sha256 = "abc123def4567890abcdef1234567890abcdef1234567890abcdef1234567890",
)
```

### With Custom Download URLs

```python
weaver_repository(
    name = "weaver",
    version = "0.1.0",
    urls = [
        "https://example.com/weaver-0.1.0.tar.gz",
        "https://backup.example.com/weaver-0.1.0.tar.gz",
    ],
)
```

### With Platform-Specific Overrides

```python
weaver_repository(
    name = "weaver",
    version = "0.1.0",
    platform_overrides = {
        "linux-x86_64": {
            "urls": ["https://custom-linux-url.com/weaver.tar.gz"],
            "sha256": "def456...",
        },
        "darwin-aarch64": {
            "sha256": "ghi789...",
        },
    },
)
```

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `name` | string | Yes | Repository name |
| `version` | string | Yes | Weaver version to download |
| `sha256` | string | No | SHA256 hash for integrity verification |
| `urls` | list of strings | No | Custom download URLs (overrides defaults) |
| `platform_overrides` | dict | No | Platform-specific configuration overrides |

## Supported Platforms

The rule automatically detects and supports the following platforms:

- **Linux**: `x86_64`, `aarch64`
- **macOS**: `x86_64`, `aarch64`
- **Windows**: `x86_64`

## Default Download URLs

If no custom URLs are provided, the rule uses the following default URLs:

```
https://github.com/open-telemetry/weaver/releases/download/v{VERSION}/weaver-{VERSION}-{PLATFORM}.tar.gz
https://github.com/open-telemetry/weaver/releases/download/v{VERSION}/weaver-{VERSION}-{PLATFORM}.zip
```

Where:
- `{VERSION}` is the specified version
- `{PLATFORM}` is the detected platform (e.g., `linux-amd64`, `darwin-arm64`)

## Generated Targets

The rule creates the following targets:

- `@weaver//:weaver_binary` - Filegroup containing the Weaver binary and related files
- `@weaver//:weaver_toolchain` - Toolchain for Weaver operations

## Integration with Toolchains

To use the downloaded Weaver binary in your rules, register the toolchain:

```python
load("@rules_weaver//weaver:repositories.bzl", "weaver_register_toolchains")

weaver_register_toolchains()
```

Then in your rule implementation:

```python
load("@rules_weaver//weaver:toolchains.bzl", "_get_weaver_toolchain")

def _my_rule_impl(ctx):
    toolchain = _get_weaver_toolchain(ctx)
    weaver_binary = toolchain.weaver_binary
    
    # Use weaver_binary in your action
    ctx.actions.run(
        executable = weaver_binary,
        # ... other action parameters
    )
```

## Error Handling

The rule provides clear error messages for common issues:

- **Unsupported platform**: Fails with platform detection error
- **Download failure**: Fails with network or file access error
- **SHA256 mismatch**: Fails with integrity verification error
- **Binary not found**: Fails with detailed file listing for debugging
- **Invalid version**: Fails with version format error

## Binary Detection

The rule automatically searches for Weaver binaries using the following patterns:

1. `weaver` (exact match)
2. `weaver.exe` (Windows)
3. `opentelemetry-weaver`
4. `otlp-weaver`
5. `weaver-*` (wildcard match)
6. `opentelemetry-weaver-*` (wildcard match)

## Best Practices

1. **Always provide SHA256**: For production builds, always specify the `sha256` parameter to ensure binary integrity.

2. **Use version pinning**: Pin to specific versions rather than using floating versions to ensure reproducible builds.

3. **Provide fallback URLs**: When using custom URLs, provide multiple sources for redundancy.

4. **Test on all platforms**: Ensure your configuration works on all supported platforms.

5. **Use platform overrides**: For environments with specific requirements, use platform overrides to customize behavior.

## Complete Example

```python
# WORKSPACE
load("@rules_weaver//weaver:repositories.bzl", 
     "weaver_repository", 
     "weaver_dependencies", 
     "weaver_register_toolchains")

weaver_dependencies()

weaver_repository(
    name = "weaver",
    version = "0.1.0",
    sha256 = "abc123def4567890abcdef1234567890abcdef1234567890abcdef1234567890",
)

weaver_register_toolchains()

# BUILD
load("@rules_weaver//weaver:defs.bzl", "weaver_generate")

weaver_generate(
    name = "generate_typescript",
    srcs = ["schema.yaml"],
    format = "typescript",
    out_dir = "generated",
)
```

## Troubleshooting

### Binary Not Found

If the rule fails with "Weaver binary not found", check:

1. The downloaded archive structure
2. The binary naming convention
3. The archive format (tar.gz vs zip)

### Platform Detection Issues

If platform detection fails, verify:

1. The operating system is supported
2. The architecture is supported
3. The `repository_ctx.os` information is correct

### Download Failures

For download failures:

1. Check network connectivity
2. Verify the URLs are accessible
3. Ensure the version exists in the repository
4. Try alternative URLs or mirrors 