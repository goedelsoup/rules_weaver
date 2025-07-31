# End-to-End Integration Test Prompt

## Objective

Create a comprehensive end-to-end integration test that simulates a completely new user's experience with the rules_weaver project. This test should verify that a user can successfully integrate rules_weaver into a fresh repository, download Weaver binaries from GitHub with automatic checksum computation, and perform all major operations.

## Test Scenario: "New User GitHub Integration"

### Success Criteria

The test should verify that a new user can successfully:

1. ✅ **Clone a fresh repository** and set up a new Bazel workspace
2. ✅ **Add rules_weaver to WORKSPACE** without manual checksum management
3. ✅ **Download Weaver binaries from GitHub** with automatic checksum computation
4. ✅ **Generate code from semantic convention registries** using real Weaver
5. ✅ **Validate schemas against policies** with actual OpenTelemetry policies
6. ✅ **Generate documentation** from semantic convention registries
7. ✅ **Handle errors gracefully** with helpful recovery mechanisms
8. ✅ **Work across multiple platforms** (Linux, macOS, Windows)

## Test Implementation Requirements

### File Structure

```
tests/e2e/
├── new_user_integration_test.bzl      # Main test implementation
├── test_workspace/
│   ├── WORKSPACE                      # Example WORKSPACE file
│   ├── BUILD.bazel                    # Example BUILD file
│   ├── schemas/
│   │   ├── sample.yaml                # Sample semantic convention
│   │   └── policies.yaml              # Sample validation policies
│   └── expected_outputs/              # Expected generated files
├── test_runner.py                     # Python test runner
├── test_runner.sh                     # Shell test runner
└── README.md                          # Test documentation
```

### Test Phases

#### Phase 1: Fresh Repository Setup
- Create a temporary workspace directory
- Initialize a new Bazel workspace
- Simulate a user who has never used rules_weaver before
- Verify clean environment

#### Phase 2: WORKSPACE Integration
- Add rules_weaver dependency via http_archive
- Configure weaver_repository with latest version (no checksum)
- Register toolchains
- Verify successful setup

#### Phase 3: Real GitHub Integration
- Download actual Weaver binaries from GitHub releases
- Verify automatic checksum computation and caching
- Use real semantic convention registries (e.g., opentelemetry-specification)
- Test with actual Weaver templates and policies

#### Phase 4: End-to-End Workflow
- Create sample semantic convention schemas
- Generate TypeScript/Go/Python code
- Validate schemas against OpenTelemetry policies
- Generate documentation
- Verify generated artifacts are correct and accessible

#### Phase 5: Error Handling & Recovery
- Test with invalid checksums and verify automatic recovery
- Test with network failures and retry logic
- Test with unsupported platforms
- Verify helpful error messages for new users

#### Phase 6: Performance & Scalability
- Test with large registries
- Test with multiple templates
- Test parallel processing capabilities
- Verify reasonable performance characteristics

## Test Commands

The test should support these scenarios:

```bash
# Basic end-to-end test
bazel test //tests/e2e:new_user_comprehensive_test

# Verbose output for debugging
bazel test //tests/e2e:new_user_comprehensive_test --test_output=all

# Extended timeout for network operations
bazel test //tests/e2e:new_user_comprehensive_test --test_timeout=600

# Platform-specific testing
bazel test //tests/e2e:new_user_comprehensive_test --platforms=@io_bazel_rules_go//go/toolchain:linux_amd64

# Remote execution testing
bazel test //tests/e2e:new_user_comprehensive_test --remote_executor=grpc://localhost:8980
```

## Key Features

### Hermetic Environment
- Should work in any CI environment (GitHub Actions, GitLab CI, etc.)
- No external dependencies beyond what's declared
- Reproducible across different environments

### Fast Execution
- Complete test should run under 5 minutes
- Parallel execution where possible
- Efficient caching of downloaded artifacts

