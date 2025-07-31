# Unit Tests

This directory contains unit tests for individual components and functions of the OpenTelemetry Weaver rules.

## Purpose

Unit tests verify that individual components work correctly in isolation. They test:
- Individual rules and their implementations
- Provider functions and data structures
- Action implementations
- Utility functions
- Error handling for individual components

## Test Files

- `library_test.bzl` - Tests for library rule functionality
- `schema_test.bzl` - Tests for schema validation and processing
- `toolchain_test.bzl` - Tests for toolchain configuration and setup
- `validate_test.bzl` - Tests for validation rule functionality
- `generate_test.bzl` - Tests for code generation rule functionality
- `docs_test.bzl` - Tests for documentation generation functionality
- `dependency_test.bzl` - Tests for dependency management
- `repositories_test.bzl` - Tests for repository configuration

## Running Tests

```bash
# Run all unit tests
bazel test //tests/unit:all_unit_tests

# Run individual test suites (when implemented)
bazel test //tests/unit:library_test
bazel test //tests/unit:schema_test
# etc.
``` 