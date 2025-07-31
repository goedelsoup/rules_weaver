# Basic Examples

Simple, single-purpose examples that demonstrate core Weaver functionality. These examples are perfect for getting started with Weaver rules.

## Examples

### weaver_generate_example.bzl
Demonstrates basic code generation from semantic convention schemas:
- Basic TypeScript generation from a single schema
- Multiple schemas generation
- Custom output directory configuration
- Environment variable usage
- Custom Weaver arguments

### weaver_validate_example.bzl
Shows how to validate semantic convention registries:
- Basic validation of local registries
- Remote registry validation
- Policy-based validation
- Custom validation arguments

### weaver_repository_example.bzl
Basic repository management examples:
- Simple repository configuration
- Local registry setup
- Basic dependency management

## Usage

Load and use these examples in your BUILD files:

```python
load("//examples/basic:weaver_generate_example.bzl", "basic_typescript_generation")
load("//examples/basic:weaver_validate_example.bzl", "validate_semantic_conventions")
load("//examples/basic:weaver_repository_example.bzl", "setup_basic_repository")
```

## Next Steps

After understanding these basic examples, explore:
- [Intermediate Examples](../intermediate/) for more complex scenarios
- [Advanced Examples](../advanced/) for production-ready patterns 