# API Reference

Complete API documentation for all Bazel OpenTelemetry Weaver rules, macros, and providers.

## Rules

### weaver_repository

Downloads and registers Weaver binaries for hermetic Bazel builds.

```python
weaver_repository(
    name,
    version,
    sha256 = None,
    urls = None,
    platform_overrides = {},
    skip_sha256_verification = False,
)
```

#### Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `name` | string | ✅ | - | Repository name |
| `version` | string | ✅ | - | Weaver version to download |
| `sha256` | string | ❌ | None | SHA256 hash for integrity verification |
| `urls` | list | ❌ | None | Custom download URLs |
| `platform_overrides` | dict | ❌ | {} | Platform-specific configuration |
| `skip_sha256_verification` | bool | ❌ | False | Skip SHA256 verification |

#### Example

```python
weaver_repository(
    name = "weaver",
    version = "0.1.0",
    sha256 = "abc123def4567890abcdef1234567890abcdef1234567890abcdef1234567890",
    urls = [
        "https://github.com/open-telemetry/weaver/releases/download/v{version}/weaver-{version}-{platform}.tar.gz",
    ],
    platform_overrides = {
        "linux-x86_64": {
            "sha256": "linux-specific-sha256",
        },
    },
)
```

### weaver_schema

Declares schema files as Bazel targets and provides schema information.

```python
weaver_schema(
    name,
    srcs,
    deps = [],
    visibility = ["//visibility:public"],
)
```

#### Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `name` | string | ✅ | - | Target name |
| `srcs` | list | ✅ | - | Schema source files |
| `deps` | list | ❌ | [] | Schema dependencies |
| `visibility` | list | ❌ | ["//visibility:public"] | Target visibility |

#### Example

```python
weaver_schema(
    name = "my_schemas",
    srcs = ["schema.yaml", "config.json"],
    deps = [":other_schemas"],
    visibility = ["//visibility:public"],
)
```

### weaver_generate

Generates code from schemas using OpenTelemetry Weaver.

```python
weaver_generate(
    name,
    srcs,
    weaver = None,
    args = [],
    env = {},
    out_dir = None,
    format = "typescript",
)
```

#### Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `name` | string | ✅ | - | Target name |
| `srcs` | list | ✅ | - | Schema source files or targets |
| `weaver` | label | ❌ | None | Weaver binary (defaults to toolchain) |
| `args` | list | ❌ | [] | Additional Weaver arguments |
| `env` | dict | ❌ | {} | Environment variables |
| `out_dir` | string | ❌ | None | Output directory |
| `format` | string | ❌ | "typescript" | Output format |

#### Example

```python
weaver_generate(
    name = "my_generated_code",
    srcs = [":my_schemas"],
    format = "typescript",
    args = ["--verbose", "--strict"],
    env = {
        "WEAVER_LOG_LEVEL": "debug",
    },
    out_dir = "generated",
)
```

### weaver_validate

Validates schemas using OpenTelemetry Weaver.

```python
weaver_validate(
    name,
    schemas,
    policies = [],
    weaver = None,
    args = [],
    env = {},
    fail_on_error = True,
)
```

#### Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `name` | string | ✅ | - | Target name |
| `schemas` | list | ✅ | - | Schema files or targets |
| `policies` | list | ❌ | [] | Policy files |
| `weaver` | label | ❌ | None | Weaver binary (defaults to toolchain) |
| `args` | list | ❌ | [] | Additional validation arguments |
| `env` | dict | ❌ | {} | Environment variables |
| `fail_on_error` | bool | ❌ | True | Fail build on validation error |

#### Example

```python
weaver_validate(
    name = "validate_schemas",
    schemas = [":my_schemas"],
    policies = ["policy.yaml"],
    args = ["--strict"],
    fail_on_error = True,
)
```

## Macros

### weaver_library

Convenience macro that combines schema declaration, code generation, and optional validation.

```python
weaver_library(
    name,
    srcs,
    weaver_args = [],
    validation = True,
    **kwargs,
)
```

#### Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `name` | string | ✅ | - | Base name for generated targets |
| `srcs` | list | ✅ | - | Schema source files |
| `weaver_args` | list | ❌ | [] | Weaver generation arguments |
| `validation` | bool | ❌ | True | Create validation target |
| `**kwargs` | dict | ❌ | {} | Additional arguments |

#### Generated Targets

The macro creates three targets:

1. `{name}` - Schema target (weaver_schema)
2. `{name}_generated` - Generated code target (weaver_generate)
3. `{name}_validation` - Validation target (weaver_validate, optional)

#### Example

```python
weaver_library(
    name = "my_schemas",
    srcs = ["schema.yaml"],
    format = "typescript",
    weaver_args = ["--verbose"],
    validation = True,
    policies = ["policy.yaml"],
    visibility = ["//visibility:public"],
)
```

## Providers

### WeaverGeneratedInfo

Information about Weaver-generated files.

```python
WeaverGeneratedInfo(
    generated_files = [],
    output_dir = "",
    source_schemas = [],
    generation_args = [],
)
```

#### Fields

