# Weaver Toolchain

The `weaver_toolchain` rule registers Weaver binaries as Bazel toolchains, enabling proper integration with Bazel's toolchain system and cross-compilation support.

## Overview

The Weaver toolchain provides:
- Weaver binary registration as a Bazel toolchain
- Toolchain information for consuming rules
- Support for toolchain resolution and selection
- Cross-compilation scenarios
- Platform-specific toolchain selection

## Usage

### Basic Toolchain Definition

```python
load("@rules_weaver//weaver:toolchains.bzl", "weaver_toolchain")

weaver_toolchain(
    name = "my_weaver_toolchain",
    weaver_binary = "//path/to/weaver:binary",
    version = "0.1.0",
    platform = "linux-x86_64",  # Optional, defaults to "auto"
)
```

### Auto Platform Detection

```python
weaver_toolchain(
    name = "auto_platform_toolchain",
    weaver_binary = "//path/to/weaver:binary",
    version = "0.1.0",
    # platform defaults to "auto" and will be auto-detected
)
```

### Platform-Specific Toolchains

```python
# Linux toolchain
weaver_toolchain(
    name = "linux_toolchain",
    weaver_binary = "//tools/weaver:linux_binary",
    version = "0.1.0",
    platform = "linux-x86_64",
)

# macOS toolchain
weaver_toolchain(
    name = "darwin_toolchain",
    weaver_binary = "//tools/weaver:darwin_binary",
    version = "0.1.0",
    platform = "darwin-x86_64",
)

# Windows toolchain
weaver_toolchain(
    name = "windows_toolchain",
    weaver_binary = "//tools/weaver:windows_binary",
    version = "0.1.0",
    platform = "windows-x86_64",
)
```

## Parameters

### Required Parameters

- `name`: The name of the toolchain target
- `weaver_binary`: Label pointing to the Weaver executable file
- `version`: Weaver version string (e.g., "0.1.0")

### Optional Parameters

- `platform`: Target platform identifier (defaults to "auto")
  - Common values: "linux-x86_64", "darwin-x86_64", "windows-x86_64"
  - Use "auto" for automatic platform detection

## Toolchain Information

The toolchain provides the following information through `platform_common.ToolchainInfo`:

- `weaver_binary`: The Weaver executable file
- `version`: Weaver version string
- `platform`: Target platform identifier

## Using Toolchains in Rules

### Accessing Toolchain Information

```python
def _my_rule_impl(ctx):
    # Get the toolchain
    toolchain = ctx.toolchains["@rules_weaver//weaver:toolchain_type"]
    
    # Access toolchain information
    weaver_binary = toolchain.weaver_binary
    version = toolchain.version
    platform = toolchain.platform
    
    # Use the toolchain in your rule implementation
    # ...
```

### Helper Functions

The toolchain module provides helper functions for common operations:

```python
load("@rules_weaver//weaver:toolchains.bzl", 
     "_weaver_binary_path", "_weaver_version", "_weaver_platform")

def _my_rule_impl(ctx):
    binary_path = _weaver_binary_path(ctx)
    version = _weaver_version(ctx)
    platform = _weaver_platform(ctx)
    
    # Use the helper functions
    # ...
```

## Toolchain Registration

### In Repository Rules

Toolchains are typically registered in repository rules:

```python
def _weaver_repository_impl(repository_ctx):
    # Download and extract Weaver binary
    # ...
    
    # Create BUILD file with toolchain
    build_content = """
load("@rules_weaver//weaver:toolchains.bzl", "weaver_toolchain")

weaver_toolchain(
    name = "weaver_toolchain",
    weaver_binary = ":weaver_binary",
    version = "{version}",
    platform = "{platform}",
)
""".format(version = version, platform = platform)
    
    repository_ctx.file("BUILD.bazel", build_content)
```

### Manual Registration

You can also register toolchains manually in your WORKSPACE or BUILD files:

```python
# In WORKSPACE
load("@rules_weaver//weaver:repositories.bzl", "weaver_register_toolchains")

weaver_register_toolchains()

# Or register specific toolchains
native.register_toolchains(
    "//path/to:my_weaver_toolchain",
)
```

