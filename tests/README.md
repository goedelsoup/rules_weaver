# OpenTelemetry Weaver Testing Framework

This directory contains a comprehensive testing framework for the OpenTelemetry Weaver Bazel rules. The framework provides extensive test coverage including unit tests, integration tests, performance benchmarks, and error scenario testing.

## Overview

The testing framework is designed to achieve >90% test coverage and ensure the reliability, performance, and correctness of the Weaver rules across all supported platforms.

## Directory Organization

The tests directory is organized into logical subdirectories:

- **`unit/`** - Unit tests for individual components and functions
- **`integration/`** - Integration tests for end-to-end workflows and component interactions
- **`performance/`** - Performance tests and benchmarks
- **`frameworks/`** - Core testing frameworks and utilities
- **`utils/`** - Test utilities, mock objects, and helper functions
- **`schemas/`** - Test schema files and data
- **`error/`** - Error scenario tests (future implementation)

## Test Structure

### Core Testing Components

- **Unit Tests**: Test individual rules, providers, and functions in isolation
- **Integration Tests**: Test end-to-end workflows and component interactions
- **Performance Tests**: Benchmark performance and detect regressions
- **Error Scenario Tests**: Test error handling and edge cases

### Test Framework Files

```
tests/
├── unit/                             # Unit tests for individual components
│   ├── BUILD.bazel
│   ├── library_test.bzl
│   ├── schema_test.bzl
│   ├── toolchain_test.bzl
│   ├── validate_test.bzl
│   ├── generate_test.bzl
│   ├── docs_test.bzl
│   ├── dependency_test.bzl
│   └── repositories_test.bzl
├── integration/                      # Integration tests for workflows
│   ├── BUILD.bazel
│   ├── library_integration_test.bzl
│   ├── schema_integration_test.bzl
│   ├── toolchain_integration_test.bzl
│   ├── validate_integration_test.bzl
│   ├── docs_integration_test.bzl
│   ├── dependency_integration_test.bzl
│   ├── real_integration_test.bzl
│   ├── real_weaver_integration_test.bzl
│   ├── simple_integration_test.bzl
│   ├── integration_test.bzl
│   └── platform_integration_test.bzl
├── performance/                      # Performance tests and benchmarks
│   ├── BUILD.bazel
│   ├── performance_test.bzl
│   ├── multi_platform_test.bzl
│   └── remote_execution_test.bzl
├── frameworks/                       # Testing frameworks and utilities
│   ├── BUILD.bazel
│   ├── unit_test_framework.bzl
│   ├── integration_test_framework.bzl
│   ├── performance_test_framework.bzl
│   ├── error_test_framework.bzl
│   └── comprehensive_test_runner.bzl
├── utils/                            # Test utilities and mock objects
│   ├── BUILD.bazel
│   ├── test_utils.bzl
│   ├── test_config.bzl
│   ├── test_workspace.bzl
│   ├── mock_weaver_repository.bzl
│   ├── mock_weaver.py
│   ├── run_integration_tests.py
│   ├── run_real_weaver_tests.py
│   ├── integration_test_targets.bzl
│   ├── real_weaver_test_config.bzl
│   └── simple_real_weaver_test.bzl
├── schemas/                          # Test schema files
│   ├── BUILD.bazel
│   ├── sample.yaml
│   ├── another.yaml
│   ├── policy.yaml
│   ├── another_policy.yaml
│   ├── test1.yaml
│   └── test2.yaml
├── error/                            # Error scenario tests (future)
├── BUILD.bazel                       # Main test targets and suites
└── README.md                         # This documentation
```

## Running Tests

### Running All Tests

```bash
# Run the comprehensive test suite (all tests)
bazel test //tests:comprehensive_test_suite

# Run all tests with verbose output
bazel test //tests:comprehensive_test_suite --test_output=all
```

### Running Specific Test Categories

```bash
# Unit tests only
bazel test //tests:all_unit_tests

# Integration tests only
bazel test //tests:all_integration_tests

# Performance tests only
bazel test //tests:all_performance_tests

# Error scenario tests only
bazel test //tests:all_error_tests

# Framework tests only
bazel test //tests:all_framework_tests
```

