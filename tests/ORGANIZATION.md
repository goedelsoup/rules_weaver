# Tests Directory Organization

This document describes the organization of the tests directory for the OpenTelemetry Weaver rules.

## Overview

The tests directory has been reorganized into logical subdirectories to improve maintainability, discoverability, and scalability. Each subdirectory has a specific purpose and contains related test files.

## Directory Structure

```
tests/
├── unit/                             # Unit tests for individual components
│   ├── BUILD.bazel                   # Unit test targets
│   ├── README.md                     # Unit test documentation
│   ├── library_test.bzl              # Library rule tests
│   ├── schema_test.bzl               # Schema validation tests
│   ├── toolchain_test.bzl            # Toolchain tests
│   ├── validate_test.bzl             # Validation rule tests
│   ├── generate_test.bzl             # Code generation tests
│   ├── docs_test.bzl                 # Documentation generation tests
│   ├── dependency_test.bzl           # Dependency management tests
│   └── repositories_test.bzl         # Repository configuration tests
├── integration/                      # Integration tests for workflows
│   ├── BUILD.bazel                   # Integration test targets
│   ├── README.md                     # Integration test documentation
│   ├── library_integration_test.bzl  # Library workflow tests
│   ├── schema_integration_test.bzl   # Schema processing workflow tests
│   ├── toolchain_integration_test.bzl # Toolchain workflow tests
│   ├── validate_integration_test.bzl # Validation workflow tests
│   ├── docs_integration_test.bzl     # Documentation workflow tests
│   ├── dependency_integration_test.bzl # Dependency workflow tests
│   ├── dependency_performance_test.bzl # Dependency performance tests
│   ├── real_integration_test.bzl     # Real Weaver integration tests
│   ├── real_weaver_integration_test.bzl # Comprehensive real Weaver tests
│   ├── simple_integration_test.bzl   # Simple integration scenarios
│   ├── integration_test.bzl          # Basic integration framework
│   └── platform_integration_test.bzl # Platform-specific integration tests
├── performance/                      # Performance tests and benchmarks
│   ├── BUILD.bazel                   # Performance test targets
│   ├── README.md                     # Performance test documentation
│   ├── performance_test.bzl          # General performance benchmarks
│   ├── multi_platform_test.bzl       # Multi-platform performance tests
│   └── remote_execution_test.bzl     # Remote execution performance tests
├── frameworks/                       # Testing frameworks and utilities
│   ├── BUILD.bazel                   # Framework test targets
│   ├── README.md                     # Framework documentation
│   ├── unit_test_framework.bzl       # Unit testing framework
│   ├── integration_test_framework.bzl # Integration testing framework
│   ├── performance_test_framework.bzl # Performance testing framework
│   ├── error_test_framework.bzl      # Error scenario testing framework
│   └── comprehensive_test_runner.bzl # Test orchestration framework
├── utils/                            # Test utilities and mock objects
│   ├── BUILD.bazel                   # Utility targets
│   ├── README.md                     # Utility documentation
│   ├── test_utils.bzl                # Common testing utilities
│   ├── test_config.bzl               # Test configuration management
│   ├── test_workspace.bzl            # Test workspace setup
│   ├── mock_weaver_repository.bzl    # Mock Weaver repository setup
│   ├── mock_weaver.py                # Mock Weaver binary
│   ├── run_integration_tests.py      # Integration test runner
│   ├── run_real_weaver_tests.py      # Real Weaver test runner
│   ├── integration_test_targets.bzl  # Integration test target creation
│   ├── real_weaver_test_config.bzl   # Real Weaver test configuration
│   └── simple_real_weaver_test.bzl   # Simple real Weaver test setup
├── schemas/                          # Test schema files and data
│   ├── BUILD.bazel                   # Schema test targets
│   ├── BUILD_library_example.bzl     # Library example configuration
│   ├── sample.yaml                   # Sample schema file
│   ├── another.yaml                  # Another sample schema
│   ├── policy.yaml                   # Policy schema example
│   ├── another_policy.yaml           # Another policy schema
│   ├── test1.yaml                    # Test schema 1
│   └── test2.yaml                    # Test schema 2
├── error/                            # Error scenario tests (future)
│   ├── BUILD.bazel                   # Error test targets
│   └── README.md                     # Error test documentation
├── BUILD.bazel                       # Main test targets and suites
├── README.md                         # Main test documentation
└── ORGANIZATION.md                   # This file
```

