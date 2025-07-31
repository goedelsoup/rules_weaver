# Frequently Asked Questions (FAQ)

Common questions and answers about the Bazel OpenTelemetry Weaver rules.

## General Questions

### What is OpenTelemetry Weaver?

OpenTelemetry Weaver is a tool for managing OpenTelemetry schemas and generating type-safe code from them. It helps teams maintain consistent telemetry schemas across different services and programming languages.

### Why use Bazel rules for Weaver?

The Bazel rules provide several advantages:
- **Hermetic builds**: All dependencies are explicitly declared
- **Remote execution**: Optimized for distributed builds
- **Reproducible**: Consistent results across environments
- **Integrated**: Seamless Bazel workflow integration
- **Scalable**: Better performance for large codebases

### What platforms are supported?

The rules support:
- **Linux**: x86_64, aarch64
- **macOS**: x86_64, aarch64
- **Windows**: x86_64

### What Bazel versions are supported?

- **Bazel 5.0+**: Full support
- **Bazel 4.0+**: Limited support
- **Bazel < 4.0**: Not supported

## Installation and Setup

### How do I install the Weaver rules?

Add the following to your `WORKSPACE` file:

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
    version = "0.1.0",
    sha256 = "abc123def4567890abcdef1234567890abcdef1234567890abcdef1234567890",
)

weaver_register_toolchains()
```

### How do I get the correct SHA256 hash?

You can compute the SHA256 hash manually:

```bash
curl -L <url> | sha256sum
```

Or temporarily skip verification (not recommended for production):

```python
weaver_repository(
    name = "weaver",
    version = "0.1.0",
    skip_sha256_verification = True,
)
```

### What Weaver version should I use?

Use the latest stable version that's compatible with your project. Check the [OpenTelemetry Weaver releases](https://github.com/open-telemetry/weaver/releases) for the most recent version.

### Can I use a custom Weaver binary?

Yes, you can specify a custom Weaver binary:

```python
weaver_generate(
    name = "my_generated",
    srcs = [":my_schemas"],
    weaver = "//path/to/custom:weaver_binary",
)
```

## Schema Management

### What schema formats are supported?

The rules support:
- **YAML** (`.yaml`, `.yml`)
- **JSON** (`.json`)

### How do I declare a schema?

Create a schema file and declare it in your `BUILD.bazel`:

```python
load("@rules_weaver//weaver:defs.bzl", "weaver_schema")

weaver_schema(
    name = "my_schemas",
    srcs = ["schema.yaml"],
    visibility = ["//visibility:public"],
)
```

### Can I group multiple schema files?

Yes, you can group related schemas:

```python
weaver_schema(
    name = "user_schemas",
    srcs = [
        "user.yaml",
        "profile.yaml",
        "preferences.yaml",
    ],
    visibility = ["//visibility:public"],
)
```

### How do I reference other schemas?

Use the `deps` attribute to declare dependencies:

```python
weaver_schema(
    name = "base_schemas",
    srcs = ["base.yaml"],
    visibility = ["//visibility:public"],
)

weaver_schema(
    name = "user_schemas",
    srcs = ["user.yaml"],
    deps = [":base_schemas"],
    visibility = ["//visibility:public"],
)
```

## Code Generation

### What output formats are supported?

The rules support generating code in:
- **TypeScript** (`.ts`, `.d.ts`)
- **Go** (`.go`)
- **Python** (`.py`)
- **Java** (`.java`)
- **Rust** (`.rs`)

### How do I generate code from schemas?

Use the `weaver_generate` rule:

```python
load("@rules_weaver//weaver:defs.bzl", "weaver_generate")

weaver_generate(
    name = "my_types",
    srcs = [":my_schemas"],
    format = "typescript",
    visibility = ["//visibility:public"],
)
```

### Can I generate multiple formats from the same schema?

Yes, create separate generation targets:

```python
weaver_generate(
    name = "typescript_types",
    srcs = [":my_schemas"],
    format = "typescript",
)

