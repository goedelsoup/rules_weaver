# weaver_validate Rule

The `weaver_validate` rule validates OpenTelemetry schemas using the Weaver tool. This rule can operate in both build mode (where validation failures cause build failures) and test mode (where validation results are reported as test outcomes).

## Basic Usage

```python
load("//weaver:defs.bzl", "weaver_validate")

weaver_validate(
    name = "validate_my_schemas",
    schemas = ["schema.yaml"],
)
```

## Parameters

### Required Parameters

- `name`: The name of the target (required)
- `schemas`: List of schema files or schema targets to validate (required)

### Optional Parameters

- `policies`: List of policy files for validation (optional, default: `[]`)
- `weaver`: Weaver binary to use (optional, defaults to toolchain)
- `args`: Additional validation arguments (optional, default: `[]`)
- `env`: Environment variables for the validation action (optional, default: `{}`)
- `fail_on_error`: Whether to fail build on validation error (optional, default: `True`)

## Examples

### Basic Validation

```python
weaver_validate(
    name = "validate_basic",
    schemas = ["my_schema.yaml"],
)
```

### Validation with Policies

```python
weaver_validate(
    name = "validate_with_policies",
    schemas = ["my_schema.yaml"],
    policies = ["my_policy.yaml"],
)
```

### Validation as a Test

```python
weaver_validate(
    name = "validate_as_test",
    testonly = True,
    schemas = ["my_schema.yaml"],
    policies = ["my_policy.yaml"],
)
```

### Validation with Custom Arguments

```python
weaver_validate(
    name = "validate_strict",
    schemas = ["my_schema.yaml"],
    args = ["--strict", "--verbose"],
)
```

### Validation with Environment Variables

```python
weaver_validate(
    name = "validate_debug",
    schemas = ["my_schema.yaml"],
    env = {"WEAVER_LOG_LEVEL": "debug"},
)
```

### Multiple Schemas and Policies

```python
weaver_validate(
    name = "validate_comprehensive",
    schemas = [
        "schema1.yaml",
        "schema2.yaml",
        "schema3.yaml",
    ],
    policies = [
        "policy1.yaml",
        "policy2.yaml",
    ],
    args = ["--strict"],
    env = {"WEAVER_LOG_LEVEL": "info"},
)
```

## Validation Modes

### Build Mode

When `testonly = False` (default), the rule operates in build mode:

- Validation failures cause build failures
- The rule produces a validation output file
- The rule can be used as a dependency in other build targets

### Test Mode

When `testonly = True`, the rule operates in test mode:

- Validation results are reported as test outcomes
- The rule integrates with Bazel's testing framework
- Validation failures are reported as test failures

## Policy Enforcement

The `weaver_validate` rule supports policy enforcement through policy files:

- Policy files define validation rules and constraints
- Multiple policies can be applied to the same schemas
- Policies can enforce naming conventions, required attributes, and type constraints

### Policy File Format

Policy files should follow the Weaver policy format:

```yaml
policy:
  name: "my_policy"
  version: "1.0.0"
  
  rules:
    - name: "require_service_name"
      description: "All services must have a service.name attribute"
      type: "resource"
      condition: "service"
      validation:
        required_attributes:
          - "service.name"
```

## Error Handling

### fail_on_error Parameter

The `fail_on_error` parameter controls how validation errors are handled:

- `True` (default): Validation errors cause build/test failures
- `False`: Validation errors are reported but don't cause failures

### Validation Output

The rule produces a validation output file containing:

- Validation results and status
- Error messages and warnings
- Policy violation details
- Schema validation information

## Integration with Bazel

### Toolchain Integration

The rule automatically uses the Weaver toolchain:

- Resolves the Weaver binary from the toolchain
- Uses toolchain-specific configuration
- Supports custom Weaver binaries through the `weaver` parameter

### Test Integration

When used as a test (`testonly = True`):

- Integrates with Bazel's test runner
- Reports validation results as test outcomes
- Supports test result aggregation
- Can be included in test suites

### Build Integration

When used in build mode:

- Can be used as a dependency in other rules
- Provides validation output files
- Supports build-time validation enforcement

## Best Practices

### Schema Organization

- Group related schemas together
- Use descriptive target names
- Organize schemas by service or component

### Policy Management

- Create reusable policy files
- Use policy inheritance and composition
- Document policy requirements

### Validation Strategy

- Use build mode for critical validation
- Use test mode for exploratory validation
- Combine multiple validation approaches

### Error Handling

- Set appropriate `fail_on_error` values
- Review validation output files
- Address validation errors promptly

## Troubleshooting

### Common Issues

1. **Schema not found**: Ensure schema files exist and are properly referenced
2. **Policy not applied**: Check policy file format and references
3. **Validation failures**: Review validation output for specific error details
4. **Toolchain issues**: Verify Weaver toolchain is properly configured

### Debugging

- Use `--verbose` argument for detailed output
- Set `WEAVER_LOG_LEVEL=debug` environment variable
- Review validation output files for error details
- Check Bazel build logs for action execution details 