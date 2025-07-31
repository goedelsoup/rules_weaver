# Migration Guide

This guide helps you migrate from manual OpenTelemetry Weaver usage to the Bazel rules for better hermetic builds, remote execution support, and improved developer experience.

## Overview

The Bazel OpenTelemetry Weaver rules provide several advantages over manual Weaver usage:

- **Hermetic Builds**: All dependencies are explicitly declared
- **Remote Execution**: Optimized for distributed builds
- **Reproducible**: Consistent results across environments
- **Integrated**: Seamless Bazel workflow integration
- **Scalable**: Better performance for large codebases

## Migration Checklist

- [ ] Set up Bazel workspace with Weaver rules
- [ ] Convert manual Weaver commands to Bazel rules
- [ ] Update build scripts and CI/CD pipelines
- [ ] Test generated code and validation
- [ ] Update documentation and team processes

## Step-by-Step Migration

### Step 1: Set Up Bazel Workspace

If you don't already have a Bazel workspace, create one:

```bash
# Create workspace
mkdir my-project
cd my-project

# Create WORKSPACE file
touch WORKSPACE

# Create BUILD file
touch BUILD.bazel
```

Add the Weaver rules to your `WORKSPACE`:

```python
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rules_weaver",
    sha256 = "YOUR_SHA256_HERE",
    strip_prefix = "rules_weaver-main",
    url = "https://github.com/open-telemetry/weaver/archive/main.zip",
)

load("@rules_weaver//weaver:repositories.bzl", 
     "weaver_repository", 
     "weaver_dependencies", 
     "weaver_register_toolchains")

weaver_dependencies()

weaver_repository(
    name = "weaver",
    version = "0.1.0",  # Use your current Weaver version
    sha256 = "abc123def4567890abcdef1234567890abcdef1234567890abcdef1234567890",
)

weaver_register_toolchains()
```

### Step 2: Convert Manual Commands

#### Before: Manual Weaver Commands

```bash
# Download Weaver manually
curl -L https://github.com/open-telemetry/weaver/releases/download/v0.1.0/weaver-0.1.0-linux-amd64.tar.gz | tar -xz
chmod +x weaver

# Generate code manually
./weaver generate --format typescript --output ./generated schemas/user.yaml

# Validate schemas manually
./weaver validate --policy policy.yaml schemas/user.yaml
```

#### After: Bazel Rules

```python
# BUILD.bazel
load("@rules_weaver//weaver:defs.bzl", "weaver_library")

weaver_library(
    name = "user_schemas",
    srcs = ["schemas/user.yaml"],
    format = "typescript",
    validation = True,
    policies = ["policy.yaml"],
    visibility = ["//visibility:public"],
)
```

```bash
# Generate code
bazel build //:user_schemas_generated

# Validate schemas
bazel test //:user_schemas_validation
```

### Step 3: Convert Build Scripts

#### Before: Shell Scripts

```bash
#!/bin/bash
# build.sh

# Download Weaver if not present
if [ ! -f "./weaver" ]; then
    curl -L https://github.com/open-telemetry/weaver/releases/download/v0.1.0/weaver-0.1.0-linux-amd64.tar.gz | tar -xz
    chmod +x weaver
fi

# Generate code
./weaver generate --format typescript --output ./generated schemas/*.yaml

# Validate schemas
./weaver validate --policy policy.yaml schemas/*.yaml

# Check for errors
if [ $? -ne 0 ]; then
    echo "Validation failed"
    exit 1
fi
```

#### After: Bazel Commands

```bash
#!/bin/bash
# build.sh

# Generate all code
bazel build //...

# Run all tests (including validation)
bazel test //...

# Check for errors
if [ $? -ne 0 ]; then
    echo "Build or validation failed"
    exit 1
fi
```

### Step 4: Update CI/CD Pipelines

#### Before: GitHub Actions

```yaml
# .github/workflows/build.yml
name: Build and Validate

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Weaver
        run: |
          curl -L https://github.com/open-telemetry/weaver/releases/download/v0.1.0/weaver-0.1.0-linux-amd64.tar.gz | tar -xz
          chmod +x weaver
          
      - name: Generate Code
        run: |
          ./weaver generate --format typescript --output ./generated schemas/*.yaml
          
      - name: Validate Schemas
        run: |
          ./weaver validate --policy policy.yaml schemas/*.yaml
          
      - name: Build Project
        run: |
          npm install
          npm run build
```