weaver_generate(
    name = "go_types",
    srcs = [":my_schemas"],
    format = "go",
)
```

### How do I specify a custom output directory?

Use the `out_dir` attribute:

```python
weaver_generate(
    name = "my_types",
    srcs = [":my_schemas"],
    format = "typescript",
    out_dir = "src/generated/types",
)
```

### Where are generated files located?

Generated files are in the Bazel output directory. You can find them with:

```bash
bazel query --output=location //:my_types
```

## Validation

### How do I validate schemas?

Use the `weaver_validate` rule:

```python
load("@rules_weaver//weaver:defs.bzl", "weaver_validate")

weaver_validate(
    name = "validate_schemas",
    schemas = [":my_schemas"],
    visibility = ["//visibility:public"],
)
```

### Can I use custom validation policies?

Yes, specify policy files:

```python
weaver_validate(
    name = "validate_with_policies",
    schemas = [":my_schemas"],
    policies = ["policy.yaml"],
    visibility = ["//visibility:public"],
)
```

### How do I run validation as a test?

Use the `testonly` attribute:

```python
weaver_validate(
    name = "test_validation",
    schemas = [":my_schemas"],
    testonly = True,
    visibility = ["//visibility:public"],
)
```

Then run:

```bash
bazel test //:test_validation
```

### Can I prevent build failures on validation errors?

Yes, set `fail_on_error = False`:

```python
weaver_validate(
    name = "validate_schemas",
    schemas = [":my_schemas"],
    fail_on_error = False,
    visibility = ["//visibility:public"],
)
```

## Convenience Macros

### What is the `weaver_library` macro?

The `weaver_library` macro combines schema declaration, code generation, and validation into a single target:

```python
load("@rules_weaver//weaver:defs.bzl", "weaver_library")

weaver_library(
    name = "my_library",
    srcs = ["schema.yaml"],
    format = "typescript",
    validation = True,
    visibility = ["//visibility:public"],
)
```

This creates three targets:
- `my_library` - Schema target
- `my_library_generated` - Generated code
- `my_library_validation` - Validation target

### When should I use `weaver_library` vs individual rules?

Use `weaver_library` for:
- Simple use cases
- Quick prototyping
- Standard workflows

Use individual rules for:
- Complex configurations
- Custom build logic
- Fine-grained control

## Integration

### How do I integrate with TypeScript projects?

```python
load("@rules_weaver//weaver:defs.bzl", "weaver_library")
load("@npm//@bazel/typescript:index.bzl", "ts_project")

# Generate types
weaver_library(
    name = "user_types",
    srcs = ["user.yaml"],
    format = "typescript",
    visibility = ["//visibility:public"],
)

# Use in TypeScript project
ts_project(
    name = "user_app",
    srcs = ["user.ts"],
    deps = [":user_types_generated"],
    visibility = ["//visibility:public"],
)
```

### How do I integrate with Go projects?

```python
load("@rules_weaver//weaver:defs.bzl", "weaver_library")
load("@io_bazel_rules_go//go:def.bzl", "go_binary")

# Generate Go types
weaver_library(
    name = "user_types",
    srcs = ["user.yaml"],
    format = "go",
    visibility = ["//visibility:public"],
)