## Cross-Platform Support

### Platform Constraints

Toolchains can be configured with platform constraints for cross-compilation:

```python
weaver_toolchain(
    name = "linux_toolchain",
    weaver_binary = "//tools/weaver:linux_binary",
    version = "0.1.0",
    platform = "linux-x86_64",
)

# Use with platform constraints
genrule(
    name = "cross_compile",
    srcs = ["//path/to:schema"],
    outs = ["generated_code"],
    cmd = "$(location //path/to:linux_toolchain) generate $< > $@",
    tools = ["//path/to:linux_toolchain"],
    target_compatible_with = ["@platforms//os:linux"],
)
```

### Multi-Platform Toolchains

For multi-platform builds, you can define multiple toolchains:

```python
# Define toolchains for different platforms
weaver_toolchain(
    name = "weaver_linux",
    weaver_binary = "//tools/weaver:linux",
    version = "0.1.0",
    platform = "linux-x86_64",
)

weaver_toolchain(
    name = "weaver_darwin",
    weaver_binary = "//tools/weaver:darwin",
    version = "0.1.0",
    platform = "darwin-x86_64",
)

weaver_toolchain(
    name = "weaver_windows",
    weaver_binary = "//tools/weaver:windows",
    version = "0.1.0",
    platform = "windows-x86_64",
)

# Register all toolchains
native.register_toolchains(
    "//tools/weaver:weaver_linux",
    "//tools/weaver:weaver_darwin",
    "//tools/weaver:weaver_windows",
)
```

## Error Handling

### Validation

The toolchain rule validates:
- Weaver binary exists and is executable
- Version is properly formatted
- Platform identifier is valid

### Common Errors

1. **Missing Weaver Binary**: Ensure the `weaver_binary` label points to a valid executable
2. **Invalid Version**: Use semantic versioning format (e.g., "0.1.0")
3. **Unsupported Platform**: Use supported platform identifiers

### Debugging

To debug toolchain issues:

```bash
# Check toolchain resolution
bazel query --output=location @rules_weaver//weaver:toolchain_type

# List available toolchains
bazel query --output=location //... --filter=kind(weaver_toolchain, //...)

# Check toolchain constraints
bazel query --output=build //path/to:toolchain
```

## Examples

### Complete Example

```python
# WORKSPACE
load("@rules_weaver//weaver:repositories.bzl", "weaver_dependencies", "weaver_register_toolchains")

weaver_dependencies()
weaver_register_toolchains()

# BUILD.bazel
load("@rules_weaver//weaver:defs.bzl", "weaver_generate")

weaver_generate(
    name = "my_generated_code",
    srcs = ["schema.yaml"],
    format = "typescript",
)
```

### Custom Toolchain

```python
# BUILD.bazel
load("@rules_weaver//weaver:toolchains.bzl", "weaver_toolchain")

# Create a custom Weaver binary
genrule(
    name = "custom_weaver",
    outs = ["weaver_custom"],
    cmd = "cp $(location //external:weaver) $@",
    tools = ["//external:weaver"],
)

# Create toolchain with custom binary
weaver_toolchain(
    name = "custom_toolchain",
    weaver_binary = ":custom_weaver",
    version = "0.1.0",
    platform = "linux-x86_64",
)

# Use custom toolchain
weaver_generate(
    name = "custom_generated",
    srcs = ["schema.yaml"],
    format = "typescript",
)
```

## Best Practices

1. **Version Pinning**: Always specify exact versions for reproducible builds
2. **Platform Detection**: Use "auto" platform detection when possible
3. **Toolchain Registration**: Register toolchains in repository rules for automatic setup
4. **Cross-Platform Testing**: Test toolchains on all supported platforms
5. **Error Handling**: Provide clear error messages for toolchain resolution failures

## Testing

Run toolchain tests:

```bash
# Run all toolchain tests
bazel test //tests:toolchain_test

# Run integration tests
bazel test //tests:toolchain_integration_test

# Test specific platform
bazel test //tests:toolchain_test --platforms=@io_bazel_rules_go//go/toolchain:linux_amd64
``` 