#### After: Bazel in CI/CD

```yaml
# .github/workflows/build.yml
name: Build and Validate

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Bazel
        uses: bazelbuild/setup-bazelisk@v2
        
      - name: Build and Test
        run: |
          bazel build //...
          bazel test //...
          
      - name: Build Project
        run: |
          bazel build //:my_app
```

### Step 5: Update Development Workflow

#### Before: Manual Development

```bash
# Developer workflow
./weaver generate --format typescript --output ./generated schemas/user.yaml
npm run build
npm test
```

#### After: Bazel Development

```bash
# Developer workflow
bazel build //:user_schemas_generated
bazel test //:user_schemas_validation
bazel build //:my_app
bazel test //:my_app_tests
```

## Common Migration Patterns

### Pattern 1: Multiple Schema Files

#### Before

```bash
# Generate from multiple schemas
./weaver generate --format typescript --output ./generated \
  schemas/user.yaml \
  schemas/product.yaml \
  schemas/order.yaml
```

#### After

```python
# BUILD.bazel
weaver_library(
    name = "all_schemas",
    srcs = [
        "schemas/user.yaml",
        "schemas/product.yaml", 
        "schemas/order.yaml",
    ],
    format = "typescript",
    visibility = ["//visibility:public"],
)
```

### Pattern 2: Multiple Output Formats

#### Before

```bash
# Generate multiple formats
./weaver generate --format typescript --output ./generated/ts schemas/user.yaml
./weaver generate --format go --output ./generated/go schemas/user.yaml
./weaver generate --format python --output ./generated/py schemas/user.yaml
```

#### After

```python
# BUILD.bazel
weaver_generate(
    name = "typescript_types",
    srcs = [":user_schemas"],
    format = "typescript",
    out_dir = "generated/ts",
)

weaver_generate(
    name = "go_types",
    srcs = [":user_schemas"],
    format = "go",
    out_dir = "generated/go",
)

weaver_generate(
    name = "python_types",
    srcs = [":user_schemas"],
    format = "python",
    out_dir = "generated/py",
)
```

### Pattern 3: Custom Weaver Arguments

#### Before

```bash
# Use custom arguments
./weaver generate \
  --format typescript \
  --output ./generated \
  --verbose \
  --strict \
  --config weaver.config.yaml \
  schemas/user.yaml
```

#### After

```python
# BUILD.bazel
weaver_generate(
    name = "user_types",
    srcs = [":user_schemas"],
    format = "typescript",
    args = [
        "--verbose",
        "--strict",
        "--config",
        "weaver.config.yaml",
    ],
    visibility = ["//visibility:public"],
)
```

### Pattern 4: Environment Variables

#### Before

```bash
# Set environment variables
export WEAVER_LOG_LEVEL=debug
export WEAVER_CACHE_DIR=/tmp/weaver-cache
./weaver generate --format typescript --output ./generated schemas/user.yaml
```

#### After

```python
# BUILD.bazel
weaver_generate(
    name = "user_types",
    srcs = [":user_schemas"],
    format = "typescript",
    env = {
        "WEAVER_LOG_LEVEL": "debug",
        "WEAVER_CACHE_DIR": "/tmp/weaver-cache",
    },
    visibility = ["//visibility:public"],
)
```

## Migration Examples

### Example 1: Simple Migration

**Before**: Single schema file with manual generation

```bash
# Manual workflow
./weaver generate --format typescript --output ./src/types schemas/user.yaml
```

**After**: Bazel rule

```python
# BUILD.bazel
weaver_library(
    name = "user_types",
    srcs = ["schemas/user.yaml"],
    format = "typescript",
    out_dir = "src/types",
    visibility = ["//visibility:public"],
)
```

### Example 2: Complex Migration

**Before**: Multiple schemas with validation and custom config

```bash
# Complex manual workflow
./weaver generate \
  --format typescript \
  --output ./generated \
  --config weaver.config.yaml \
  --verbose \
  schemas/user.yaml \
  schemas/product.yaml \
  schemas/order.yaml

./weaver validate \
  --policy security_policy.yaml \
  --policy naming_policy.yaml \
  schemas/*.yaml
```