| Field | Type | Description |
|-------|------|-------------|
| `generated_files` | list | List of generated file artifacts |
| `output_dir` | string | Output directory path |
| `source_schemas` | list | Source schema targets |
| `generation_args` | list | Arguments used for generation |

### WeaverValidationInfo

Information about Weaver validation results.

```python
WeaverValidationInfo(
    validation_output = None,
    validated_schemas = [],
    applied_policies = [],
    validation_args = [],
    success = False,
)
```

#### Fields

| Field | Type | Description |
|-------|------|-------------|
| `validation_output` | File | Validation result file artifact |
| `validated_schemas` | list | List of validated schema files |
| `applied_policies` | list | List of applied policy files |
| `validation_args` | list | Arguments used for validation |
| `success` | bool | Whether validation was successful |

### WeaverSchemaInfo

Information about Weaver schema files.

```python
WeaverSchemaInfo(
    schema_files = [],
    schema_content = [],
    dependencies = [],
    metadata = {},
)
```

#### Fields

| Field | Type | Description |
|-------|------|-------------|
| `schema_files` | list | List of schema file artifacts |
| `schema_content` | list | Parsed schema content for validation |
| `dependencies` | list | Transitive schema dependencies |
| `metadata` | dict | Additional schema metadata |

## Functions

### weaver_dependencies()

Sets up dependencies required by Weaver rules.

```python
load("@rules_weaver//weaver:repositories.bzl", "weaver_dependencies")

weaver_dependencies()
```

### weaver_register_toolchains()

Registers Weaver toolchains for the current platform.

```python
load("@rules_weaver//weaver:repositories.bzl", "weaver_register_toolchains")

weaver_register_toolchains()
```

## Toolchain

### WeaverToolchainInfo

Information about the Weaver toolchain.

```python
WeaverToolchainInfo(
    weaver_binary = None,
    version = "",
    platform = "",
)
```

#### Fields

| Field | Type | Description |
|-------|------|-------------|
| `weaver_binary` | File | Weaver binary executable |
| `version` | string | Weaver version |
| `platform` | string | Target platform |

## Supported Formats

### Input Formats

- YAML (`.yaml`, `.yml`)
- JSON (`.json`)

### Output Formats

| Format | Description | File Extensions |
|--------|-------------|-----------------|
| `typescript` | TypeScript interfaces and types | `.ts`, `.d.ts` |
| `go` | Go structs and interfaces | `.go` |
| `python` | Python classes and types | `.py` |
| `java` | Java classes and interfaces | `.java` |
| `rust` | Rust structs and traits | `.rs` |

## Environment Variables

### Weaver-Specific Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `WEAVER_LOG_LEVEL` | Log level (debug, info, warn, error) | `info` |
| `WEAVER_CACHE_DIR` | Cache directory path | `/tmp/weaver-cache` |
| `WEAVER_TEMP_DIR` | Temporary directory path | System temp dir |
| `WEAVER_TIMEOUT` | Operation timeout in seconds | `300` |

### Bazel Variables

| Variable | Description |
|----------|-------------|
| `BAZEL_BUILD_FILE` | Path to BUILD file |
| `BAZEL_WORKSPACE` | Workspace root path |
| `BAZEL_OUTPUT_BASE` | Output base directory |

## Error Handling

### Common Error Types

| Error Type | Description | Resolution |
|------------|-------------|------------|
| `SchemaParseError` | Invalid schema syntax | Fix YAML/JSON syntax |
| `ValidationError` | Schema validation failed | Review schema against spec |
| `GenerationError` | Code generation failed | Check schema format |
| `ToolchainError` | Toolchain not found | Verify toolchain setup |
| `PlatformError` | Unsupported platform | Check platform support |

### Error Recovery

```python
# Handle validation errors gracefully
weaver_validate(
    name = "validate_schemas",
    schemas = [":my_schemas"],
    fail_on_error = False,  # Don't fail build on validation errors
)

# Use test mode for validation
weaver_validate(
    name = "test_validation",
    schemas = [":my_schemas"],
    testonly = True,  # Run as test target
)
```

## Best Practices

### Schema Organization

```python
# Group related schemas
weaver_schema(
    name = "user_schemas",
    srcs = ["user.yaml", "profile.yaml"],
)

weaver_schema(
    name = "product_schemas", 
    srcs = ["product.yaml", "inventory.yaml"],
)

# Reference schemas
weaver_schema(
    name = "all_schemas",
    srcs = ["common.yaml"],
    deps = [":user_schemas", ":product_schemas"],
)
```

### Code Generation

```python
# Generate multiple formats
weaver_generate(
    name = "typescript_types",
    srcs = [":schemas"],
    format = "typescript",
)

weaver_generate(
    name = "go_types",
    srcs = [":schemas"],
    format = "go",
)
```

### Validation

```python
# Separate validation for different concerns
weaver_validate(
    name = "syntax_validation",
    schemas = [":schemas"],
    args = ["--syntax-only"],
)

weaver_validate(
    name = "policy_validation",
    schemas = [":schemas"],
    policies = ["security_policy.yaml"],
)
``` 