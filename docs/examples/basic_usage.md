# Basic Usage Examples

Simple examples demonstrating basic usage of Bazel OpenTelemetry Weaver rules.

## Prerequisites

- Bazel 5.0 or later
- Weaver rules installed in your workspace (see [Installation Guide](../getting-started/installation.md))

## Example 1: Basic Schema Definition

Create a simple schema file `schema.yaml`:

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

Create a `BUILD` file to declare the schema:

```python
load("@rules_weaver//weaver:defs.bzl", "weaver_schema")

weaver_schema(
    name = "user_schemas",
    srcs = ["schema.yaml"],
    visibility = ["//visibility:public"],
)
```

## Example 2: Basic Code Generation

Generate TypeScript code from your schema:

```python
load("@rules_weaver//weaver:defs.bzl", "weaver_generate")

weaver_generate(
    name = "user_typescript",
    srcs = [":user_schemas"],
    format = "typescript",
    out_dir = "generated",
    visibility = ["//visibility:public"],
)
```

Build the generated code:

```bash
bazel build //path/to/your:user_typescript
```

## Example 3: Basic Validation

Validate your schema against policies:

```python
load("@rules_weaver//weaver:defs.bzl", "weaver_validate")

weaver_validate(
    name = "validate_user_schema",
    srcs = [":user_schemas"],
    policies = ["//path/to/policies:naming.rego"],
    testonly = True,
)
```

Run the validation:

```bash
bazel test //path/to/your:validate_user_schema
```

## Example 4: Using weaver_library Macro

The `weaver_library` macro combines schema declaration, code generation, and validation:

```python
load("@rules_weaver//weaver:defs.bzl", "weaver_library")

weaver_library(
    name = "user_library",
    srcs = ["schema.yaml"],
    format = "typescript",
    policies = ["//path/to/policies:naming.rego"],
    visibility = ["//visibility:public"],
)
```

This creates:
- `user_library` - The schema target
- `user_library_generated` - Generated TypeScript code
- `user_library_validation` - Schema validation target

## Example 5: Multiple Schemas

Define multiple schemas in a single target:

```python
weaver_schema(
    name = "api_schemas",
    srcs = [
        "user.yaml",
        "product.yaml",
        "order.yaml",
    ],
    visibility = ["//visibility:public"],
)
```

## Example 6: Schema Dependencies

Create schemas with dependencies:

```python
weaver_schema(
    name = "common_schemas",
    srcs = ["common.yaml"],
    visibility = ["//visibility:public"],
)

weaver_schema(
    name = "business_schemas",
    srcs = ["business.yaml"],
    deps = [":common_schemas"],
    visibility = ["//visibility:public"],
)
```

## Example 7: Custom Output Configuration

Generate code with custom output settings:

```python
weaver_generate(
    name = "custom_output",
    srcs = [":user_schemas"],
    format = "typescript",
    out_dir = "src/generated",
    args = [
        "--verbose",
        "--no-cache",
        "--output-format", "es6",
    ],
    env = {
        "DEBUG": "1",
        "LOG_LEVEL": "info",
    },
    visibility = ["//visibility:public"],
)
```

## Example 8: Repository Setup

Set up Weaver repository in your `WORKSPACE` file:

```python
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

## Common Workflows

### Basic Workflow
1. Define schemas with `weaver_schema`
2. Generate code with `weaver_generate`
3. Validate with `weaver_validate`

### Library Workflow
1. Use `weaver_library` for simple projects
2. Combines schema, generation, and validation

### Multi-Schema Workflow
1. Define base schemas
2. Create dependent schemas
3. Generate code for all schemas together

## Next Steps

After mastering these basic examples:
- Explore [Core Rules](../core-rules/) for detailed rule documentation
- Check [Advanced Topics](../advanced-topics/) for complex scenarios
- Review [Reference](../reference/) for complete API documentation 