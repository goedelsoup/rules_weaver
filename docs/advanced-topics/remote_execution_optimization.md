# Remote Execution Optimization Guide

This document describes the remote execution compatibility features and optimization strategies implemented in the OpenTelemetry Weaver rules.

## Overview

The Weaver rules have been optimized for remote execution environments like Google Cloud Build, Bazel Remote Execution (RBE), and other distributed build systems. All actions are designed to be fully hermetic, platform-agnostic, and efficient for network transfer.

## Key Features

### 1. Hermetic Actions

All Weaver actions are fully hermetic, meaning they:
- Don't depend on external state or network access
- Use only explicitly declared inputs
- Produce deterministic outputs
- Work consistently across different environments

### 2. Platform Constraints

The rules support multiple platforms with proper constraint handling:
- Linux (x86_64, aarch64)
- macOS (x86_64, aarch64)
- Windows (x86_64)

Platform constraints are automatically detected and applied to ensure compatibility.

### 3. Execution Requirements

Actions include optimized execution requirements for remote execution:
- `no-sandbox: "1"` - Allows remote execution
- `supports-workers: "1"` - Enables worker processes for performance
- `requires-network: "0"` - Confirms no network access needed
- `cpu-cores: "2"` - Requests appropriate CPU resources
- `memory: "4g"` - Requests appropriate memory
- `timeout: "300s"` - Sets reasonable timeout

### 4. Input/Output Optimization

Actions are optimized for efficient network transfer:
- Minimal input dependencies
- Efficient output file organization
- Platform-agnostic path handling
- Proper file encoding (UTF-8)

### 5. Progress Reporting

Enhanced progress messages provide useful feedback in remote execution:
- Schema count information
- Remote execution compatibility indicators
- Detailed operation descriptions
- Execution time tracking

## Usage Examples

### Basic Remote Execution Setup

```python
# WORKSPACE
load("@rules_weaver//weaver:repositories.bzl", "weaver_repository", "weaver_register_toolchains")

weaver_repository(
    name = "weaver",
    version = "0.1.0",
    sha256 = "abc123...",
)

weaver_register_toolchains()
```

### Code Generation with Remote Execution

```python
# BUILD.bazel
load("@rules_weaver//weaver:defs.bzl", "weaver_generate")

weaver_generate(
    name = "my_generated_code",
    srcs = ["schema.yaml"],
    format = "typescript",
    args = ["--verbose"],
)
```

### Validation with Remote Execution

```python
# BUILD.bazel
load("@rules_weaver//weaver:defs.bzl", "weaver_validate")

weaver_validate(
    name = "validate_schemas",
    schemas = ["schema.yaml"],
    policies = ["policy.yaml"],
    args = ["--strict"],
)
```

## Performance Optimization

### 1. Caching Strategy

Actions are designed to maximize cache hits:
- Deterministic outputs based on inputs
- Proper input dependency declaration
- Efficient file fingerprinting

### 2. Worker Processes

Actions support worker processes for improved performance:
- Parallel execution where possible
- Shared state between workers
- Efficient resource utilization

### 3. Resource Management

Actions request appropriate resources:
- CPU cores based on operation complexity
- Memory allocation for large schemas
- Timeout settings for long-running operations

## Platform Compatibility

### Supported Platforms

| Platform | Architecture | Status |
|----------|-------------|---------|
| Linux | x86_64 | ✅ Supported |
| Linux | aarch64 | ✅ Supported |
| macOS | x86_64 | ✅ Supported |
| macOS | aarch64 | ✅ Supported |
| Windows | x86_64 | ✅ Supported |

### Platform Detection

Platform detection is automatic and optimized for remote execution:
- Uses Bazel's platform constraints
- Handles cross-compilation scenarios
- Supports platform-specific optimizations

## Environment Variables

Actions use consistent environment variables for remote execution:
- `PATH=/usr/local/bin:/usr/bin:/bin`
- `LANG=C.UTF-8`
- `LC_ALL=C.UTF-8`

Custom environment variables can be added through the `env` attribute.

## Testing Remote Execution

### Running Tests

```bash
# Run all remote execution tests
bazel test //tests:remote_execution_test

# Run specific test categories
bazel test //tests:remote_execution_test --test_filter=test_platform_constraints
```

### Test Categories

1. **Platform Constraints** - Verify platform support
2. **Execution Requirements** - Check remote execution settings
3. **Hermetic Actions** - Ensure actions are hermetic
4. **Environment Isolation** - Verify environment handling
5. **Input/Output Optimization** - Test efficiency
6. **Progress Reporting** - Check progress messages
7. **Network Isolation** - Verify no network access
8. **Sandbox Compatibility** - Test sandbox support
9. **Worker Support** - Verify worker process support

## Troubleshooting

### Common Issues

1. **Platform Not Supported**
   - Check platform constraint definitions
   - Verify platform detection logic
   - Update platform mappings if needed

2. **Action Fails in Remote Execution**
   - Verify all inputs are declared
   - Check for hidden dependencies
   - Ensure environment variables are set correctly

3. **Performance Issues**
   - Review execution requirements
   - Check resource allocation
   - Verify caching behavior

### Debugging

Enable verbose output for debugging:
```bash
bazel build --verbose_failures --sandbox_debug //target
```

Check execution requirements:
```bash
bazel aquery --output=text //target
```

## Best Practices

1. **Always declare all inputs explicitly**
2. **Use platform-agnostic paths**
3. **Set appropriate execution requirements**
4. **Test in remote execution environments**
5. **Monitor performance metrics**
6. **Keep actions hermetic**
7. **Use consistent environment variables**
8. **Optimize for caching**

## Future Enhancements

Planned improvements for remote execution:
- Enhanced platform detection
- Dynamic resource allocation
- Advanced caching strategies
- Performance monitoring
- Cross-platform optimization
- Network transfer optimization 