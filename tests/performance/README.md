# Performance Tests

This directory contains performance tests and benchmarks for the OpenTelemetry Weaver rules.

## Purpose

Performance tests verify that the Weaver rules perform well and detect performance regressions. They test:
- Large schema processing performance
- Incremental build performance
- Multi-platform build performance
- Remote execution performance
- Memory usage and resource consumption
- Build time benchmarks

## Test Files

- `performance_test.bzl` - General performance benchmarks and tests
- `multi_platform_test.bzl` - Multi-platform performance tests
- `remote_execution_test.bzl` - Remote execution performance tests

## Running Tests

```bash
# Run all performance tests
bazel test //tests/performance:all_performance_tests

# Run individual test suites (when implemented)
bazel test //tests/performance:performance_test
bazel test //tests/performance:multi_platform_test
bazel test //tests/performance:remote_execution_test
```

## Performance Metrics

These tests measure:
- Build time for various schema sizes
- Memory usage during processing
- Incremental build performance
- Cross-platform build performance
- Remote execution efficiency 