### Reliable Operation
- Handle network issues gracefully
- Retry failed operations with exponential backoff
- Clear error messages and debugging information

### Comprehensive Coverage
- Test all major functionality paths
- Verify error conditions and recovery
- Test multiple platforms and configurations

## Success Criteria

### Functional Requirements
- ✅ Weaver binary downloads successfully from GitHub
- ✅ Code generation works with real registries
- ✅ Validation passes with real policies
- ✅ Documentation generation produces valid output
- ✅ All generated files are accessible and correct
- ✅ No hardcoded checksums required
- ✅ Works across multiple platforms (Linux, macOS, Windows)

### Error Scenarios
- ✅ Invalid checksums (should auto-recover)
- ✅ Network failures (should retry)
- ✅ Unsupported Weaver versions
- ✅ Malformed schemas
- ✅ Missing dependencies

### Performance Requirements
- ✅ Downloads complete within 2 minutes
- ✅ Code generation completes within 1 minute
- ✅ Validation completes within 30 seconds
- ✅ Documentation generation completes within 1 minute
- ✅ Total test time under 5 minutes

## Documentation Requirements

### Test Documentation
- Step-by-step instructions for reproducing the test locally
- Expected outputs and success criteria
- Troubleshooting guide for common issues
- Platform-specific considerations

### User Documentation
- Example WORKSPACE configuration
- Example BUILD file configuration
- Common usage patterns
- Best practices for new users

### Developer Documentation
- Test architecture and design decisions
- Extension points for additional tests
- Integration with CI/CD systems
- Performance optimization strategies

## Integration with CI/CD

### GitHub Actions
```yaml
- name: Run End-to-End Tests
  run: |
    bazel test //tests/e2e:new_user_comprehensive_test \
      --test_output=all \
      --test_timeout=600 \
      --verbose_failures
```

### GitLab CI
```yaml
e2e_test:
  script:
    - bazel test //tests/e2e:new_user_comprehensive_test
  timeout: 10 minutes
```

### Local Development
```bash
# Run tests locally
bazel test //tests/e2e:new_user_comprehensive_test

# Debug test failures
bazel test //tests/e2e:new_user_comprehensive_test --test_output=all --verbose_failures

# Run specific test phases
bazel test //tests/e2e:new_user_workspace_test
bazel test //tests/e2e:new_user_generation_test
bazel test //tests/e2e:new_user_validation_test
```

## Monitoring and Metrics

### Test Metrics
- Execution time for each phase
- Success/failure rates
- Network download times
- Checksum computation times
- Error frequency and types

### Performance Benchmarks
- Baseline performance on reference hardware
- Performance regression detection
- Platform-specific performance characteristics
- Scalability with larger registries

## Future Enhancements

### Planned Improvements
1. **Multi-Platform Testing**: Automated testing on all supported platforms
2. **Performance Regression**: Automated detection of performance regressions
3. **Security Testing**: Verification of checksum integrity and security
4. **Load Testing**: Testing with very large registries and complex schemas
5. **Integration Testing**: Testing with real-world OpenTelemetry projects

### Extension Points
1. **Custom Templates**: Testing with user-provided templates
2. **Custom Policies**: Testing with user-provided validation policies
3. **Custom Registries**: Testing with user-provided semantic convention registries
4. **Plugin Integration**: Testing with Weaver plugins and extensions

## Conclusion

This end-to-end integration test serves as the gold standard for verifying that rules_weaver works correctly for new users. It should be comprehensive, reliable, and fast, providing confidence that the system works as expected in real-world scenarios.

The test should be:
- **Comprehensive**: Cover all major functionality
- **Reliable**: Handle errors gracefully
- **Fast**: Complete within reasonable time limits
- **Maintainable**: Easy to understand and modify
- **Documented**: Well-documented for users and developers

This test will serve as both a validation mechanism and documentation of the complete user experience, ensuring that new users can successfully integrate rules_weaver into their projects. 