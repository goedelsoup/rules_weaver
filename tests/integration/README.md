# Integration Tests

This directory contains integration tests for end-to-end workflows and component interactions of the OpenTelemetry Weaver rules.

## Purpose

Integration tests verify that components work together correctly. They test:
- End-to-end workflows from schema to generated code
- Component interactions and data flow
- Real Weaver integration scenarios
- Platform-specific behavior
- Dependency resolution and management
- Caching and incremental builds

## Test Files

- `library_integration_test.bzl` - Integration tests for library workflows
- `schema_integration_test.bzl` - Integration tests for schema processing workflows
- `toolchain_integration_test.bzl` - Integration tests for toolchain setup and usage
- `validate_integration_test.bzl` - Integration tests for validation workflows
- `docs_integration_test.bzl` - Integration tests for documentation generation workflows
- `dependency_integration_test.bzl` - Integration tests for dependency management
- `dependency_performance_test.bzl` - Performance tests for dependency resolution
- `real_integration_test.bzl` - Integration tests with real Weaver binary
- `real_weaver_integration_test.bzl` - Comprehensive real Weaver integration tests
- `simple_integration_test.bzl` - Simple integration test scenarios
- `integration_test.bzl` - Basic integration test framework
- `platform_integration_test.bzl` - Platform-specific integration tests

## Running Tests

```bash
# Run all integration tests
bazel test //tests/integration:all_integration_tests

# Run individual test suites (when implemented)
bazel test //tests/integration:library_integration_test
bazel test //tests/integration:schema_integration_test
# etc.
``` 