# Dependency Optimization

This document describes the dependency optimization features available in the Bazel OpenTelemetry Weaver rules, including transitive dependency tracking, change detection optimization, and file group operations.

## Overview

The dependency optimization features provide:

- **Automatic dependency discovery** using aspects
- **Transitive dependency tracking** for efficient incremental builds
- **Change detection optimization** to minimize unnecessary rebuilds
- **File group operations** for efficient batch processing
- **Circular dependency detection** to prevent build issues

## Core Components

### Aspects

The dependency optimization system uses three main aspects:

#### `weaver_schema_aspect`

Automatically discovers and tracks dependencies between schema files:

```python
load("//weaver:aspects.bzl", "weaver_schema_aspect")

weaver_schema(
    name = "my_schemas",
    srcs = ["schema1.yaml", "schema2.yaml"],
    deps = [":base_schemas"],
)
```

#### `weaver_file_group_aspect`

Tracks dependencies for file groups containing related schemas:

```python
load("//weaver:aspects.bzl", "weaver_file_group_aspect")

filegroup(
    name = "schema_group",
    srcs = glob(["schemas/**/*.yaml"]),
)
```

#### `weaver_change_detection_aspect`

Provides optimized change detection for incremental builds:

```python
load("//weaver:aspects.bzl", "weaver_change_detection_aspect")

weaver_generate(
    name = "generated_code",
    schemas = [":my_schemas"],
)
```

### Dependency Utilities

The `dependency_utils` module provides core functionality:

```python
load("//weaver:internal/utils.bzl", "dependency_utils")

# Extract dependencies from schema files
deps = dependency_utils.extract_schema_dependencies(ctx, schema_file)

# Build transitive dependency graph
graph = dependency_utils.build_transitive_dependency_graph(dependency_graph, transitive_deps)

# Detect circular dependencies
circular_deps = dependency_utils.detect_circular_dependencies(dependency_graph)

# Create change detection data
change_data = dependency_utils.create_change_detection_data(schema_files)
```

## Usage Examples

### Basic Dependency Tracking

```python
load("//weaver:defs.bzl", "weaver_schema")

# Create schema targets with automatic dependency tracking
weaver_schema(
    name = "base_schemas",
    srcs = [
        "schemas/base/common.yaml",
        "schemas/base/types.yaml",
    ],
)

weaver_schema(
    name = "api_schemas",
    srcs = [
        "schemas/api/endpoints.yaml",
        "schemas/api/requests.yaml",
    ],
    deps = [":base_schemas"],  # Dependencies are automatically tracked
)
```

### File Group Optimization

```python
load("//weaver:defs.bzl", "weaver_schema")

# Create schema groups for efficient batch operations
weaver_schema(
    name = "auth_schemas",
    srcs = glob(["schemas/auth/*.yaml"]),
)

weaver_schema(
    name = "data_schemas",
    srcs = glob(["schemas/data/*.yaml"]),
)

# Create a file group for all schemas
filegroup(
    name = "all_schemas",
    srcs = [
        ":auth_schemas",
        ":data_schemas",
    ],
)
```

### Large-Scale Optimization

For large schema sets, use schema collections:

```python
load("//examples:dependency_optimization_example.bzl", "weaver_schema_collection")

# Create organized schema collections
weaver_schema_collection(
    name = "service_schemas",
    schema_groups = {
        "auth": glob(["schemas/auth/*.yaml"]),
        "data": glob(["schemas/data/*.yaml"]),
        "config": glob(["schemas/config/*.yaml"]),
    },
    deps = [":base_schemas"],
)
```

## Performance Optimization

### Analysis Time Requirements

The dependency optimization features are designed to maintain fast analysis times:

- **Typical BUILD files**: Analysis time under 100ms
- **Large schema sets**: Analysis time under 5 seconds for 1000 schemas
- **Dependency graph construction**: Under 1 second for 500 nodes
- **Circular dependency detection**: Under 500ms for 100 nodes

### Memory Usage Optimization

The system uses several techniques to minimize memory usage:

- **Content hash caching** to avoid repeated computations
- **Streaming file processing** to handle large files efficiently
- **Lazy evaluation** where possible
- **Efficient data structures** for dependency tracking

