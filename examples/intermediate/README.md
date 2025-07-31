# Intermediate Examples

More complex examples that combine multiple Weaver features. These examples demonstrate common patterns and workflows used in real projects.

## Examples

### weaver_schema_example.bzl
Schema definition and management examples:
- Complex schema definitions with dependencies
- Schema validation and transformation
- Custom schema attributes and metadata
- Schema versioning and compatibility

### weaver_library_example.bzl
Library creation and dependency management:
- Creating reusable Weaver libraries
- Managing dependencies between schemas
- Library packaging and distribution
- Cross-project schema sharing

### weaver_docs_example.bzl
Documentation generation with templates:
- Custom documentation templates
- Multi-format documentation generation
- Template customization and styling
- Documentation deployment workflows

## Usage

Load and use these examples in your BUILD files:

```python
load("//examples/intermediate:weaver_schema_example.bzl", "create_complex_schema")
load("//examples/intermediate:weaver_library_example.bzl", "build_weaver_library")
load("//examples/intermediate:weaver_docs_example.bzl", "generate_custom_docs")
```

## Prerequisites

Before using these examples, make sure you understand:
- Basic Weaver concepts from [Basic Examples](../basic/)
- Bazel build system fundamentals
- Semantic convention registry concepts

## Next Steps

After mastering these intermediate examples, explore:
- [Advanced Examples](../advanced/) for production-ready patterns
- Custom template development
- Performance optimization techniques 