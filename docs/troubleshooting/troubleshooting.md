# Troubleshooting Guide

This guide helps you resolve common issues when using the Bazel OpenTelemetry Weaver rules.

## Quick Diagnosis

### Check Basic Setup

```bash
# Verify Bazel installation
bazel --version

# Check Weaver rules are loaded
bazel query @rules_weaver//...

# Verify Weaver toolchain
bazel query @weaver//...
```

### Common Error Patterns

| Error Pattern | Likely Cause | Quick Fix |
|---------------|--------------|-----------|
| `No such target` | Missing BUILD file or target | Check target name and BUILD file |
| `SHA256 mismatch` | Wrong hash or corrupted download | Update SHA256 in WORKSPACE |
| `Unsupported platform` | Platform not supported | Check platform support |
| `Toolchain not found` | Toolchain not registered | Call `weaver_register_toolchains()` |
| `Schema parse error` | Invalid YAML/JSON | Validate schema syntax |

## Common Issues and Solutions

### 1. Installation Issues

#### Issue: SHA256 Mismatch

**Error Message**:
```
ERROR: SHA256 mismatch for downloaded file
```

**Causes**:
- Incorrect SHA256 hash in WORKSPACE
- Corrupted download
- Different file version

**Solutions**:

1. **Get the correct SHA256**:
```bash
# Download and compute hash manually
curl -L <url> | sha256sum
```

2. **Update WORKSPACE**:
```python
weaver_repository(
    name = "weaver",
    version = "0.1.0",
    sha256 = "correct-sha256-here",  # Update this
)
```

3. **Skip verification temporarily** (not recommended for production):
```python
weaver_repository(
    name = "weaver",
    version = "0.1.0",
    skip_sha256_verification = True,
)
```

#### Issue: Platform Detection Failure

**Error Message**:
```
ERROR: Unsupported platform: unknown
```

**Causes**:
- Unsupported operating system or architecture
- Remote execution environment issues

**Solutions**:

1. **Check platform support**:
```bash
# Check your platform
uname -s -m
```

2. **Add platform-specific configuration**:
```python
weaver_repository(
    name = "weaver",
    version = "0.1.0",
    platform_overrides = {
        "your-platform": {
            "sha256": "platform-specific-sha256",
            "urls": ["https://platform-specific-url"],
        },
    },
)
```

3. **Use custom URLs**:
```python
weaver_repository(
    name = "weaver",
    version = "0.1.0",
    urls = [
        "https://your-mirror.com/weaver-{version}-{platform}.tar.gz",
    ],
)
```

#### Issue: Network Download Failures

**Error Message**:
```
ERROR: Failed to download Weaver binary
```

**Causes**:
- Network connectivity issues
- Firewall blocking downloads
- Invalid URLs

**Solutions**:

1. **Check network connectivity**:
```bash
# Test URL accessibility
curl -I https://github.com/open-telemetry/weaver/releases/download/v0.1.0/weaver-0.1.0-linux-amd64.tar.gz
```

2. **Use alternative URLs**:
```python
weaver_repository(
    name = "weaver",
    version = "0.1.0",
    urls = [
        "https://primary-url.com/weaver-{version}-{platform}.tar.gz",
        "https://fallback-url.com/weaver-{version}-{platform}.tar.gz",
    ],
)
```

3. **Configure proxy if needed**:
```bash
# Set HTTP proxy
export HTTP_PROXY=http://proxy.example.com:8080
export HTTPS_PROXY=http://proxy.example.com:8080
```

### 2. Build Issues

#### Issue: Target Not Found

**Error Message**:
```
ERROR: no such target '//path/to:target': target 'target' not declared in package 'path/to'
```

**Causes**:
- Missing BUILD file
- Incorrect target name
- Wrong package path

**Solutions**:

1. **Check BUILD file exists**:
```bash
# Verify BUILD file exists
ls -la path/to/BUILD*

# Create BUILD file if missing
touch path/to/BUILD.bazel
```

2. **Verify target name**:
```bash
# List all targets in package
bazel query //path/to:all
```

3. **Check target declaration**:
```python
# Ensure target is properly declared
weaver_library(
    name = "my_schemas",  # This is the target name
    srcs = ["schema.yaml"],
    visibility = ["//visibility:public"],
)
```

#### Issue: Schema File Not Found

**Error Message**:
```
ERROR: no such file 'schema.yaml'
```

**Causes**:
- File doesn't exist
- Wrong file path
- File not in correct package

**Solutions**:

1. **Check file exists**:
```bash
# Verify file exists
ls -la schema.yaml

# Check file path relative to BUILD file
find . -name "schema.yaml"
```

2. **Use correct relative path**:
```python
# If BUILD file is in same directory as schema
weaver_library(
    name = "my_schemas",
    srcs = ["schema.yaml"],  # Relative to BUILD file
)

# If schema is in subdirectory
weaver_library(
    name = "my_schemas",
    srcs = ["schemas/schema.yaml"],
)
```

