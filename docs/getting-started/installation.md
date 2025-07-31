# Installation Guide

This guide will walk you through installing and configuring the Bazel OpenTelemetry Weaver rules in your workspace.

## Prerequisites

- Bazel 5.0 or later
- Python 3.7+ (for some advanced features)
- Git

## Step 1: Add to WORKSPACE

Add the following to your `WORKSPACE` file:

```python
# Load the Weaver rules
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# Download the Weaver rules
http_archive(
    name = "rules_weaver",
    sha256 = "YOUR_SHA256_HERE",  # Replace with actual SHA256
    strip_prefix = "rules_weaver-main",
    url = "https://github.com/open-telemetry/weaver/archive/main.zip",
)

# Load Weaver repository rules
load("@rules_weaver//weaver:repositories.bzl", 
     "weaver_repository", 
     "weaver_dependencies", 
     "weaver_register_toolchains")

# Set up dependencies
weaver_dependencies()

# Download Weaver binary
weaver_repository(
    name = "weaver",
    version = "0.1.0",  # Replace with desired version
    sha256 = "abc123def4567890abcdef1234567890abcdef1234567890abcdef1234567890",  # Replace with actual SHA256
)

# Register toolchains
weaver_register_toolchains()
```

## Step 2: Configure BUILD Files

Add the following to your `BUILD` file or create a new one:

```python
load("@rules_weaver//weaver:defs.bzl", "weaver_schema", "weaver_generate", "weaver_validate", "weaver_library")

# Example: Declare a schema
weaver_schema(
    name = "my_schemas",
    srcs = ["schema.yaml"],
    visibility = ["//visibility:public"],
)

# Example: Generate code from schema
weaver_generate(
    name = "my_generated_code",
    srcs = [":my_schemas"],
    format = "typescript",
    visibility = ["//visibility:public"],
)

# Example: Validate schemas
weaver_validate(
    name = "validate_schemas",
    schemas = [":my_schemas"],
    policies = ["policy.yaml"],
    visibility = ["//visibility:public"],
)

# Example: Use the convenience macro
weaver_library(
    name = "my_library",
    srcs = ["schema.yaml"],
    format = "typescript",
    validation = True,
    visibility = ["//visibility:public"],
)
```

## Step 3: Verify Installation

Test your installation by running:

```bash
# Test that the rules load correctly
bazel query @weaver//...

# Test a simple schema declaration
bazel build //path/to/your:schema_target

# Test code generation
bazel build //path/to/your:generated_target
```

## Configuration Options

### Weaver Repository Configuration

The `weaver_repository` rule supports several configuration options:

```python
weaver_repository(
    name = "weaver",
    version = "0.1.0",
    sha256 = "abc123...",
    
    # Optional: Custom download URLs
    urls = [
        "https://custom.example.com/weaver-{version}-{platform}.tar.gz",
        "https://fallback.example.com/weaver-{version}-{platform}.zip",
    ],
    
    # Optional: Platform-specific overrides
    platform_overrides = {
        "linux-x86_64": {
            "sha256": "linux-specific-sha256",
            "urls": ["https://linux-specific-url"],
        },
        "darwin-aarch64": {
            "sha256": "macos-arm64-specific-sha256",
        },
    },
    
    # Optional: Skip SHA256 verification (not recommended for production)
    skip_sha256_verification = False,
)
```

### Environment Variables

You can configure environment variables for Weaver operations:

```python
weaver_generate(
    name = "my_generated_code",
    srcs = [":my_schemas"],
    env = {
        "WEAVER_LOG_LEVEL": "debug",
        "WEAVER_CACHE_DIR": "/tmp/weaver-cache",
    },
)
```

## Platform Support

The rules support the following platforms:

| Platform | Architecture | Status |
|----------|--------------|--------|
| Linux | x86_64 | ✅ Supported |
| Linux | aarch64 | ✅ Supported |
| macOS | x86_64 | ✅ Supported |
| macOS | aarch64 | ✅ Supported |
| Windows | x86_64 | ✅ Supported |

## Version Compatibility

| Weaver Version | Bazel Version | Status |
|----------------|---------------|--------|
| 0.1.0+ | 5.0+ | ✅ Supported |
| 0.1.0+ | 4.0+ | ⚠️ Limited support |
| < 0.1.0 | Any | ❌ Not supported |

## Troubleshooting Installation

### Common Issues

#### 1. SHA256 Mismatch

**Error**: `SHA256 mismatch for downloaded file`

**Solution**: Update the SHA256 hash in your WORKSPACE file. You can get the correct hash by:

```bash
# Download the file manually and compute SHA256
curl -L <url> | sha256sum
```

#### 2. Platform Detection Issues

**Error**: `Unsupported platform: unknown`

**Solution**: Ensure you're using a supported platform or add platform-specific configuration:

```python
weaver_repository(
    name = "weaver",
    version = "0.1.0",
    sha256 = "abc123...",
    platform_overrides = {
        "your-platform": {
            "sha256": "platform-specific-sha256",
            "urls": ["https://platform-specific-url"],
        },
    },
)
```

#### 3. Network Issues

**Error**: `Failed to download Weaver binary`

**Solution**: 
- Check your network connection
- Verify the download URLs are accessible
- Use custom URLs if needed:

```python
weaver_repository(
    name = "weaver",
    version = "0.1.0",
    urls = [
        "https://your-mirror.com/weaver-{version}-{platform}.tar.gz",
    ],
)
```

#### 4. Permission Issues

**Error**: `Permission denied`

**Solution**: Ensure the downloaded binary is executable:

```python
weaver_repository(
    name = "weaver",
    version = "0.1.0",
    sha256 = "abc123...",
    # The rules should handle this automatically, but you can verify:
    # chmod +x $(bazel info output_base)/external/weaver/weaver
)
```

### Getting Help

If you encounter issues not covered here:

1. Check the [Troubleshooting Guide](troubleshooting.md)
2. Review the [FAQ](faq.md)
3. Search existing [GitHub Issues](https://github.com/open-telemetry/weaver/issues)
4. Create a new issue with:
   - Your Bazel version
   - Your platform (OS + architecture)
   - The complete error message
   - Your WORKSPACE configuration

## Next Steps

After installation, you can:

1. Follow the [Quick Start Guide](quick_start.md) to create your first schema
2. Explore [Basic Examples](examples/basic_usage.md) for common usage patterns
3. Read the [API Reference](api_reference.md) for complete documentation
4. Check out [Advanced Examples](examples/advanced_usage.md) for complex scenarios 