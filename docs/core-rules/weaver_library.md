# Weaver Library Macro

The `weaver_library` macro is a convenience macro that combines schema declaration, code generation, and optional validation into a single, easy-to-use interface for developers.

## Overview

The `weaver_library` macro creates multiple targets with proper dependencies:

- `{name}`: Main schema target (weaver_schema)
- `{name}_generated`: Generated code target (weaver_generate)
- `{name}_validation`: Validation target (weaver_validate, optional)

## Usage

### Basic Usage

```python
load("//weaver:defs.bzl", "weaver_library")

weaver_library(
    name = "my_schemas",
    srcs = ["schema.yaml"],
)
```

This creates three targets:
- `my_schemas`: Schema target
- `my_schemas_generated`: Generated code target
- `my_schemas_validation`: Validation target

### With Custom Arguments

```python
weaver_library(
    name = "my_schemas",
    srcs = ["schema.yaml"],
    weaver_args = [
        "--verbose",
        "--format", "typescript",
        "--output-format", "es6",
    ],
)
```

### Without Validation

```python
weaver_library(
    name = "my_schemas",
    srcs = ["schema.yaml"],
    validation = False,
)
```

This creates only two targets:
- `my_schemas`: Schema target
- `my_schemas_generated`: Generated code target

### With Validation Policies

```python
weaver_library(
    name = "my_schemas",
    srcs = ["schema.yaml"],
    policies = ["policy.yaml"],
    weaver_args = ["--verbose"],
)
```

### With Custom Output Format

```python
weaver_library(
    name = "my_schemas",
    srcs = ["schema.yaml"],
    format = "go",
    weaver_args = ["--package", "myapp"],
)
```

### With Custom Output Directory

```python
weaver_library(
    name = "my_schemas",
    srcs = ["schema.yaml"],
    out_dir = "my_generated_code",
    weaver_args = ["--verbose"],
)
```

### With Dependencies

```python
# Base schema
weaver_library(
    name = "base_schemas",
    srcs = ["base.yaml"],
)

# Extended schema with dependency
weaver_library(
    name = "extended_schemas",
    srcs = ["extended.yaml"],
    deps = [":base_schemas"],
    weaver_args = ["--verbose"],
)
```

### With Environment Variables

```python
weaver_library(
    name = "my_schemas",
    srcs = ["schema.yaml"],
    env = {
        "DEBUG": "1",
        "LOG_LEVEL": "info",
    },
    weaver_args = ["--log-level", "debug"],
)
```

### Comprehensive Example

```python
weaver_library(
    name = "comprehensive_library",
    srcs = [
        "service_schema.yaml",
        "config_schema.json",
    ],
    deps = [":base_schemas"],
    weaver_args = [
        "--verbose",
        "--format", "typescript",
        "--output-format", "es6",
    ],
    format = "typescript",
    out_dir = "generated_api",
    env = {
        "DEBUG": "1",
        "LOG_LEVEL": "info",
    },
    policies = [
        "api_policy.yaml",
        "security_policy.yaml",
    ],
    fail_on_error = True,
    visibility = ["//visibility:public"],
)
```

## Parameters

### Required Parameters

- `name`: Base name for generated targets
- `srcs`: Schema source files (YAML, JSON)

### Optional Parameters

- `weaver_args`: Weaver generation arguments (default: `[]`)
- `validation`: Whether to create validation target (default: `True`)

### Additional Parameters

The macro accepts additional parameters that are distributed to the appropriate underlying rules:

#### Schema Parameters (weaver_schema)
- `deps`: Schema dependencies

#### Generation Parameters (weaver_generate)
- `format`: Output format (default: "typescript")
- `out_dir`: Output directory
- `env`: Environment variables
- `weaver`: Custom Weaver binary

#### Validation Parameters (weaver_validate)
- `policies`: Policy files for validation
- `fail_on_error`: Whether to fail build on validation error
- `testonly`: Whether the validation target is test-only

#### Common Parameters
- `visibility`: Target visibility (applied to all generated targets)

## Target Dependencies

The macro establishes the following dependency relationships:

```
{name}_generated -> {name} (schema dependency)
{name}_validation -> {name} (schema dependency)
```

This ensures that:
- Generated code targets have access to schema files
- Validation targets can validate the schema files
- Proper transitive dependency handling

## Error Handling

The macro provides clear error messages for:
- Missing required parameters (`name`, `srcs`)
- Invalid parameter combinations
- Dependency resolution failures

## Examples

See the `examples/weaver_library_example.bzl` file for comprehensive usage examples.

## Testing

The macro includes comprehensive test coverage:
- Unit tests in `tests/library_test.bzl`
- Integration tests in `tests/library_integration_test.bzl`
- Sample BUILD files in `tests/schemas/BUILD_library_example.bzl` 