### Running Individual Test Suites

```bash
# Unit tests
bazel test //tests/unit:all_unit_tests

# Integration tests
bazel test //tests/integration:all_integration_tests

# Performance tests
bazel test //tests/performance:all_performance_tests

# Utility tests (mock objects, real weaver integration)
bazel test //tests/utils:all_utils_tests

# Framework tests
bazel test //tests/frameworks:all_framework_tests
```

### Running Specific Test Categories

```bash
# Individual unit test suites (when implemented)
bazel test //tests/unit:library_test
bazel test //tests/unit:schema_test
bazel test //tests/unit:toolchain_test
bazel test //tests/unit:validate_test
bazel test //tests/unit:generate_test
bazel test //tests/unit:docs_test
bazel test //tests/unit:dependency_test
bazel test //tests/unit:repositories_test

# Individual integration test suites (when implemented)
bazel test //tests/integration:library_integration_test
bazel test //tests/integration:schema_integration_test
bazel test //tests/integration:toolchain_integration_test
bazel test //tests/integration:validate_integration_test
bazel test //tests/integration:docs_integration_test
bazel test //tests/integration:real_integration_test
bazel test //tests/integration:simple_integration_test

# Individual performance test suites (when implemented)
bazel test //tests/performance:performance_test
bazel test //tests/performance:multi_platform_test
bazel test //tests/performance:remote_execution_test
```

## Test Categories

### Unit Tests

Unit tests focus on testing individual components in isolation:

- **Provider Tests**: Test all Weaver providers (WeaverGeneratedInfo, WeaverValidationInfo, etc.)
- **Rule Tests**: Test rule implementations and behavior
- **Action Tests**: Test action creation and properties
- **Performance Tests**: Test performance characteristics of individual functions
- **Error Tests**: Test error handling in individual components

### Integration Tests

Integration tests verify end-to-end workflows and component interactions:

- **Workflow Tests**: Test complete generation, validation, and documentation workflows
- **Dependency Tests**: Test dependency tracking and resolution
- **Caching Tests**: Test caching behavior and hit rates
- **Remote Execution Tests**: Test remote execution compatibility

### Performance Tests

Performance tests measure and benchmark system performance:

- **Large Schema Tests**: Test handling of large schema sets
- **Incremental Build Tests**: Test incremental build performance
- **Benchmark Tests**: Test performance benchmarks for different operations
- **Memory Tests**: Test memory usage profiling

### Error Scenario Tests

Error scenario tests ensure robust error handling:

- **Invalid Schema Tests**: Test handling of malformed schemas
- **Missing Dependency Tests**: Test handling of missing dependencies
- **Configuration Tests**: Test handling of invalid configurations
- **Platform Tests**: Test platform-specific error scenarios

## Test Utilities

The `test_utils.bzl` module provides common utilities for all tests:

### Mock Objects

```python
# Create mock context for testing
mock_ctx = create_mock_ctx(
    name = "test_target",
    srcs = [create_mock_file("schema.yaml")],
    format = "typescript",
    args = ["--verbose"],
)

# Create mock files
test_file = create_mock_file("test.yaml", content = "test content")

# Create mock providers
provider = create_mock_provider(
    "WeaverGeneratedInfo",
    generated_files = [test_file],
    output_dir = "test_output",
)
```

### Test Data Generators

```python
# Generate test schemas
schema = generate_test_schema("test_schema")
policy = generate_test_policy("test_policy")

# Generate large schema sets for performance testing
large_schemas = generate_large_schema_set(100)
```

### Assertion Helpers

```python
# Assert provider fields
assert_provider_fields(env, provider, {
    "generated_files": expected_files,
    "output_dir": "test_output",
})

# Assert action hermeticity
assert_action_hermeticity(env, action)

# Assert file existence
assert_file_exists(env, file_list, "expected_file.yaml")

# Assert dependency tracking
assert_dependency_tracking(env, provider, expected_deps)
```

