# Test Utilities

This directory contains test utilities, mock objects, and helper functions for the OpenTelemetry Weaver rules.

## Purpose

The utilities provide common functionality used across all test types. They include:
- Mock objects for testing without real dependencies
- Test data generators and helpers
- Test configuration management
- Real Weaver integration test setup
- Test runner scripts

## Utility Files

- `test_utils.bzl` - Common testing utilities and helpers
- `test_config.bzl` - Test configuration management
- `test_workspace.bzl` - Test workspace setup utilities
- `mock_weaver_repository.bzl` - Mock Weaver repository setup
- `mock_weaver.py` - Mock Weaver binary implementation
- `run_integration_tests.py` - Integration test runner script
- `run_real_weaver_tests.py` - Real Weaver test runner script
- `integration_test_targets.bzl` - Integration test target creation
- `real_weaver_test_config.bzl` - Real Weaver test configuration
- `simple_real_weaver_test.bzl` - Simple real Weaver test setup

## Mock Objects

- `mock_weaver.py` - Simulates the Weaver binary for testing
- `mock_weaver_repository.bzl` - Sets up mock Weaver toolchain
- Mock context objects for testing rules
- Mock file objects for testing file operations

## Running Utility Tests

```bash
# Run all utility tests
bazel test //tests/utils:all_utils_tests

# Run mock Weaver tests
bazel test //tests/utils:simple_real_weaver_test
bazel test //tests/utils:simple_real_weaver_generate

# Run test runner scripts
bazel run //tests/utils:run_integration_tests
bazel run //tests/utils:run_real_weaver_tests
``` 