#### Issue: Toolchain Not Found

**Error Message**:
```
ERROR: No toolchain found for @rules_weaver//weaver:toolchain_type
```

**Causes**:
- Toolchain not registered
- Weaver repository not configured
- Platform not supported

**Solutions**:

1. **Ensure toolchain registration**:
```python
# In WORKSPACE file
load("@rules_weaver//weaver:repositories.bzl", "weaver_register_toolchains")

weaver_register_toolchains()  # This must be called
```

2. **Check Weaver repository setup**:
```python
# Verify Weaver repository is configured
weaver_repository(
    name = "weaver",
    version = "0.1.0",
    sha256 = "abc123...",
)
```

3. **Check toolchain availability**:
```bash
# Query available toolchains
bazel query --output=location @weaver//:weaver_toolchain
```

### 3. Schema Issues

#### Issue: Schema Parse Error

**Error Message**:
```
ERROR: Failed to parse schema: invalid YAML syntax
```

**Causes**:
- Invalid YAML syntax
- Invalid JSON syntax
- Schema format not supported

**Solutions**:

1. **Validate YAML syntax**:
```bash
# Check YAML syntax
python3 -c "import yaml; yaml.safe_load(open('schema.yaml'))"
```

2. **Use YAML validator**:
```bash
# Install and use yamllint
pip install yamllint
yamllint schema.yaml
```

3. **Check schema format**:
```yaml
# Ensure proper OpenTelemetry schema format
version: "1.0"
schemas:
  - name: "MySchema"
    type: "object"
    properties:
      field:
        type: "string"
```

#### Issue: Schema Validation Failure

**Error Message**:
```
ERROR: Schema validation failed: field 'required' must be an array
```

**Causes**:
- Schema doesn't conform to OpenTelemetry specification
- Missing required fields
- Invalid field types

**Solutions**:

1. **Check OpenTelemetry schema spec**:
```yaml
# Ensure schema follows OpenTelemetry format
version: "1.0"
schemas:
  - name: "User"
    type: "object"
    properties:
      id:
        type: "string"
    required: ["id"]  # Must be array
```

2. **Use schema validation**:
```python
# Add validation to catch issues early
weaver_validate(
    name = "validate_schemas",
    schemas = [":my_schemas"],
    fail_on_error = True,
)
```

3. **Check schema dependencies**:
```python
# Ensure all dependencies are declared
weaver_schema(
    name = "my_schemas",
    srcs = ["schema.yaml"],
    deps = [":other_schemas"],  # Declare dependencies
)
```

### 4. Generation Issues

#### Issue: No Generated Files

**Error Message**:
```
ERROR: No files were generated
```

**Causes**:
- Schema is empty or invalid
- Output format not supported
- Generation arguments incorrect

**Solutions**:

1. **Check schema content**:
```bash
# Verify schema has content
cat schema.yaml
```

2. **Use verbose output**:
```python
weaver_generate(
    name = "my_generated",
    srcs = [":my_schemas"],
    args = ["--verbose"],  # Add verbose output
)
```

3. **Check output format**:
```python
# Ensure format is supported
weaver_generate(
    name = "my_generated",
    srcs = [":my_schemas"],
    format = "typescript",  # Use supported format
)
```

#### Issue: Generated Files in Wrong Location

**Error Message**:
```
ERROR: Generated files not found in expected location
```

**Causes**:
- Output directory not specified correctly
- Files generated in different location
- Path resolution issues

**Solutions**:

1. **Specify output directory**:
```python
weaver_generate(
    name = "my_generated",
    srcs = [":my_schemas"],
    out_dir = "generated",  # Specify output directory
)
```

2. **Find generated files**:
```bash
# Query where files are generated
bazel query --output=location //:my_generated

# List generated files
bazel query --output=location //:my_generated | xargs ls -la
```

3. **Use absolute paths**:
```python
weaver_generate(
    name = "my_generated",
    srcs = [":my_schemas"],
    out_dir = "/absolute/path/to/generated",
)
```

### 5. Validation Issues

#### Issue: Validation Always Passes

**Error Message**:
```
# No error, but validation should fail
```

**Causes**:
- Validation not actually running
- Policy files not loaded
- Validation mode incorrect

**Solutions**:

1. **Check validation is enabled**:
```python
weaver_library(
    name = "my_schemas",
    srcs = ["schema.yaml"],
    validation = True,  # Ensure validation is enabled
)
```

2. **Add policy files**:
```python
weaver_validate(
    name = "validate_schemas",
    schemas = [":my_schemas"],
    policies = ["policy.yaml"],  # Add policy files
)
```

3. **Use test mode**:
```python
weaver_validate(
    name = "test_validation",
    schemas = [":my_schemas"],
    testonly = True,  # Run as test
)
```

