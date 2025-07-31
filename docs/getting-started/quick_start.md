# Quick Start Guide

Get up and running with Bazel OpenTelemetry Weaver rules in under 5 minutes!

## Prerequisites

- Bazel 5.0 or later
- A Bazel workspace

## Step 1: Set Up Your Workspace

Add the following to your `WORKSPACE` file:

```python
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# Download the Weaver rules
http_archive(
    name = "rules_weaver",
    sha256 = "YOUR_SHA256_HERE",  # Replace with actual SHA256
    strip_prefix = "rules_weaver-main",
    url = "https://github.com/open-telemetry/weaver/archive/main.zip",
)

# Load and configure Weaver
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

## Step 2: Create Your First Schema

Create a file `schema.yaml` in your project:

```yaml
# schema.yaml
version: "1.0"
schemas:
  - name: "User"
    type: "object"
    properties:
      id:
        type: "string"
        description: "User identifier"
      name:
        type: "string"
        description: "User's full name"
      email:
        type: "string"
        format: "email"
        description: "User's email address"
      created_at:
        type: "string"
        format: "date-time"
        description: "Account creation timestamp"
    required: ["id", "name", "email"]
```

## Step 3: Create Your BUILD File

Create a `BUILD` file in the same directory:

```python
load("@rules_weaver//weaver:defs.bzl", "weaver_library")

weaver_library(
    name = "user_schemas",
    srcs = ["schema.yaml"],
    format = "typescript",
    visibility = ["//visibility:public"],
)
```

## Step 4: Generate Code

Run the following command to generate TypeScript code from your schema:

```bash
bazel build //path/to/your:user_schemas_generated
```

This will create:
- `user_schemas` - The schema target
- `user_schemas_generated` - Generated TypeScript code
- `user_schemas_validation` - Schema validation target

## Step 5: Use Generated Code

The generated TypeScript code will be available at:
```
bazel-bin/path/to/your/user_schemas_generated/
```

You can now use the generated types in your TypeScript code:

```typescript
import { User } from './user_schemas_generated/types';

const user: User = {
    id: "123",
    name: "John Doe",
    email: "john@example.com",
    created_at: new Date().toISOString(),
};
```

## What Just Happened?

The `weaver_library` macro created three targets for you:

1. **Schema Target** (`user_schemas`): Declares your schema files as Bazel targets
2. **Generated Code Target** (`user_schemas_generated`): Generates TypeScript code from your schemas
3. **Validation Target** (`user_schemas_validation`): Validates your schemas for correctness

## Next Steps

### Add Validation

Create a policy file `policy.yaml`:

```yaml
# policy.yaml
policies:
  - name: "email_format"
    rule: "email_must_be_valid"
    message: "Email addresses must be valid"
```

Update your BUILD file:

```python
weaver_library(
    name = "user_schemas",
    srcs = ["schema.yaml"],
    format = "typescript",
    validation = True,
    policies = ["policy.yaml"],
    visibility = ["//visibility:public"],
)
```

Run validation:

```bash
bazel test //path/to/your:user_schemas_validation
```

### Add More Schemas

Create additional schema files and reference them:

```python
weaver_library(
    name = "all_schemas",
    srcs = [
        "user_schema.yaml",
        "product_schema.yaml",
        "order_schema.yaml",
    ],
    format = "typescript",
    visibility = ["//visibility:public"],
)
```

### Use Different Output Formats

Generate different types of code:

```python
# Generate Go code
weaver_library(
    name = "go_schemas",
    srcs = ["schema.yaml"],
    format = "go",
    visibility = ["//visibility:public"],
)

# Generate Python code
weaver_library(
    name = "python_schemas",
    srcs = ["schema.yaml"],
    format = "python",
    visibility = ["//visibility:public"],
)
```

## Common Commands

```bash
# Build generated code
bazel build //path/to/your:target_generated

# Test validation
bazel test //path/to/your:target_validation

# Clean generated files
bazel clean

# Show generated files
bazel query --output=location //path/to/your:target_generated

# Run with verbose output
bazel build //path/to/your:target_generated --verbose_failures
```

## Troubleshooting

### Build Fails

If your build fails, check:

1. **Schema syntax**: Ensure your YAML is valid
2. **File paths**: Verify schema files exist
3. **Bazel version**: Ensure you're using Bazel 5.0+

### No Generated Files

If no files are generated:

1. Check the build output for errors
2. Verify the schema format is supported
3. Ensure the output format is correct

### Validation Fails

If validation fails:

1. Check the validation output for specific errors
2. Verify your schema against the OpenTelemetry schema specification
3. Review any policy files for correctness

## What's Next?

Now that you're up and running:

1. Explore [Basic Examples](examples/basic_usage.md) for more usage patterns
2. Read the [API Reference](api_reference.md) for complete documentation
3. Check out [Advanced Examples](examples/advanced_usage.md) for complex scenarios
4. Learn about [Migration](migration_guide.md) if you're coming from manual Weaver usage

Congratulations! You've successfully set up Bazel OpenTelemetry Weaver rules and generated your first code from schemas. 🎉 