# Use in Go binary
go_binary(
    name = "user_app",
    srcs = ["main.go"],
    deps = [":user_types_generated"],
    visibility = ["//visibility:public"],
)
```

### Can I use generated types in other Bazel rules?

Yes, generated types can be used as dependencies in any Bazel rule that accepts file dependencies.

## Performance

### How can I optimize build performance?

1. **Enable caching**:
```bash
bazel build --disk_cache=/path/to/cache //:target
```

2. **Use remote execution**:
```bash
bazel build --remote_executor=grpc://executor.example.com:8080 //:target
```

3. **Group related schemas**:
```python
weaver_schema(
    name = "user_schemas",
    srcs = ["user.yaml", "profile.yaml"],
)
```

### Why are my builds slow?

Common causes:
- No caching enabled
- Large schema files
- Too many schemas processed at once
- Network issues downloading Weaver binary

### How can I reduce memory usage?

1. **Split large schemas**:
```python
weaver_schema(
    name = "schema_part_1",
    srcs = ["large_schema_part1.yaml"],
)
```

2. **Process schemas incrementally**:
```python
weaver_generate(
    name = "generate_1",
    srcs = [":schema_1"],
)
```

3. **Increase Bazel memory**:
```bash
bazel build --host_jvm_args=-Xmx4g //:target
```

## Troubleshooting

### Build fails with "No such target"

Check:
1. Target name is correct
2. BUILD file exists
3. Target is properly declared

```bash
# List all targets in package
bazel query //path/to:all
```

### Generated files not found

Find generated files with:

```bash
bazel query --output=location //:target_generated
```

### Validation fails but works manually

Check:
1. All dependencies are declared
2. Policy files are included
3. Weaver version compatibility

### SHA256 mismatch error

Get the correct hash:

```bash
curl -L <url> | sha256sum
```

Or temporarily skip verification:

```python
weaver_repository(
    name = "weaver",
    version = "0.1.0",
    skip_sha256_verification = True,
)
```

### Platform not supported

Check your platform:

```bash
uname -s -m
```

Add platform-specific configuration:

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

## Migration

### How do I migrate from manual Weaver usage?

See the [Migration Guide](migration_guide.md) for step-by-step instructions.

### Can I use both manual and Bazel Weaver during migration?

Yes, you can maintain both workflows during transition:

```bash
if [ "$USE_BAZEL" = "true" ]; then
    bazel build //:schemas_generated
else
    ./weaver generate --format typescript --output ./generated schemas/*.yaml
fi
```

### How do I verify my migration was successful?

Test your setup:

```bash
# Test basic functionality
bazel build //:all_schemas_generated
bazel test //:all_schemas_validation

# Compare generated output
diff -r ./old-generated ./bazel-bin/path/to/generated
```

## Advanced Topics

### How do I use environment variables?

```python
weaver_generate(
    name = "my_types",
    srcs = [":my_schemas"],
    env = {
        "WEAVER_LOG_LEVEL": "debug",
        "WEAVER_CACHE_DIR": "/tmp/weaver-cache",
    },
)
```

### Can I use custom Weaver arguments?

Yes, use the `args` attribute:

```python
weaver_generate(
    name = "my_types",
    srcs = [":my_schemas"],
    args = ["--verbose", "--strict", "--config", "weaver.config.yaml"],
)
```

### How do I handle schema dependencies?

Declare dependencies in the `deps` attribute:

```python
weaver_schema(
    name = "user_schemas",
    srcs = ["user.yaml"],
    deps = [":base_schemas", ":auth_schemas"],
)
```

### Can I use the rules in a monorepo?

Yes, the rules work well in monorepos. Organize schemas by service or domain:

```python
# //services/user/BUILD.bazel
weaver_library(
    name = "user_schemas",
    srcs = ["user.yaml"],
    format = "typescript",
    visibility = ["//visibility:public"],
)

# //services/product/BUILD.bazel
weaver_library(
    name = "product_schemas",
    srcs = ["product.yaml"],
    format = "typescript",
    visibility = ["//visibility:public"],
)
```

## Getting Help

### Where can I get help?

1. **Documentation**: [Complete documentation](README.md)
2. **Examples**: [Usage examples](examples/)
3. **GitHub Issues**: [Report bugs](https://github.com/open-telemetry/weaver/issues)
4. **GitHub Discussions**: [Ask questions](https://github.com/open-telemetry/weaver/discussions)

### How do I report a bug?

Include:
1. Bazel version: `bazel --version`
2. Platform: `uname -s -m`
3. Complete error message
4. Minimal reproduction steps
5. WORKSPACE and BUILD file configuration

### Can I contribute?

Yes! Contributions are welcome. See the [Contributing Guide](contributing.md) for details.

## Version Compatibility

### What Weaver versions are supported?

- **0.1.0+**: Full support
- **< 0.1.0**: Not supported

### How do I update Weaver version?

Update the version in your `WORKSPACE`:

```python
weaver_repository(
    name = "weaver",
    version = "0.2.0",  # Update to new version
    sha256 = "new-sha256-here",
)
```

### Are there breaking changes between versions?

Check the [OpenTelemetry Weaver changelog](https://github.com/open-telemetry/weaver/releases) for breaking changes between versions. 