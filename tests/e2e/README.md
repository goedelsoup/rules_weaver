# End-to-End Integration Tests

This directory contains comprehensive end-to-end integration tests that simulate real user experiences with the rules_weaver project.

## Overview

The end-to-end tests are designed to verify that a completely new user can successfully:
1. Set up a fresh Bazel workspace
2. Integrate rules_weaver into their WORKSPACE
3. Download Weaver binaries from GitHub
4. Generate code from semantic convention registries
5. Validate schemas against policies
6. Generate documentation

## Test Structure

### `new_user_integration_test`
The flagship test that simulates a new user's complete experience with rules_weaver.

**Test Scenario**: "New User GitHub Integration"

**Objective**: Verify end-to-end functionality for a user who has never used rules_weaver before.

## Running the Tests

### Prerequisites
- Bazel installed and configured
- Network access to GitHub (for downloading Weaver binaries)
- Python 3.7+ (for test runner)

### Basic Test Execution
```bash
# Run the main new user integration test
bazel test //tests/e2e:new_user_integration_test

# Run with verbose output
bazel test //tests/e2e:new_user_integration_test --test_output=all

# Run with extended timeout (recommended for CI)
bazel test //tests/e2e:new_user_integration_test --test_timeout=600

# Run the entire e2e test suite
bazel test //tests/e2e:e2e_test_suite
```

### Local Development
```bash
# Run with local debugging
bazel test //tests/e2e:new_user_integration_test --test_output=all --test_verbose_timeout_warnings

# Run with specific test filter
bazel test //tests/e2e:new_user_integration_test --test_filter=test_workspace_setup
```

## Test Components

### Test Runner (`test_runner.py`)
The main test orchestrator that:
- Creates a temporary workspace
- Sets up a fresh Bazel environment
- Executes the complete user workflow
- Validates all generated artifacts
- Handles error scenarios and recovery

### Test Workspace (`test_workspace/`)
A complete example workspace that demonstrates:
- Proper WORKSPACE configuration
- Sample schemas and policies
- Expected output validation
- Error handling scenarios

## Success Criteria

The test is considered successful when:
- ✅ Weaver binary downloads successfully from GitHub
- ✅ Code generation works with real registries
- ✅ Validation passes with real policies
- ✅ Documentation generation produces valid output
- ✅ All generated files are accessible and correct
- ✅ No hardcoded checksums required
- ✅ Works across multiple platforms (Linux, macOS, Windows)

## Error Scenarios Tested

The test validates handling of:
- Invalid checksums (should auto-recover)
- Network failures (should retry)
- Unsupported Weaver versions
- Malformed schemas
- Missing dependencies

## Test Output

### Generated Artifacts
The test generates and validates:
- TypeScript code from semantic conventions
- Go code from semantic conventions
- Python code from semantic conventions
- HTML documentation
- Markdown documentation
- Validation reports

### Validation Checks
- File existence and accessibility
- Content correctness
- Format validation
- Cross-platform compatibility

## Troubleshooting

### Common Issues

**Network Timeout**
```bash
# Increase timeout for slow networks
bazel test //tests/e2e:new_user_integration_test --test_timeout=900
```

**GitHub Rate Limiting**
```bash
# Use GitHub token if available
export GITHUB_TOKEN=your_token_here
bazel test //tests/e2e:new_user_integration_test
```

**Platform-Specific Issues**
```bash
# Run with platform-specific flags
bazel test //tests/e2e:new_user_integration_test --platforms=@io_bazel_rules_go//go/toolchain:linux_amd64
```

### Debug Mode
```bash
# Enable debug logging
bazel test //tests/e2e:new_user_integration_test --test_env=DEBUG=1 --test_output=all
```

## CI Integration

### GitHub Actions
```yaml
- name: Run E2E Tests
  run: |
    bazel test //tests/e2e:new_user_integration_test \
      --test_timeout=600 \
      --test_output=all \
      --verbose_failures
```

### Local CI
```bash
# Run all tests including e2e
bazel test //tests/... --test_timeout=600
```

## Contributing

When adding new e2e tests:
1. Follow the existing test structure
2. Include comprehensive documentation
3. Add appropriate error scenarios
4. Ensure hermetic execution
5. Keep test execution time under 5 minutes
6. Add to the test suite in BUILD.bazel

## Performance Considerations

- Test execution time: Target < 5 minutes
- Memory usage: Monitor for leaks
- Network usage: Minimize downloads
- Platform coverage: Test on Linux, macOS, Windows

## Future Enhancements

- Add more user scenarios
- Include performance benchmarks
- Add stress testing
- Expand platform coverage
- Add more error scenarios 