# Real Weaver Binary Integration

This document describes how to integrate the Bazel OpenTelemetry Weaver rules with actual Weaver binaries downloaded from GitHub releases, enabling real functionality beyond mock implementations.

## Overview

The Real Weaver Binary Integration provides:

- **Automatic binary downloads** from GitHub releases
- **Multi-platform support** (Linux x86_64/aarch64, macOS x86_64/aarch64, Windows x86_64)
- **Hermetic builds** with SHA256 verification
- **Toolchain resolution** with fallback mechanisms
- **Cross-platform compatibility** for remote execution

## Setup

### 1. Bzlmod Setup (Recommended)

For Bzlmod-enabled workspaces, add the following to your `MODULE.bazel`:

```python
# Weaver binary dependencies
weaver_repository = use_extension(
    "@rules_weaver//weaver:extensions.bzl",
    "weaver_repository",
    dev_dependency = True,
)

weaver_repository.download(
    name = "weaver_binary",
    version = "0.16.1",
    platforms = [
        "linux-x86_64",
        "linux-aarch64", 
        "darwin-x86_64",
        "darwin-aarch64",
        "windows-x86_64",
    ],
)

use_repo(
    weaver_repository,
    "weaver_binary",
)
```

### 2. WORKSPACE Setup (Legacy)

For legacy WORKSPACE-based projects, add the following to your `WORKSPACE`:

```python
load("@rules_weaver//weaver:repositories.bzl", "weaver_dependencies", "weaver_repository", "weaver_register_toolchains")

# Set up Weaver dependencies
weaver_dependencies()

# Real Weaver repository
weaver_repository(
    name = "real_weaver",
    version = "0.16.1",
)

# Register toolchains
weaver_register_toolchains()
```

## Usage

### Basic Usage

Once set up, the rules automatically use real Weaver binaries:

```python
# Schema validation with real Weaver
weaver_validate_test(
    name = "my_validation",
    registries = ["//path/to/schema.yaml"],
    weaver_args = ["--quiet"],
)

# Code generation with real Weaver
weaver_generate(
    name = "my_generated_code",
    registries = ["//path/to/schema.yaml"],
    target = "my-target",
    args = ["--quiet"],
)

# Documentation generation with real Weaver
weaver_docs(
    name = "my_documentation",
    schemas = ["//path/to/schema.yaml"],
    format = "html",
    args = ["--quiet"],
)
```

### Toolchain Resolution

The rules automatically resolve the appropriate Weaver toolchain:

1. **Real toolchain first**: Attempts to use the registered real Weaver toolchain
2. **Explicit binary**: Falls back to explicitly specified Weaver binary
3. **Mock binary**: Creates a mock binary for testing if no real binary is available

### Platform Support

The integration supports the following platforms:

| Platform | Architecture | Binary Name |
|----------|--------------|-------------|
| Linux | x86_64 | `x86_64-unknown-linux-gnu` |
| Linux | aarch64 | `aarch64-unknown-linux-gnu` |
| macOS | x86_64 | `x86_64-apple-darwin` |
| macOS | aarch64 | `aarch64-apple-darwin` |
| Windows | x86_64 | `x86_64-pc-windows-msvc` |

## Configuration

### Version Management

Specify Weaver versions in your repository configuration:

```python
weaver_repository(
    name = "weaver_stable",
    version = "0.16.1",  # Latest stable
)

weaver_repository(
    name = "weaver_latest",
    version = "0.16.1",  # Latest release
)
```

### SHA256 Verification

For enhanced security, provide SHA256 hashes:

```python
weaver_repository(
    name = "weaver_verified",
    version = "0.16.1",
    sha256 = "a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456",
)
```

### Custom URLs

Use custom download URLs if needed:

```python
weaver_repository(
    name = "weaver_custom",
    version = "0.16.1",
    urls = [
        "https://custom.example.com/weaver-0.16.1.tar.xz",
    ],
)
```

## Testing

### Integration Tests

Run integration tests with real Weaver binaries:

```bash
# Run all real Weaver binary tests
bazel test //tests/integration:all_integration_tests --test_tag_filters=real_weaver

# Run specific test categories
bazel test //tests/integration:all_integration_tests --test_tag_filters=integration
bazel test //tests/integration:all_integration_tests --test_tag_filters=performance
bazel test //tests/integration:all_integration_tests --test_tag_filters=error_handling
```

### Test Categories

- **Integration**: Basic functionality tests
- **Performance**: Large schema and performance tests
- **Error Handling**: Invalid schemas and error conditions
- **Platform**: Cross-platform compatibility tests
- **Toolchain**: Toolchain resolution and fallback tests

## Troubleshooting

### Common Issues

#### 1. Binary Download Failures

**Symptoms**: Build fails with download errors

**Solutions**:
- Check network connectivity
- Verify GitHub release availability
- Use custom URLs if needed
- Check platform compatibility