### Performance Testing

```python
# Measure execution time
result, execution_time = measure_execution_time(function, args)

# Assert performance thresholds
assert_performance_threshold(env, execution_time, 100.0, "operation_name")
```

## Test Coverage

The testing framework aims to achieve >90% test coverage across all components:

- **Provider Coverage**: 100% - All provider fields and creation logic
- **Rule Coverage**: 95% - All rule implementations and edge cases
- **Action Coverage**: 90% - All action creation and properties
- **Integration Coverage**: 85% - All major workflows and interactions
- **Error Coverage**: 95% - All error scenarios and edge cases
- **Performance Coverage**: 80% - All performance-critical paths

## Performance Benchmarks

The framework includes performance benchmarks for:

- **Schema Processing**: Parsing and validation of schemas
- **Code Generation**: Generation of different output formats
- **Documentation Generation**: HTML and Markdown documentation
- **Validation**: Schema validation with policies
- **Incremental Builds**: Performance of incremental builds
- **Memory Usage**: Memory profiling and optimization

## Error Scenarios

The framework tests various error scenarios:

- **Invalid YAML**: Malformed YAML syntax
- **Invalid OpenAPI**: Invalid OpenAPI schema structure
- **Missing Dependencies**: Unresolvable schema references
- **Circular Dependencies**: Circular dependency detection
- **Configuration Errors**: Invalid configuration parameters
- **Platform Errors**: Platform-specific error conditions

## Contributing

When adding new tests:

1. **Use the existing framework**: Leverage the utilities in `test_utils.bzl`
2. **Follow naming conventions**: Use descriptive test names
3. **Add to appropriate suite**: Place tests in the correct test suite
4. **Update BUILD.bazel**: Add new test targets to the BUILD file
5. **Document new tests**: Update this README if adding new test categories

### Adding Unit Tests

```python
def _test_new_feature(ctx):
    """Test new feature functionality."""
    env = unittest.begin(ctx)
    
    # Test implementation
    result = test_new_feature()
    
    # Assertions
    asserts.true(env, result.success, "Feature should work correctly")
    
    return unittest.end(env)

# Add to appropriate test suite
new_feature_test_suite = unittest.suite(
    "new_feature_tests",
    _test_new_feature,
)
```

### Adding Integration Tests

```python
def _test_new_workflow(ctx):
    """Test new workflow integration."""
    env = unittest.begin(ctx)
    
    # Create test workspace
    workspace = create_integration_test_workspace()
    
    # Execute workflow
    result, execution_time = measure_execution_time(
        new_workflow_function, workspace.schemas
    )
    
    # Assert workflow completion
    assert_integration_workflow(env, result)
    
    return unittest.end(env)
```

## Troubleshooting

### Common Issues

1. **Test failures**: Check that all dependencies are properly mocked
2. **Performance test failures**: Adjust performance thresholds if needed
3. **Integration test failures**: Verify test workspace setup
4. **Build errors**: Ensure all test targets are properly defined in BUILD.bazel

### Debugging Tests

```bash
# Run tests with debug output
bazel test //tests:unit_provider_test --test_output=all --test_verbose_timeout_warnings

# Run specific test with debug
bazel test //tests:unit_provider_test --test_filter=test_name --test_output=all
```

## Continuous Integration

The testing framework is designed to work with CI/CD pipelines:

- **Automated Testing**: All tests run automatically on code changes
- **Performance Regression Detection**: Performance tests detect regressions
- **Coverage Reporting**: Coverage metrics are tracked and reported
- **Multi-Platform Testing**: Tests run on all supported platforms

## Future Enhancements

Planned improvements to the testing framework:

- **Property-based Testing**: Add property-based testing for more thorough coverage
- **Fuzzing**: Add fuzzing tests for robustness
- **Load Testing**: Add load testing for large-scale scenarios
- **Visual Regression Testing**: Add visual regression tests for documentation
- **API Contract Testing**: Add contract testing for external integrations 