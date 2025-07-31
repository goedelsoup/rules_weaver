# Providers

This document describes the providers used by the Bazel OpenTelemetry Weaver rules to communicate information about generated artifacts, validation results, and schema dependencies.

## Overview

Providers are Bazel's mechanism for rules to communicate information to other rules and to the build system. The Weaver rules use several providers to share information about:

- Generated code artifacts
- Validation results
- Schema files and dependencies
- Toolchain information

## WeaverGeneratedInfo

Information about Weaver-generated files.

### Definition

```python
WeaverGeneratedInfo = provider(
    doc = "Information about Weaver-generated files",
    fields = {
        "generated_files": "List of generated file artifacts",
        "output_dir": "Output directory path",
        "source_schemas": "Source schema targets",
        "generation_args": "Arguments used for generation",
    },
)
```

### Fields

| Field | Type | Description |
|-------|------|-------------|
| `generated_files` | list | List of generated file artifacts |
| `output_dir` | string | Output directory path |
| `source_schemas` | list | Source schema targets |
| `generation_args` | list | Arguments used for generation |

### Usage

The `weaver_generate` rule returns this provider:

```python
def _weaver_generate_impl(ctx):
    # ... generation logic ...
    
    return [
        WeaverGeneratedInfo(
            generated_files = generated_files,
            output_dir = output_dir,
            source_schemas = schemas,
            generation_args = args,
        ),
        DefaultInfo(
            files = depset(generated_files),
            runfiles = ctx.runfiles(files = generated_files),
        ),
    ]
```

### Accessing Generated Files

Other rules can access generated files through the provider:

```python
def _my_rule_impl(ctx):
    # Get the WeaverGeneratedInfo provider
    weaver_info = ctx.attr.generated_target[WeaverGeneratedInfo]
    
    # Access generated files
    generated_files = weaver_info.generated_files
    
    # Access output directory
    output_dir = weaver_info.output_dir
    
    # Access source schemas
    source_schemas = weaver_info.source_schemas
    
    # Access generation arguments
    generation_args = weaver_info.generation_args
```

## WeaverValidationInfo

Information about Weaver validation results.

### Definition

```python
WeaverValidationInfo = provider(
    doc = "Information about Weaver validation results",
    fields = {
        "validation_output": "Validation result file artifact",
        "validated_schemas": "List of validated schema files",
        "applied_policies": "List of applied policy files",
        "validation_args": "Arguments used for validation",
        "success": "Whether validation was successful",
    },
)
```

### Fields

| Field | Type | Description |
|-------|------|-------------|
| `validation_output` | File | Validation result file artifact |
| `validated_schemas` | list | List of validated schema files |
| `applied_policies` | list | List of applied policy files |
| `validation_args` | list | Arguments used for validation |
| `success` | bool | Whether validation was successful |

### Usage

The `weaver_validate` rule returns this provider:

```python
def _weaver_validate_impl(ctx):
    # ... validation logic ...
    
    return [
        WeaverValidationInfo(
            validation_output = validation_output,
            validated_schemas = schemas,
            applied_policies = policies,
            validation_args = args,
            success = True,  # Will be determined by action execution
        ),
        DefaultInfo(
            files = depset([validation_output]),
            runfiles = ctx.runfiles(files = [validation_output]),
        ),
    ]
```

### Accessing Validation Results

Other rules can access validation results:

```python
def _my_rule_impl(ctx):
    # Get the WeaverValidationInfo provider
    validation_info = ctx.attr.validation_target[WeaverValidationInfo]
    
    # Check if validation was successful
    if not validation_info.success:
        fail("Schema validation failed")
    
    # Access validation output
    validation_output = validation_info.validation_output
    
    # Access validated schemas
    validated_schemas = validation_info.validated_schemas
    
    # Access applied policies
    applied_policies = validation_info.applied_policies
```

## WeaverSchemaInfo

Information about Weaver schema files.

### Definition

```python
WeaverSchemaInfo = provider(
    doc = "Information about Weaver schema files",
    fields = {
        "schema_files": "List of schema file artifacts",
        "schema_content": "Parsed schema content for validation",
        "dependencies": "Transitive schema dependencies",
        "metadata": "Additional schema metadata",
    },
)
```

### Fields