**After**: Bazel rules

```python
# BUILD.bazel
weaver_library(
    name = "all_schemas",
    srcs = [
        "schemas/user.yaml",
        "schemas/product.yaml",
        "schemas/order.yaml",
    ],
    format = "typescript",
    weaver_args = [
        "--config",
        "weaver.config.yaml",
        "--verbose",
    ],
    validation = True,
    policies = [
        "security_policy.yaml",
        "naming_policy.yaml",
    ],
    visibility = ["//visibility:public"],
)
```

## Troubleshooting Migration

### Common Issues

#### 1. Build Failures

**Issue**: Bazel build fails after migration

**Solution**: 
- Check that all schema files are properly referenced
- Verify file paths are correct
- Ensure Weaver version compatibility

```bash
# Debug build issues
bazel build //:target --verbose_failures
```

#### 2. Generated Files Not Found

**Issue**: Generated files are not where expected

**Solution**: Use Bazel query to find generated files

```bash
# Find generated files
bazel query --output=location //:target_generated

# Show file contents
bazel query --output=location //:target_generated | xargs ls -la
```

#### 3. Validation Failures

**Issue**: Validation passes manually but fails in Bazel

**Solution**: 
- Check that all dependencies are properly declared
- Verify policy files are included
- Use test mode for validation

```python
# Use test mode for validation
weaver_validate(
    name = "validation_test",
    schemas = [":schemas"],
    policies = ["policy.yaml"],
    testonly = True,  # Run as test
)
```

#### 4. Performance Issues

**Issue**: Bazel builds are slower than manual commands

**Solution**:
- Enable remote execution if available
- Use Bazel's caching effectively
- Optimize schema organization

```bash
# Enable remote execution
bazel build //:target --remote_executor=grpc://your-remote-executor:8080

# Use local caching
bazel build //:target --disk_cache=/path/to/cache
```

### Migration Validation

After migration, validate your setup:

```bash
# Test basic functionality
bazel build //:all_schemas_generated
bazel test //:all_schemas_validation

# Compare generated output
diff -r ./old-generated ./bazel-bin/path/to/generated

# Test integration
bazel build //:my_app
bazel test //:my_app_tests
```

## Best Practices for Migration

### 1. Incremental Migration

Migrate one schema at a time:

```python
# Start with one schema
weaver_library(
    name = "user_schemas",
    srcs = ["schemas/user.yaml"],
    format = "typescript",
)

# Then add more
weaver_library(
    name = "all_schemas",
    srcs = [
        "schemas/user.yaml",
        "schemas/product.yaml",
    ],
    format = "typescript",
)
```

### 2. Maintain Compatibility

Keep manual commands working during transition:

```bash
# Hybrid approach during migration
if [ "$USE_BAZEL" = "true" ]; then
    bazel build //:schemas_generated
else
    ./weaver generate --format typescript --output ./generated schemas/*.yaml
fi
```

### 3. Update Documentation

Update team documentation:

```markdown
# Development Setup

## Prerequisites
- Bazel 5.0+
- Weaver rules configured in WORKSPACE

## Development Commands
```bash
# Generate code
bazel build //:schemas_generated

# Validate schemas  
bazel test //:schemas_validation

# Build application
bazel build //:my_app
```
```

### 4. Team Training

Train your team on the new workflow:

1. **Workshop**: Hands-on migration session
2. **Documentation**: Updated development guides
3. **Examples**: Migration examples for common patterns
4. **Support**: Designated migration support person

## Post-Migration Checklist

- [ ] All schemas generate correctly
- [ ] Validation passes consistently
- [ ] CI/CD pipeline updated
- [ ] Team documentation updated
- [ ] Performance meets expectations
- [ ] Rollback plan tested
- [ ] Team training completed

## Getting Help

If you encounter issues during migration:

1. Check the [Troubleshooting Guide](troubleshooting.md)
2. Review [Migration Examples](examples/migration_examples.md)
3. Search existing [GitHub Issues](https://github.com/open-telemetry/weaver/issues)
4. Create a new issue with migration details

## Next Steps

After successful migration:

1. Explore [Advanced Examples](examples/advanced_usage.md)
2. Optimize for [Remote Execution](remote_execution.md)
3. Implement [Performance Best Practices](performance.md)
4. Contribute back to the community 