## Test Categories

### Unit Tests (`unit/`)
- **Purpose**: Test individual components in isolation
- **Scope**: Individual rules, providers, functions, and utilities
- **Examples**: Testing a single rule implementation, provider data structures, utility functions

### Integration Tests (`integration/`)
- **Purpose**: Test end-to-end workflows and component interactions
- **Scope**: Complete workflows from schema to generated code
- **Examples**: Full schema processing pipeline, real Weaver integration, dependency resolution

### Performance Tests (`performance/`)
- **Purpose**: Benchmark performance and detect regressions
- **Scope**: Build times, memory usage, incremental builds, cross-platform performance
- **Examples**: Large schema processing, multi-platform builds, remote execution

### Frameworks (`frameworks/`)
- **Purpose**: Provide testing infrastructure and utilities
- **Scope**: Core testing frameworks used by other test types
- **Examples**: Unit testing framework, integration testing framework, test orchestration

### Utilities (`utils/`)
- **Purpose**: Provide common functionality and mock objects
- **Scope**: Mock objects, test data generators, configuration management
- **Examples**: Mock Weaver binary, test utilities, real Weaver integration setup

### Schemas (`schemas/`)
- **Purpose**: Provide test data and schema files
- **Scope**: YAML/JSON schema files used by tests
- **Examples**: Sample schemas, policy files, test configurations

### Error Tests (`error/`)
- **Purpose**: Test error handling and edge cases (future)
- **Scope**: Invalid schemas, missing dependencies, configuration errors
- **Examples**: Malformed YAML, circular dependencies, permission errors

## Running Tests

### All Tests
```bash
bazel test //tests:comprehensive_test_suite
```

### By Category
```bash
# Unit tests
bazel test //tests:all_unit_tests

# Integration tests
bazel test //tests:all_integration_tests

# Performance tests
bazel test //tests:all_performance_tests

# Utility tests
bazel test //tests:all_utils_tests

# Framework tests
bazel test //tests:all_framework_tests

# Error tests (when implemented)
bazel test //tests:all_error_tests
```

### By Subdirectory
```bash
# Unit tests
bazel test //tests/unit:all_unit_tests

# Integration tests
bazel test //tests/integration:all_integration_tests

# Performance tests
bazel test //tests/performance:all_performance_tests

# Utility tests
bazel test //tests/utils:all_utils_tests

# Framework tests
bazel test //tests/frameworks:all_framework_tests

# Error tests (when implemented)
bazel test //tests/error:all_error_tests
```

## Benefits of This Organization

1. **Discoverability**: Easy to find relevant tests by category
2. **Maintainability**: Related tests are grouped together
3. **Scalability**: Easy to add new test categories
4. **Isolation**: Tests are organized by scope and purpose
5. **Documentation**: Each subdirectory has its own README
6. **Build Organization**: BUILD files are organized by test type
7. **Import Clarity**: Clear import paths between test files

## Migration Notes

- All existing test files have been moved to appropriate subdirectories
- Import paths have been updated to reflect the new organization
- BUILD files have been updated to reference the new structure
- Documentation has been updated to reflect the new organization
- Test suites are now organized by category and subdirectory

## Future Enhancements

- Add more comprehensive error tests in the `error/` directory
- Implement individual test targets for each test file
- Add more performance benchmarks
- Expand integration test coverage
- Add more mock objects and utilities 