#### 2. Toolchain Resolution Failures

**Symptoms**: Rules fall back to mock binaries

**Solutions**:
- Verify toolchain registration
- Check platform constraints
- Ensure repository setup is correct
- Review error messages in build output

#### 3. Platform Compatibility Issues

**Symptoms**: Build fails on specific platforms

**Solutions**:
- Verify platform support in Weaver releases
- Check architecture compatibility
- Use platform-specific configurations
- Review platform constraint definitions

### Debug Information

Enable debug output to troubleshoot issues:

```bash
# Enable verbose output
bazel build --verbose_failures //your:target

# Check toolchain resolution
bazel query --output=location //weaver:toolchain_type

# Verify repository setup
bazel query --output=location @real_weaver//:weaver_binary
```

### Error Messages

Common error messages and solutions:

| Error | Cause | Solution |
|-------|-------|----------|
| `Failed to download Weaver binary` | Network or URL issues | Check connectivity and URLs |
| `Could not find Weaver binary` | Archive extraction issues | Verify archive format and content |
| `Unsupported platform` | Platform not supported | Check platform compatibility |
| `Toolchain not available` | Toolchain registration issues | Verify toolchain setup |

## Performance Considerations

### Binary Caching

Weaver binaries are cached by Bazel for improved performance:

- **Local cache**: Binaries cached in Bazel cache directory
- **Remote cache**: Compatible with Bazel remote execution
- **Repository cache**: Repository rules cache downloaded files

### Optimization Tips

1. **Use specific versions**: Avoid `latest` to ensure reproducible builds
2. **Leverage remote execution**: Real binaries work with Bazel remote execution
3. **Cache optimization**: Configure appropriate cache settings
4. **Parallel execution**: Multiple rules can use the same binary simultaneously

## Migration from Mock Binaries

### Step-by-Step Migration

1. **Add repository setup** to your `MODULE.bazel` or `WORKSPACE`
2. **Register toolchains** using `weaver_register_toolchains()`
3. **Update rule usage** to remove explicit mock binary references
4. **Test integration** with real Weaver functionality
5. **Verify performance** and adjust as needed

### Backward Compatibility

The integration maintains backward compatibility:

- **Mock fallbacks**: Rules fall back to mock binaries if real binaries unavailable
- **Explicit binaries**: Still support explicitly specified Weaver binaries
- **Gradual migration**: Can migrate rules individually

## Advanced Configuration

### Multiple Versions

Support multiple Weaver versions simultaneously:

```python
# Multiple repositories for different versions
weaver_repository(name = "weaver_v0_16", version = "0.16.1")
weaver_repository(name = "weaver_v0_15", version = "0.15.0")

# Use specific version in rules
weaver_generate(
    name = "generated_v0_16",
    weaver = "@weaver_v0_16//:weaver_binary",
    # ... other attributes
)
```

### Custom Toolchains

Create custom toolchain configurations:

```python
# Custom toolchain with specific configuration
toolchain(
    name = "custom_weaver_toolchain",
    toolchain = ":custom_weaver_toolchain_impl",
    toolchain_type = "//weaver:toolchain_type",
    target_compatible_with = [
        "//constraints:linux",
        "//constraints:x86_64",
    ],
)
```

## Security Considerations

### Binary Verification

- **SHA256 hashes**: Verify binary integrity
- **HTTPS downloads**: Secure download channels
- **Repository isolation**: Isolated repository environments
- **Audit trails**: Bazel provides build audit trails

### Best Practices

1. **Pin versions**: Use specific versions, not `latest`
2. **Verify hashes**: Provide SHA256 hashes when possible
3. **Review sources**: Verify download URLs and sources
4. **Monitor updates**: Regularly update to security patches

## Support

For issues and questions:

1. **Check documentation**: Review this guide and related docs
2. **Run tests**: Verify with integration tests
3. **Debug output**: Enable verbose output for troubleshooting
4. **Community**: Engage with the Bazel and OpenTelemetry communities

## Examples

### Complete Example

```python
# MODULE.bazel
module(name = "my_project")

weaver_repository = use_extension(
    "@rules_weaver//weaver:extensions.bzl",
    "weaver_repository",
)

weaver_repository.download(
    name = "weaver_binary",
    version = "0.16.1",
)

use_repo(weaver_repository, "weaver_binary")

# BUILD.bazel
load("@rules_weaver//weaver:defs.bzl", "weaver_generate", "weaver_validate_test")

weaver_validate_test(
    name = "validate_schemas",
    registries = ["//schemas:my_schema.yaml"],
    weaver_args = ["--quiet"],
)

weaver_generate(
    name = "generate_code",
    registries = ["//schemas:my_schema.yaml"],
    target = "my-target",
    args = ["--quiet"],
)
```

This setup provides a complete real Weaver binary integration with proper toolchain resolution, platform support, and error handling. 