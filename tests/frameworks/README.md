# Testing Frameworks

This directory contains the core testing frameworks and utilities for the OpenTelemetry Weaver rules.

## Purpose

The testing frameworks provide the infrastructure and utilities for writing and running tests. They include:
- Unit testing framework for testing individual components
- Integration testing framework for testing workflows
- Performance testing framework for benchmarks
- Error testing framework for error scenarios
- Comprehensive test runner for orchestrating all tests

## Framework Files

- `unit_test_framework.bzl` - Framework for unit testing individual components
- `integration_test_framework.bzl` - Framework for integration testing workflows
- `performance_test_framework.bzl` - Framework for performance testing and benchmarking
- `error_test_framework.bzl` - Framework for testing error scenarios and edge cases
- `comprehensive_test_runner.bzl` - Test orchestration and reporting framework

## Usage

These frameworks are used by test files in other directories. They provide:
- Common test utilities and helpers
- Mock objects and test data generators
- Test suite creation and management
- Performance measurement utilities
- Error scenario testing utilities
- Test reporting and aggregation

## Running Framework Tests

```bash
# Run all framework tests
bazel test //tests/frameworks:all_framework_tests
``` 