| Field | Type | Description |
|-------|------|-------------|
| `schema_files` | list | List of schema file artifacts |
| `schema_content` | list | Parsed schema content for validation |
| `dependencies` | list | Transitive schema dependencies |
| `metadata` | dict | Additional schema metadata |

### Usage

The `weaver_schema` rule returns this provider:

```python
def _weaver_schema_impl(ctx):
    # ... schema processing logic ...
    
    return [
        WeaverSchemaInfo(
            schema_files = schema_files,
            schema_content = parsed_contents,
            dependencies = transitive_deps,
            metadata = metadata,
        ),
        DefaultInfo(
            files = depset(schema_files + parsed_contents + validation_results + dependency_results),
            runfiles = ctx.runfiles(files = schema_files + parsed_contents + validation_results + dependency_results),
        ),
    ]
```

### Accessing Schema Information

Other rules can access schema information:

```python
def _my_rule_impl(ctx):
    # Get the WeaverSchemaInfo provider
    schema_info = ctx.attr.schema_target[WeaverSchemaInfo]
    
    # Access schema files
    schema_files = schema_info.schema_files
    
    # Access parsed content
    schema_content = schema_info.schema_content
    
    # Access dependencies
    dependencies = schema_info.dependencies
    
    # Access metadata
    metadata = schema_info.metadata
    schema_count = metadata.get("schema_count", 0)
    formats = metadata.get("formats", [])
```

## WeaverToolchainInfo

Information about the Weaver toolchain.

### Definition

```python
WeaverToolchainInfo = provider(
    doc = "Information about the Weaver toolchain",
    fields = {
        "weaver_binary": "Weaver binary executable",
        "version": "Weaver version",
        "platform": "Target platform",
    },
)
```

### Fields

| Field | Type | Description |
|-------|------|-------------|
| `weaver_binary` | File | Weaver binary executable |
| `version` | string | Weaver version |
| `platform` | string | Target platform |

### Usage

The toolchain rule returns this provider:

```python
def _weaver_toolchain_impl(ctx):
    return [
        WeaverToolchainInfo(
            weaver_binary = ctx.file.weaver_binary,
            version = ctx.attr.version,
            platform = ctx.attr.platform,
        ),
    ]
```

### Accessing Toolchain Information

Rules can access toolchain information:

```python
def _my_rule_impl(ctx):
    # Get the toolchain
    toolchain = ctx.toolchains["@rules_weaver//weaver:toolchain_type"]
    
    # Access toolchain info
    weaver_binary = toolchain.weaver_binary
    version = toolchain.version
    platform = toolchain.platform
```

## Provider Usage Examples

### Custom Rule Using Generated Files

```python
def _my_custom_rule_impl(ctx):
    # Get generated files from weaver_generate target
    weaver_info = ctx.attr.generated_target[WeaverGeneratedInfo]
    generated_files = weaver_info.generated_files
    
    # Process generated files
    outputs = []
    for generated_file in generated_files:
        # Create output file
        output = ctx.actions.declare_file(generated_file.basename + ".processed")
        
        # Process the file
        ctx.actions.run(
            inputs = [generated_file],
            outputs = [output],
            executable = ctx.executable.processor,
            arguments = [generated_file.path, output.path],
        )
        outputs.append(output)
    
    return [DefaultInfo(files = depset(outputs))]

my_custom_rule = rule(
    implementation = _my_custom_rule_impl,
    attrs = {
        "generated_target": attr.label(
            providers = [WeaverGeneratedInfo],
            mandatory = True,
        ),
        "processor": attr.label(
            executable = True,
            cfg = "exec",
        ),
    },
)
```

### Custom Rule Using Validation Results

```python
def _validation_processor_impl(ctx):
    # Get validation results
    validation_info = ctx.attr.validation_target[WeaverValidationInfo]
    
    # Check validation success
    if not validation_info.success:
        fail("Validation failed")
    
    # Process validation output
    validation_output = validation_info.validation_output
    
    # Create summary
    summary = ctx.actions.declare_file("validation_summary.txt")
    ctx.actions.write(
        output = summary,
        content = "Validation passed for {} schemas".format(len(validation_info.validated_schemas)),
    )
    
    return [DefaultInfo(files = depset([summary]))]

validation_processor = rule(
    implementation = _validation_processor_impl,
    attrs = {
        "validation_target": attr.label(
            providers = [WeaverValidationInfo],
            mandatory = True,
        ),
    },
)
```

### Custom Rule Using Schema Information

