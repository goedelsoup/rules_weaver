# Error Tests

This directory will contain error scenario tests for the OpenTelemetry Weaver rules.

## Purpose

Error tests verify that the Weaver rules handle error conditions gracefully. They will test:
- Invalid schema handling
- Missing dependency scenarios
- Configuration errors
- Platform-specific errors
- Network and connectivity issues
- Resource exhaustion scenarios

## Future Test Files

- `invalid_schema_test.bzl` - Tests for invalid schema handling
- `missing_dependency_test.bzl` - Tests for missing dependency scenarios
- `configuration_error_test.bzl` - Tests for configuration errors
- `platform_error_test.bzl` - Tests for platform-specific errors
- `network_error_test.bzl` - Tests for network and connectivity issues

## Running Tests

```bash
# Run all error tests (when implemented)
bazel test //tests/error:all_error_tests

# Run individual error test suites (when implemented)
bazel test //tests/error:invalid_schema_test
bazel test //tests/error:missing_dependency_test
# etc.
```

## Error Scenarios

These tests will cover:
- Malformed YAML/JSON schemas
- Missing required fields
- Invalid field types
- Circular dependencies
- Unresolvable dependencies
- Permission errors
- Disk space issues
- Memory exhaustion 