# weaver_schema Rule

The `weaver_schema` rule declares schema files as Bazel targets and provides schema information to other rules through providers. It performs basic syntax validation and tracks dependencies between schema files.

## Overview

The `weaver_schema` rule is designed to:

- Declare schema files (YAML, JSON) as Bazel targets
- Perform basic syntax validation at analysis time
- Track dependencies between schema files
- Provide schema information through the `WeaverSchemaInfo` provider
- Support integration with other Weaver rules

## Rule Definition

```python
weaver_schema = rule(
    implementation = _weaver_schema_impl,
    attrs = {
        "srcs": attr.label_list(
            mandatory = True,
            allow_files = True,
            doc = "Schema source files (YAML, JSON)",
        ),
        "deps": attr.label_list(
            default = [],
            providers = ["weaver_schema_info"],
            doc = "Schema dependencies",
        ),
        "visibility": attr.string_list(
            default = ["//visibility:public"],
            doc = "Target visibility",
        ),
    },
)
```

## Parameters

### `name` (required)
The target name for the schema rule.

### `srcs` (required)
List of schema source files. Supports YAML (`.yaml`, `.yml`) and JSON (`.json`) files.

### `deps` (optional)
List of schema dependencies. These must be other `weaver_schema` targets.

### `visibility` (optional)
Standard Bazel visibility setting. Defaults to `["//visibility:public"]`.

## Provider: WeaverSchemaInfo

The rule provides the `WeaverSchemaInfo` provider with the following fields:

- `schema_files`: List of schema file artifacts
- `schema_content`: Parsed schema content for validation
- `dependencies`: Transitive schema dependencies
- `metadata`: Additional schema metadata

## Basic Usage

### Simple Schema Declaration

```python
weaver_schema(
    name = "my_schema",
    srcs = ["schema.yaml"],
)
```

### Multiple Schema Files

```python
weaver_schema(
    name = "multi_schema",
    srcs = [
        "service_schema.yaml",
        "config_schema.json",
    ],
)
```

### Schema with Dependencies

```python
weaver_schema(
    name = "base_schema",
    srcs = ["base.yaml"],
)

weaver_schema(
    name = "extended_schema",
    srcs = ["extended.yaml"],
    deps = [":base_schema"],
)
```

## Integration with Other Rules

### Using with weaver_generate

```python
weaver_schema(
    name = "my_schema",
    srcs = ["schema.yaml"],
)

weaver_generate(
    name = "generate_code",
    srcs = [":my_schema"],
    format = "typescript",
)
```

### Using with weaver_validate

```python
weaver_schema(
    name = "my_schema",
    srcs = ["schema.yaml"],
)

weaver_validate(
    name = "validate_schema",
    schemas = [":my_schema"],
    policies = ["policy.yaml"],
)
```

## Schema Validation

The rule performs basic syntax validation at analysis time:

- **YAML files**: Validates YAML syntax using Python's `yaml.safe_load()`
- **JSON files**: Validates JSON syntax using Python's `json.load()`
- **File format detection**: Automatically detects file format based on extension

### Validation Results

Validation results are stored in the `WeaverSchemaInfo` metadata:

```python
metadata = {
    "schema_count": len(schema_files),
    "formats": list(set([f.extension for f in schema_files])),
    "validation_results": [r.path for r in validation_results],
    "dependency_results": [r.path for r in dependency_results],
}
```

## Dependency Tracking

The rule tracks dependencies between schema files:

1. **Direct dependencies**: Specified in the `deps` attribute
2. **Transitive dependencies**: Automatically collected from dependent schemas
3. **Dependency extraction**: Parses schema files for import/reference patterns

### Dependency Patterns

The rule looks for common dependency patterns:

- **YAML**: `$ref`, `import`, `include` patterns
- **JSON**: `$ref` patterns

## Error Handling

The rule provides clear error messages for:

- Invalid schema syntax
- Missing dependency files
- Circular dependency detection
- Unsupported file formats

## Examples

### Complex Schema Hierarchy

```python
# Core schema
weaver_schema(
    name = "core_schema",
    srcs = ["core.yaml"],
)

# Service schema depends on core
weaver_schema(
    name = "service_schema",
    srcs = ["service.yaml"],
    deps = [":core_schema"],
)

# API schema depends on service
weaver_schema(
    name = "api_schema",
    srcs = ["api.yaml"],
    deps = [":service_schema"],
)

# Generate code from complete hierarchy
weaver_generate(
    name = "generate_api",
    srcs = [":api_schema"],
    format = "typescript",
)
```

### Mixed Format Schemas

```python
# YAML schema
weaver_schema(
    name = "yaml_schema",
    srcs = ["config.yaml"],
)

# JSON schema
weaver_schema(
    name = "json_schema",
    srcs = ["metadata.json"],
)

# Combined schema target
weaver_schema(
    name = "mixed_schema",
    srcs = [
        ":yaml_schema",
        ":json_schema",
    ],
)
```

## Testing

The rule includes comprehensive tests:

- **Unit tests**: Test basic functionality and validation
- **Integration tests**: Test with real schema files and dependencies
- **Error scenario tests**: Test error handling and edge cases

Run tests with:

```bash
bazel test //tests:schema_test
bazel test //tests:schema_integration_test
```

## Best Practices

1. **Use descriptive names**: Choose meaningful target names that reflect the schema content
2. **Organize dependencies**: Structure schema dependencies logically
3. **Validate early**: Use the rule's built-in validation to catch issues early
4. **Document schemas**: Include documentation in schema files
5. **Test thoroughly**: Write tests for complex schema hierarchies

## Limitations

- Basic syntax validation only (complex semantic validation deferred to execution time)
- Limited dependency pattern recognition
- No support for circular dependency resolution
- Schema format support limited to YAML and JSON

## Future Enhancements

- Enhanced dependency pattern recognition
- Circular dependency detection and resolution
- More sophisticated schema validation
- Support for additional schema formats
- Schema inheritance and composition features 