```python
def _schema_analyzer_impl(ctx):
    # Get schema information
    schema_info = ctx.attr.schema_target[WeaverSchemaInfo]
    
    # Analyze schemas
    analysis = ctx.actions.declare_file("schema_analysis.json")
    
    analysis_data = {
        "schema_count": len(schema_info.schema_files),
        "formats": schema_info.metadata.get("formats", []),
        "dependencies": len(schema_info.dependencies),
    }
    
    ctx.actions.write(
        output = analysis,
        content = json.encode(analysis_data),
    )
    
    return [DefaultInfo(files = depset([analysis]))]

schema_analyzer = rule(
    implementation = _schema_analyzer_impl,
    attrs = {
        "schema_target": attr.label(
            providers = [WeaverSchemaInfo],
            mandatory = True,
        ),
    },
)
```

## Provider Dependencies

### Required Providers

When using Weaver rules in your custom rules, specify the required providers:

```python
my_rule = rule(
    implementation = _my_rule_impl,
    attrs = {
        "generated_target": attr.label(
            providers = [WeaverGeneratedInfo],  # Require WeaverGeneratedInfo
            mandatory = True,
        ),
        "validation_target": attr.label(
            providers = [WeaverValidationInfo],  # Require WeaverValidationInfo
            mandatory = True,
        ),
        "schema_target": attr.label(
            providers = [WeaverSchemaInfo],  # Require WeaverSchemaInfo
            mandatory = True,
        ),
    },
)
```

### Optional Providers

For optional dependencies, don't specify providers:

```python
my_rule = rule(
    implementation = _my_rule_impl,
    attrs = {
        "optional_generated": attr.label(
            # No providers specified - optional dependency
        ),
    },
)
```

## Best Practices

### 1. Check Provider Availability

Always check if a provider is available before accessing it:

```python
def _my_rule_impl(ctx):
    if WeaverGeneratedInfo in ctx.attr.target:
        weaver_info = ctx.attr.target[WeaverGeneratedInfo]
        # Use weaver_info
    else:
        # Handle case where provider is not available
        pass
```

### 2. Use Type-Safe Access

Use the provider's fields for type-safe access:

```python
# Good: Type-safe access
generated_files = weaver_info.generated_files

# Avoid: Direct attribute access
generated_files = weaver_info.generated_files  # This is the same, but use the documented field
```

### 3. Handle Missing Data

Provide sensible defaults for optional data:

```python
def _my_rule_impl(ctx):
    weaver_info = ctx.attr.target[WeaverGeneratedInfo]
    
    # Use metadata with defaults
    metadata = weaver_info.metadata or {}
    schema_count = metadata.get("schema_count", 0)
    formats = metadata.get("formats", [])
```

### 4. Document Provider Usage

Document how your custom rules use Weaver providers:

```python
def _my_rule_impl(ctx):
    """
    Implementation of my_rule.
    
    Requires WeaverGeneratedInfo provider from generated_target.
    Uses generated files to create processed output.
    """
    # ... implementation ...
```

## Troubleshooting

### Common Issues

#### Provider Not Found

**Error**: `Target does not have required provider 'WeaverGeneratedInfo'`

**Solution**: Ensure the target provides the required provider:

```python
# Check if target provides the provider
if WeaverGeneratedInfo in ctx.attr.target:
    weaver_info = ctx.attr.target[WeaverGeneratedInfo]
else:
    fail("Target must provide WeaverGeneratedInfo")
```

#### Missing Fields

**Error**: `'WeaverGeneratedInfo' object has no attribute 'field_name'`

**Solution**: Use the correct field names from the provider definition:

```python
# Correct field names
generated_files = weaver_info.generated_files
output_dir = weaver_info.output_dir
source_schemas = weaver_info.source_schemas
generation_args = weaver_info.generation_args
```

#### Type Errors

**Error**: `Expected type 'list' for field 'generated_files'`

**Solution**: Ensure you're using the correct types:

```python
# generated_files is a list
for file in weaver_info.generated_files:
    # Process each file
    
# output_dir is a string
output_path = weaver_info.output_dir
```

## Related Documentation

- [API Reference](api_reference.md) - Complete API documentation
- [Rules Documentation](rules.md) - Detailed rule documentation
- [Examples](examples/) - Usage examples
- [Troubleshooting](troubleshooting.md) - Common issues and solutions 