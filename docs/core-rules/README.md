# Core Rules

Documentation for the fundamental Bazel OpenTelemetry Weaver rules that provide the core functionality.

## Rules

### [weaver_repository](weaver_repository.md)
Download and register Weaver binaries for hermetic Bazel builds:
- Binary download and verification
- Platform-specific configuration
- Version management
- Repository setup

### [weaver_schema](weaver_schema.md)
Declare and manage schema files as Bazel targets:
- Schema file declaration
- Dependency management
- Schema validation
- Target visibility

### [weaver_generate](weaver_generate.md)
Generate code from schemas using OpenTelemetry Weaver:
- Code generation workflows
- Output format configuration
- Custom arguments and environment
- Generated target management

### [weaver_validate](weaver_validate.md)
Validate schemas and policies:
- Schema validation
- Policy enforcement
- Validation workflows
- Error handling

### [weaver_library](weaver_library.md)
Convenience macro for common workflows:
- Simplified rule combinations
- Common patterns
- Best practices
- Workflow optimization

## Usage Patterns

These core rules can be combined to create powerful workflows:
1. **Basic Workflow**: `weaver_repository` → `weaver_schema` → `weaver_generate`
2. **Validation Workflow**: `weaver_schema` → `weaver_validate`
3. **Library Workflow**: `weaver_library` (combines multiple rules)

## Related Documentation

- [API Reference](../reference/api_reference.md) - Complete parameter documentation
- [Advanced Topics](../advanced-topics/) - Complex usage scenarios
- [Examples](../examples/) - Practical implementation examples 