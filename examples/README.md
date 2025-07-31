# Weaver Examples

This directory contains examples demonstrating how to use the Weaver rules for semantic convention registry management, code generation, validation, and documentation generation.

## Organization

Examples are organized by complexity level:

### 📚 [Basic Examples](basic/)
Simple, single-purpose examples that demonstrate core Weaver functionality:
- **weaver_generate_example.bzl** - Basic code generation from schemas
- **weaver_validate_example.bzl** - Simple validation of semantic conventions
- **weaver_repository_example.bzl** - Basic repository management

### 🔧 [Intermediate Examples](intermediate/)
More complex examples that combine multiple features:
- **weaver_schema_example.bzl** - Schema definition and management
- **weaver_library_example.bzl** - Library creation and dependency management
- **weaver_docs_example.bzl** - Documentation generation with templates

### 🚀 [Advanced Examples](advanced/)
Complex, production-ready examples with advanced features:
- **weaver_comprehensive_example.bzl** - Complete workflow demonstrating all features
- **weaver_toolchain_example.bzl** - Custom toolchain configuration
- **multi_platform_example.bzl** - Cross-platform development scenarios
- **dependency_optimization_example.bzl** - Performance optimization techniques

## Getting Started

1. **New to Weaver?** Start with the [basic examples](basic/) to understand core concepts
2. **Building a project?** Check [intermediate examples](intermediate/) for common patterns
3. **Production deployment?** Review [advanced examples](advanced/) for best practices

## Usage

Each example can be loaded and used in your BUILD files:

```python
load("//examples/basic:weaver_generate_example.bzl", "basic_typescript_generation")
load("//examples/advanced:weaver_comprehensive_example.bzl", "weaver_comprehensive_example")
```

## Contributing

When adding new examples:
1. Place them in the appropriate complexity directory
2. Update the corresponding BUILD.bazel file
3. Add a description to this README
4. Follow the existing naming conventions 