### Change Detection Optimization

Change detection is optimized to trigger rebuilds only when necessary:

- **Content-based hashing** for accurate change detection
- **Incremental validation** to avoid full revalidation
- **Dependency graph caching** to speed up analysis
- **Selective invalidation** based on dependency relationships

## Best Practices

### Schema Organization

1. **Group related schemas** in the same directory
2. **Use clear dependency relationships** between schema groups
3. **Avoid circular dependencies** by designing clear hierarchies
4. **Keep schema files focused** on specific concerns

### Performance Guidelines

1. **Use file groups** for related schemas to enable batch operations
2. **Leverage schema collections** for large-scale projects
3. **Monitor analysis times** and optimize if they exceed requirements
4. **Use dependency tracking aspects** consistently across your project

### Dependency Management

1. **Explicitly declare dependencies** between schema targets
2. **Use transitive dependencies** to avoid manual dependency management
3. **Monitor circular dependency warnings** and resolve them promptly
4. **Group related dependencies** to improve build efficiency

## Troubleshooting

### Common Issues

#### Circular Dependencies

If you encounter circular dependency errors:

```bash
# Check for circular dependencies
bazel build --aspects //weaver:aspects.bzl%weaver_schema_aspect //path/to:target
```

#### Performance Issues

If analysis times are too slow:

1. **Check schema file sizes** and consider splitting large files
2. **Review dependency relationships** and remove unnecessary dependencies
3. **Use file groups** to enable batch operations
4. **Monitor memory usage** and optimize if needed

#### Change Detection Problems

If rebuilds are not triggered when expected:

1. **Verify content hashes** are being computed correctly
2. **Check dependency relationships** are properly declared
3. **Ensure aspects are applied** to relevant targets
4. **Review change detection data** for accuracy

### Debugging

Enable debug output for dependency tracking:

```python
weaver_schema(
    name = "debug_schemas",
    srcs = ["schema.yaml"],
    enable_dependency_debug = True,  # Enable debug output
)
```

## Integration with Existing Rules

The dependency optimization features integrate seamlessly with existing Weaver rules:

### weaver_schema

```python
weaver_schema(
    name = "optimized_schemas",
    srcs = ["schema.yaml"],
    deps = [":base_schemas"],
    # Dependency tracking is automatically enabled
)
```

### weaver_generate

```python
weaver_generate(
    name = "generated_code",
    schemas = [":optimized_schemas"],
    # Change detection optimization is automatically applied
)
```

### weaver_validate

```python
weaver_validate(
    name = "validation",
    schemas = [":optimized_schemas"],
    # Incremental validation is automatically enabled
)
```

## Advanced Usage

### Custom Dependency Extraction

For custom schema formats, you can extend dependency extraction:

```python
def custom_dependency_extractor(ctx, schema_file):
    """Custom dependency extraction for specific schema format."""
    # Implement custom dependency extraction logic
    return ["dependency1.yaml", "dependency2.yaml"]

# Use in aspect implementation
deps = custom_dependency_extractor(ctx, schema_file)
```

### Performance Monitoring

Monitor dependency optimization performance:

```python
weaver_schema(
    name = "monitored_schemas",
    srcs = ["schema.yaml"],
    enable_performance_monitoring = True,  # Enable performance metrics
)
```

## Migration Guide

### From Basic Rules

If you're migrating from basic Weaver rules:

1. **Add dependency declarations** to existing schema targets
2. **Group related schemas** using file groups
3. **Enable aspects** for automatic dependency tracking
4. **Monitor performance** and optimize as needed

### From Manual Dependency Management

If you're migrating from manual dependency management:

1. **Remove manual dependency tracking** code
2. **Use automatic dependency discovery** via aspects
3. **Leverage transitive dependencies** instead of manual tracking
4. **Enable change detection optimization** for better performance

## Conclusion

The dependency optimization features provide powerful tools for managing complex schema dependencies while maintaining excellent performance characteristics. By following the best practices outlined in this document, you can achieve efficient, maintainable schema management in your Bazel projects. 