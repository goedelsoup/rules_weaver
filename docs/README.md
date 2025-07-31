# Bazel OpenTelemetry Weaver Rules Documentation

Welcome to the comprehensive documentation for the Bazel OpenTelemetry Weaver rules. This documentation provides everything you need to integrate OpenTelemetry Weaver into your Bazel workspace for hermetic, scalable telemetry schema management and code generation.

## Quick Navigation

### 🚀 [Getting Started](getting-started/)
- [Installation Guide](getting-started/installation.md) - How to set up the rules in your workspace
- [Quick Start Guide](getting-started/quick_start.md) - Get up and running in minutes

### 🔧 [Core Rules](core-rules/)
- [weaver_repository](core-rules/weaver_repository.md) - Download and register Weaver binaries
- [weaver_schema](core-rules/weaver_schema.md) - Declare and manage schema files
- [weaver_generate](core-rules/weaver_generate.md) - Generate code from schemas
- [weaver_validate](core-rules/weaver_validate.md) - Validate schemas and policies
- [weaver_library](core-rules/weaver_library.md) - Convenience macro for common workflows

### 🚀 [Advanced Topics](advanced-topics/)
- [weaver_toolchain](advanced-topics/weaver_toolchain.md) - Using Weaver with Bazel toolchains
- [weaver_docs](advanced-topics/weaver_docs.md) - Documentation generation
- [Multi-Platform Support](advanced-topics/multi_platform_support.md) - Cross-platform compatibility
- [Performance Optimization](advanced-topics/performance_optimization.md) - Best practices for performance
- [Dependency Optimization](advanced-topics/dependency_optimization.md) - Large-scale optimization
- [Remote Execution Optimization](advanced-topics/remote_execution_optimization.md) - Remote execution optimization

### 📚 [Reference](reference/)
- [API Reference](reference/api_reference.md) - Complete API documentation
- [Providers](reference/providers.md) - Information about rule providers

### 🔧 [Troubleshooting](troubleshooting/)
- [Troubleshooting Guide](troubleshooting/troubleshooting.md) - Common issues and solutions
- [FAQ](troubleshooting/faq.md) - Frequently asked questions
- [Migration Guide](troubleshooting/migration_guide.md) - Migrating from manual Weaver usage
- [Contributing Guide](troubleshooting/contributing.md) - How to contribute to the project

### 👨‍💻 [Developer Guide](developer-guide.md) - Technical guide for developers and contributors

### 📖 [Examples](examples/)
- [Basic Usage](examples/basic_usage.md) - Simple examples to get started

## What is OpenTelemetry Weaver?

OpenTelemetry Weaver is a tool for managing OpenTelemetry schemas and generating code from them. The Bazel rules provide:

- **Hermetic Builds**: All dependencies are properly declared for reproducible builds
- **Remote Execution Support**: Optimized for Bazel remote execution
- **Cross-Platform**: Support for Linux, macOS, and Windows
- **Schema Management**: Declare, validate, and manage schema files
- **Code Generation**: Generate type-safe code from schemas
- **Policy Validation**: Validate schemas against policies
- **Toolchain Integration**: Seamless integration with Bazel's toolchain system

## Key Features

### 🔒 Hermetic & Reproducible
- All dependencies are explicitly declared
- SHA256 verification for downloaded binaries
- Platform-specific binary selection
- No external dependencies during build

### 🚀 Remote Execution Optimized
- Efficient binary downloads
- Minimal network transfers
- Platform detection for remote workers
- Optimized for distributed builds

### 🛠️ Developer Friendly
- Simple rule definitions
- Comprehensive error messages
- Integration with existing Bazel workflows
- Extensive documentation and examples

### 🔧 Flexible Configuration
- Custom download URLs
- Platform-specific overrides
- Environment variable support
- Extensible argument passing

## Getting Started

The fastest way to get started is with our [Quick Start Guide](getting-started/quick_start.md), which will have you generating code from schemas in under 5 minutes.

For a complete setup, see the [Installation Guide](getting-started/installation.md).

## Support

- **Issues**: Report bugs and request features on [GitHub](https://github.com/open-telemetry/weaver)
- **Discussions**: Join the conversation in [GitHub Discussions](https://github.com/open-telemetry/weaver/discussions)
- **Documentation**: This comprehensive documentation covers all aspects of the rules

## Contributing

We welcome contributions! Please see our [Contributing Guide](troubleshooting/contributing.md) for details on how to submit patches, report issues, and contribute to the project. 