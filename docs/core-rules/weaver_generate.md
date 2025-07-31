# weaver_generate Rule

The `weaver_generate` rule generates code from OpenTelemetry schemas using the Weaver tool with full hermeticity and proper dependency tracking.

## Overview

This rule creates a hermetic action that generates code from schema files using the OpenTelemetry Weaver tool. The generated files are made available through the `WeaverGeneratedInfo` provider and can be consumed by other Bazel rules.

## Basic Usage

```python
load("//weaver:defs.bzl", "weaver_generate")

weaver_generate(
    name = "my_generated_code",
    srcs = ["schema.yaml"],
    format = "typescript",
)
```

## Parameters

### Required Parameters

- **`name`**: Target name (required)
- **`srcs`**: Schema source files or schema targets (required)

### Optional Parameters

- **`weaver`**: Weaver binary (optional, defaults to toolchain)
- **`args`**: Additional Weaver arguments (optional)
- **`env`**: Environment variables (optional)
- **`out_dir`**: Output directory (optional, defaults to `{name}_generated`)
- **`format`**: Output format (default: "typescript")
- **`visibility`**: Standard Bazel visibility (optional)

## Examples

### Basic TypeScript Generation

```python
weaver_generate(
    name = "basic_generated",
    srcs = ["schema.yaml"],
    format = "typescript",
)
```

### Multiple Schemas

```python
weaver_generate(
    name = "multiple_generated",
    srcs = [
        "service_schema.yaml",
        "database_schema.yaml",
    ],
    format = "typescript",
    args = ["--verbose"],
)
```

### Custom Output Directory

```python
weaver_generate(
    name = "custom_output",
    srcs = ["schema.yaml"],
    format = "typescript",
    out_dir = "my_custom_output",
)
```

### With Environment Variables

```python
weaver_generate(
    name = "env_generated",
    srcs = ["schema.yaml"],
    format = "typescript",
    env = {
        "DEBUG": "1",
        "LOG_LEVEL": "info",
    },
    args = ["--log-level", "debug"],
)
```

### Custom Arguments

```python
weaver_generate(
    name = "custom_args_generated",
    srcs = ["schema.yaml"],
    format = "typescript",
    args = [
        "--verbose",
        "--no-cache",
        "--output-format", "es6",
    ],
)
```

## Provider: WeaverGeneratedInfo

The rule provides a `WeaverGeneratedInfo` provider with the following fields:

- **`generated_files`**: List of generated file artifacts
- **`output_dir`**: Output directory path
- **`source_schemas`**: Source schema targets
- **`generation_args`**: Arguments used for generation

### Accessing Generated Files

```python
# In a consuming rule
def _my_rule_impl(ctx):
    weaver_info = ctx.attr.generated_target[WeaverGeneratedInfo]
    
    # Access generated files
    generated_files = weaver_info.generated_files
    
    # Access output directory
    output_dir = weaver_info.output_dir
    
    # Access source schemas
    source_schemas = weaver_info.source_schemas
```

## Hermeticity

The rule ensures full hermeticity by:

- Declaring all inputs explicitly in the `inputs` parameter
- Declaring all outputs explicitly in the `outputs` parameter
- Using `use_default_shell_env = False`
- Requiring all environment variables to be explicitly declared

## Toolchain Integration

The rule automatically resolves the Weaver toolchain and uses the appropriate binary for the current platform. The toolchain must be registered in your `WORKSPACE` file.

## Error Handling

The rule provides clear error messages for:

- Missing schema files
- Weaver command failures
- Invalid format specifications
- Toolchain resolution failures

## Testing

The rule includes comprehensive tests for:

- Basic functionality
- Hermeticity verification
- Output file determination
- Provider creation
- Integration scenarios

Run the tests with:

```bash
bazel test //tests:generate_test
bazel test //tests:generate_integration_test
``` 