#### Issue: Validation Fails in CI but Passes Locally

**Error Message**:
```
ERROR: Validation failed in CI environment
```

**Causes**:
- Different Weaver versions
- Different platform environments
- Different policy files

**Solutions**:

1. **Pin Weaver version**:
```python
weaver_repository(
    name = "weaver",
    version = "0.1.0",  # Use exact version
    sha256 = "abc123...",
)
```

2. **Use hermetic builds**:
```bash
# Ensure hermetic builds
bazel build --enable_platform_specific_config //:target
```

3. **Check environment differences**:
```bash
# Compare environments
bazel info
bazel query @weaver//...
```

### 6. Performance Issues

#### Issue: Slow Builds

**Error Message**:
```
# Builds take too long
```

**Causes**:
- No caching enabled
- Remote execution not configured
- Inefficient schema organization

**Solutions**:

1. **Enable caching**:
```bash
# Enable disk cache
bazel build --disk_cache=/path/to/cache //:target

# Enable remote cache
bazel build --remote_cache=grpc://cache.example.com:8080 //:target
```

2. **Use remote execution**:
```bash
# Enable remote execution
bazel build --remote_executor=grpc://executor.example.com:8080 //:target
```

3. **Optimize schema organization**:
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
```

#### Issue: Memory Issues

**Error Message**:
```
ERROR: Out of memory
```

**Causes**:
- Large schema files
- Too many schemas processed at once
- Insufficient memory allocation

**Solutions**:

1. **Split large schemas**:
```python
# Split large schema into smaller parts
weaver_schema(
    name = "schema_part_1",
    srcs = ["large_schema_part1.yaml"],
)

weaver_schema(
    name = "schema_part_2",
    srcs = ["large_schema_part2.yaml"],
)
```

2. **Increase memory allocation**:
```bash
# Increase Bazel memory
bazel build --host_jvm_args=-Xmx4g //:target
```

3. **Process schemas incrementally**:
```python
# Process schemas one at a time
weaver_generate(
    name = "generate_1",
    srcs = [":schema_1"],
)

weaver_generate(
    name = "generate_2",
    srcs = [":schema_2"],
)
```

## Debugging Techniques

### Enable Verbose Output

```bash
# Enable verbose Bazel output
bazel build --verbose_failures //:target

# Enable Weaver verbose output
weaver_generate(
    name = "my_generated",
    srcs = [":my_schemas"],
    args = ["--verbose"],
)
```

### Query Target Information

```bash
# Query target dependencies
bazel query --noimplicit_deps //:target

# Query target location
bazel query --output=location //:target

# Query target attributes
bazel query --output=build //:target
```

### Check Generated Files

```bash
# List generated files
bazel query --output=location //:target_generated | xargs ls -la

# Show generated content
bazel query --output=location //:target_generated | xargs cat
```

### Validate Schema Syntax

```bash
# Check YAML syntax
python3 -c "import yaml; yaml.safe_load(open('schema.yaml'))"

# Check JSON syntax
python3 -c "import json; json.load(open('schema.json'))"
```

## Getting Help

### Before Asking for Help

1. **Check this troubleshooting guide**
2. **Search existing issues**: [GitHub Issues](https://github.com/open-telemetry/weaver/issues)
3. **Check documentation**: [API Reference](api_reference.md)
4. **Try minimal reproduction**: Create minimal example that reproduces the issue

### When Creating an Issue

Include the following information:

1. **Environment**:
   - Bazel version: `bazel --version`
   - Platform: `uname -s -m`
   - Weaver version in WORKSPACE

2. **Error details**:
   - Complete error message
   - Stack trace if available
   - Verbose output

3. **Reproduction steps**:
   - Minimal WORKSPACE configuration
   - Minimal BUILD file
   - Schema files (if applicable)

4. **Expected vs actual behavior**:
   - What you expected to happen
   - What actually happened

### Community Resources

- **GitHub Issues**: [Report bugs and request features](https://github.com/open-telemetry/weaver/issues)
- **GitHub Discussions**: [Ask questions and share solutions](https://github.com/open-telemetry/weaver/discussions)
- **Documentation**: [Complete documentation](README.md)
- **Examples**: [Usage examples](examples/)

## Prevention

### Best Practices

1. **Use version pinning**: Always specify exact Weaver version and SHA256
2. **Enable validation**: Use `validation = True` in `weaver_library`
3. **Test in CI**: Include validation tests in your CI pipeline
4. **Document configuration**: Keep WORKSPACE and BUILD files documented
5. **Use hermetic builds**: Ensure builds are reproducible

### Regular Maintenance

1. **Update Weaver version**: Regularly update to latest stable version
2. **Review schemas**: Periodically review and validate schemas
3. **Monitor performance**: Track build times and optimize as needed
4. **Update documentation**: Keep team documentation current 