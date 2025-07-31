# Developer Guide

This guide is for developers who want to understand, extend, or contribute to the Bazel OpenTelemetry Weaver rules. It covers the internal architecture, development patterns, and how to work with the codebase effectively.

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Core Components](#core-components)
- [Development Patterns](#development-patterns)
- [Extending the Rules](#extending-the-rules)
- [Testing Strategies](#testing-strategies)
- [Performance Considerations](#performance-considerations)
- [Debugging](#debugging)
- [Common Development Tasks](#common-development-tasks)

## Architecture Overview

The Bazel OpenTelemetry Weaver rules are built around several key architectural principles:

### 1. Hermetic Builds
All dependencies are explicitly declared and downloaded during the build process. No external dependencies are required at runtime.

### 2. Toolchain-Based Design
The rules use Bazel's toolchain system to provide platform-specific Weaver binaries and configurations.

### 3. Provider-Based Communication
Rules communicate through Bazel providers, allowing for loose coupling and extensibility.

### 4. Action-Based Execution
All Weaver operations are implemented as Bazel actions, ensuring proper dependency tracking and caching.

## Core Components

### 1. Repository Rules (`repositories.bzl`)

Repository rules handle downloading and setting up Weaver binaries:

```python
# Key functions:
weaver_repository()          # Downloads Weaver binary for specific platform
weaver_register_toolchains() # Registers toolchains for all platforms
```

**Key Features:**
- Platform detection and binary selection
- SHA256 verification for security
- Support for custom download URLs
- Environment variable overrides

### 2. Toolchain System (`toolchains.bzl`, `toolchain_type.bzl`)

The toolchain system provides platform-specific Weaver configurations:

```python
# Toolchain type definition
weaver_toolchain_type = toolchain_type(
    name = "weaver_toolchain_type",
    doc = "Toolchain for OpenTelemetry Weaver operations",
)

# Toolchain rule
weaver_toolchain = rule(
    implementation = _weaver_toolchain_impl,
    attrs = {
        "weaver_binary": attr.label(
            mandatory = True,
            allow_single_file = True,
            executable = True,
            cfg = "exec",
        ),
        "weaver_version": attr.string(mandatory = True),
        "platform_constraints": attr.label_list(
            default = [],
            providers = [PlatformConstraintSetInfo],
        ),
    },
    provides = [WeaverToolchainInfo],
)
```

### 3. Main Rules (`defs.bzl`)

The main rules implement the core functionality:

- `weaver_generate`: Generate code from semantic convention registries
- `weaver_validate_test`: Validate registries against policies
- `weaver_docs`: Generate documentation from registries
- `weaver_library`: Convenience macro for common workflows

### 4. Internal Implementation (`internal/`)

The internal directory contains shared implementation details:

- `actions.bzl`: Action creation and execution
- `utils.bzl`: Common utility functions
- `performance.bzl`: Performance optimization utilities
- `monitoring.bzl`: Build monitoring and metrics

### 5. Providers (`providers.bzl`)

Providers define the data structures used for rule communication:

```python
WeaverGeneratedInfo = provider(
    doc = "Information about generated Weaver artifacts",
    fields = {
        "generated_files": "List of generated files",
        "output_dir": "Output directory for generated files",
        "source_schemas": "Source schema files used for generation",
        "generation_args": "Arguments passed to Weaver",
    },
)

WeaverToolchainInfo = provider(
    doc = "Information about Weaver toolchain",
    fields = {
        "weaver_binary": "Path to Weaver binary",
        "weaver_version": "Weaver version",
        "platform_constraints": "Platform constraints",
    },
)
```

## Development Patterns

### 1. Rule Implementation Pattern

All rules follow a consistent implementation pattern:

```python
def _rule_name_impl(ctx):
    """Implementation of rule_name rule."""
    
    # 1. Validate inputs
    _validate_inputs(ctx)
    
    # 2. Get toolchain
    toolchain = ctx.toolchains["@rules_weaver//weaver:toolchain_type"].weaver_toolchain_info
    
    # 3. Prepare inputs
    inputs = _prepare_inputs(ctx)
    
    # 4. Create action
    outputs = _create_action(ctx, toolchain, inputs)
    
    # 5. Return providers
    return [
        SomeProviderInfo(
            # provider fields
        ),
        DefaultInfo(files = depset(outputs)),
    ]

rule_name = rule(
    implementation = _rule_name_impl,
    attrs = {
        # rule attributes
    },
    toolchains = ["@rules_weaver//weaver:toolchain_type"],
    doc = "Rule documentation",
)
```

### 2. Action Creation Pattern

Actions are created using a consistent pattern:

```python
def _create_weaver_action(ctx, toolchain, inputs, outputs, args):
    """Create a Weaver action with proper configuration."""
    
    # Prepare command
    command = [
        toolchain.weaver_binary.path,
    ] + args
    
    # Prepare inputs
    input_files = []
    for input_group in inputs.values():
        if hasattr(input_group, "files"):
            input_files.extend(input_group.files.to_list())
        else:
            input_files.append(input_group)
    
    # Create action
    ctx.actions.run(
        outputs = outputs,
        inputs = input_files,
        executable = toolchain.weaver_binary,
        arguments = args,
        mnemonic = "WeaverGenerate",
        progress_message = "Generating code with Weaver",
        use_default_shell_env = True,
    )
```

### 3. Provider Communication Pattern

Rules communicate through providers:

```python
# Producer rule
def _producer_impl(ctx):
    # ... implementation ...
    return [
        SomeProviderInfo(
            data = processed_data,
            metadata = metadata,
        ),
    ]

# Consumer rule
def _consumer_impl(ctx):
    # Get provider from dependency
    provider = ctx.attr.dep[SomeProviderInfo]
    
    # Use provider data
    data = provider.data
    metadata = provider.metadata
    
    # ... implementation ...
```

## Extending the Rules

### 1. Adding New Rules

To add a new rule:

1. **Define the rule** in `defs.bzl`:
```python
def _new_rule_impl(ctx):
    """Implementation of new_rule."""
    # Implementation here
    pass

new_rule = rule(
    implementation = _new_rule_impl,
    attrs = {
        "srcs": attr.label_list(mandatory = True),
        "output_format": attr.string(default = "default"),
    },
    toolchains = ["@rules_weaver//weaver:toolchain_type"],
    doc = "New rule for specific functionality",
)
```

2. **Add to exports** in `defs.bzl`:
```python
# Add to the exports list
exports = [
    # ... existing exports ...
    "new_rule",
]
```

3. **Create tests** in `tests/`:
```python
# tests/new_rule_test.bzl
load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("//weaver:defs.bzl", "new_rule")

def _new_rule_test_impl(ctx):
    env = unittest.begin(ctx)
    # Test implementation
    return unittest.end(env)

new_rule_test = unittest.make(_new_rule_test_impl, attrs = {
    "target": attr.label(),
})
```

### 2. Adding New Providers

To add a new provider:

1. **Define the provider** in `providers.bzl`:
```python
NewProviderInfo = provider(
    doc = "Information about new functionality",
    fields = {
        "data": "The data field",
        "metadata": "Metadata about the data",
    },
)
```

2. **Use in rules**:
```python
def _rule_impl(ctx):
    # ... implementation ...
    return [
        NewProviderInfo(
            data = data,
            metadata = metadata,
        ),
    ]
```

### 3. Adding New Actions

To add new action types:

1. **Create action function** in `internal/actions.bzl`:
```python
def create_custom_weaver_action(ctx, toolchain, inputs, outputs, args):
    """Create a custom Weaver action."""
    ctx.actions.run(
        outputs = outputs,
        inputs = inputs,
        executable = toolchain.weaver_binary,
        arguments = args,
        mnemonic = "WeaverCustom",
        progress_message = "Running custom Weaver operation",
    )
```

2. **Use in rules**:
```python
def _rule_impl(ctx):
    # ... implementation ...
    create_custom_weaver_action(
        ctx = ctx,
        toolchain = toolchain,
        inputs = input_files,
        outputs = output_files,
        args = args,
    )
```

## Testing Strategies

### 1. Unit Testing

Unit tests focus on individual functions and rule implementations:

```python
# tests/unit/rule_test.bzl
load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("//weaver:defs.bzl", "some_rule")

def _test_rule_impl(ctx):
    env = unittest.begin(ctx)
    
    # Test rule behavior
    target = ctx.attr.target
    asserts.equals(env, "expected", target.some_field)
    
    return unittest.end(env)

test_rule = unittest.make(_test_rule_impl, attrs = {
    "target": attr.label(),
})

def test_rule_suite(name):
    unittest.suite(
        name,
        test_rule,
        target = "//path/to:test_target",
    )
```

### 2. Integration Testing

Integration tests verify complete workflows:

```python
# tests/integration/integration_test.bzl
def _integration_test_impl(ctx):
    """Test complete Weaver workflow."""
    
    # Test file generation
    generated_file = ctx.actions.declare_file("generated.txt")
    ctx.actions.write(generated_file, "test content")
    
    # Test validation
    script = ctx.actions.declare_file("test_script.sh")
    ctx.actions.write(script, """
#!/bin/bash
# Test script content
echo "Integration test passed"
""")
    ctx.actions.chmod(script, 0o755)
    
    return [DefaultInfo(
        files = depset([generated_file]),
        executable = script,
    )]

integration_test = rule(
    implementation = _integration_test_impl,
    test = True,
)
```

### 3. Performance Testing

Performance tests measure build performance:

```python
# tests/performance/performance_test.bzl
def _performance_test_impl(ctx):
    """Test performance characteristics."""
    
    # Measure action execution time
    start_time = time.time()
    
    # Perform operations
    # ... implementation ...
    
    end_time = time.time()
    execution_time = end_time - start_time
    
    # Assert performance requirements
    if execution_time > 5.0:  # 5 seconds
        fail("Performance test failed: execution took {} seconds".format(execution_time))
    
    return [DefaultInfo()]

performance_test = rule(
    implementation = _performance_test_impl,
    test = True,
)
```

## Performance Considerations

### 1. Action Optimization

- **Minimize inputs**: Only include necessary files in action inputs
- **Use depsets**: Use depsets for efficient file collection
- **Batch operations**: Combine multiple operations when possible

```python
# Good: Efficient input collection
def _collect_inputs(ctx):
    inputs = depset()
    for src in ctx.attr.srcs:
        if hasattr(src, "files"):
            inputs = depset(transitive = [inputs, src.files])
        else:
            inputs = depset(direct = [src], transitive = [inputs])
    return inputs

# Bad: Inefficient input collection
def _collect_inputs_bad(ctx):
    inputs = []
    for src in ctx.attr.srcs:
        if hasattr(src, "files"):
            inputs.extend(src.files.to_list())
        else:
            inputs.append(src)
    return inputs
```

### 2. Caching Strategy

- **Stable outputs**: Ensure outputs are deterministic
- **Proper dependencies**: Declare all necessary dependencies
- **Avoid unnecessary rebuilds**: Use appropriate file groups

### 3. Remote Execution

- **Minimize network transfers**: Use efficient binary downloads
- **Platform detection**: Proper platform-specific binary selection
- **Action isolation**: Ensure actions are self-contained

## Debugging

### 1. Bazel Debugging

Use Bazel's debugging features:

```bash
# Verbose output
bazel build //target --verbose_failures

# Show action details
bazel build //target --subcommands

# Show dependency graph
bazel query --output=graph //target

# Show rule analysis
bazel build //target --experimental_show_artifacts
```

### 2. Rule Debugging

Add debugging to rule implementations:

```python
def _rule_impl(ctx):
    # Debug information
    print("Rule inputs:", [f.path for f in ctx.files.srcs])
    print("Rule attributes:", ctx.attr)
    
    # ... implementation ...
```

### 3. Action Debugging

Debug action execution:

```python
def _create_action(ctx, toolchain, inputs, outputs, args):
    # Debug action details
    print("Action executable:", toolchain.weaver_binary.path)
    print("Action arguments:", args)
    print("Action inputs:", [f.path for f in inputs])
    print("Action outputs:", [f.path for f in outputs])
    
    ctx.actions.run(
        outputs = outputs,
        inputs = inputs,
        executable = toolchain.weaver_binary,
        arguments = args,
        mnemonic = "WeaverDebug",
    )
```

## Common Development Tasks

### 1. Adding New Weaver Commands

To add support for new Weaver commands:

1. **Update rule attributes** to accept new parameters
2. **Modify action creation** to include new arguments
3. **Add validation** for new parameters
4. **Update documentation** and examples

### 2. Supporting New Platforms

To add support for new platforms:

1. **Update platform constraints** in `platform_constraints.bzl`
2. **Add platform detection** in `repositories.bzl`
3. **Update toolchain registration** to include new platform
4. **Test on new platform**

### 3. Optimizing Build Performance

To optimize build performance:

1. **Profile builds** using `--profile` flag
2. **Identify bottlenecks** in action execution
3. **Optimize input/output handling**
4. **Use appropriate caching strategies**

### 4. Adding New Output Formats

To add new output formats:

1. **Extend format validation** in rules
2. **Add format-specific arguments**
3. **Update templates** if needed
4. **Add format-specific tests**

## Best Practices

### 1. Code Organization

- **Separate concerns**: Keep rule logic, action creation, and utilities separate
- **Consistent naming**: Use consistent naming conventions
- **Documentation**: Document all public APIs and complex logic

### 2. Error Handling

- **Validate inputs**: Always validate rule inputs
- **Clear error messages**: Provide helpful error messages
- **Graceful degradation**: Handle edge cases gracefully

### 3. Testing

- **Comprehensive coverage**: Test all code paths
- **Edge cases**: Test boundary conditions
- **Performance**: Include performance tests for critical paths

### 4. Documentation

- **Keep docs updated**: Update documentation with code changes
- **Include examples**: Provide working examples for all features
- **API documentation**: Document all public APIs

## Getting Help

- **Code comments**: Check inline code comments
- **Test files**: Look at test files for usage examples
- **GitHub issues**: Search existing issues for similar problems
- **Community**: Ask questions in GitHub discussions

This developer guide should help you understand and work with the Bazel OpenTelemetry Weaver rules effectively. For more specific information, refer to the individual rule documentation and examples. 