# Bazel OpenTelemetry Weaver Rules

Bazel rules for integrating OpenTelemetry Weaver into your build system. These rules provide hermetic, reproducible builds for semantic convention registry management, code generation, and validation.

## Features

- **Semantic Convention Registry Management**: Declare and manage semantic convention registries
- **Code Generation**: Generate type-safe code from semantic convention registries using Weaver templates
- **Validation**: Validate semantic convention registries against policies
- **Documentation Generation**: Generate documentation from semantic convention registries
- **Multi-Platform Support**: Works on Linux, macOS, and Windows
- **Hermetic Builds**: Ensures reproducible builds across environments
- **Remote Execution Compatible**: Optimized for Bazel remote execution

## Quick Start

### 1. Add to your WORKSPACE file

```python
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# Download the rules
http_archive(
    name = "rules_weaver",
    sha256 = "your_sha256_here",
    strip_prefix = "rules_weaver-main",
    url = "https://github.com/your-org/rules_weaver/archive/main.tar.gz",
)

# Load the rules
load("@rules_weaver//weaver:deps.bzl", "weaver_dependencies")
weaver_dependencies()

# Set up Weaver binary
load("@rules_weaver//weaver:repositories.bzl", "weaver_repository", "weaver_register_toolchains")

weaver_repository(
    name = "weaver",
    version = "0.16.1",
)

weaver_register_toolchains()
```

### 2. Use in your BUILD files

```python
load("@rules_weaver//weaver:defs.bzl", "weaver_generate", "weaver_validate_test")

# Generate code from semantic convention registry
weaver_generate(
    name = "my_generated_code",
    registries = ["//path/to/registry"],
    target = "opentelemetry-proto",
    templates = ["//path/to/templates"],
    args = ["--verbose"],
)

# Validate semantic convention registry
weaver_validate_test(
    name = "validate_my_registry",
    registries = ["//path/to/registry"],
    policies = ["//path/to/policies"],
    weaver_args = ["--strict"],
)
```

## Supported Platforms

- **Linux**: x86_64, aarch64
- **macOS**: x86_64, aarch64 (Apple Silicon)
- **Windows**: x86_64, aarch64

## Documentation

- [API Reference](docs/reference/api_reference.md)
- [Quick Start Guide](docs/getting-started/quick_start.md)
- [Installation Guide](docs/getting-started/installation.md)
- [Developer Guide](docs/developer-guide.md)
- [Migration Guide](docs/troubleshooting/migration_guide.md)
- [Troubleshooting](docs/troubleshooting/troubleshooting.md)

## Project Structure

```
rules_weaver/
├── weaver/                    # Core rules implementation
│   ├── defs.bzl              # Main rule definitions
│   ├── repositories.bzl      # Repository rules for Weaver binary
│   ├── toolchains.bzl        # Toolchain definitions
│   ├── providers.bzl         # Provider definitions
│   └── internal/             # Internal implementation
├── examples/                 # Usage examples
├── tests/                    # Test suite
└── docs/                     # Documentation
```

## Implementation Status

- ✅ **weaver_repository**: Download and set up Weaver binaries
- ✅ **weaver_generate**: Generate code from semantic convention registries
- ✅ **weaver_validate_test**: Validate semantic convention registries
- ✅ **weaver_docs**: Generate documentation (complete)
- ✅ **weaver_library**: Convenience macro (complete)
- ✅ **Core Rule Implementation**: All core rules implemented and tested
- 🔄 **Real Weaver Integration**: Full integration with actual Weaver binaries (next priority)

## Next Steps

- Additional rules for advanced registry management
- Template management and customization
- Policy validation integration
- Performance optimizations for large registries
