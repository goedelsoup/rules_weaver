# Expected Outputs

This directory contains the expected outputs that the new user integration test should generate and validate.

## Generated Artifacts

The test should successfully generate the following artifacts:

### Code Generation
- **TypeScript**: Generated TypeScript code from semantic conventions
- **Go**: Generated Go code from semantic conventions  
- **Python**: Generated Python code from semantic conventions

### Documentation
- **HTML**: Generated HTML documentation from schemas
- **Markdown**: Generated Markdown documentation from schemas

### Validation
- **Validation Reports**: Schema validation against policies
- **Error Reports**: Graceful error handling for invalid schemas

## Validation Criteria

### File Existence
- All generated files should exist in the expected locations
- File permissions should allow reading and execution where appropriate
- File sizes should be reasonable (not empty, not excessively large)

### Content Validation
- Generated code should be syntactically correct for the target language
- Generated documentation should be well-formed HTML/Markdown
- Validation reports should indicate success or provide clear error messages

### Cross-Platform Compatibility
- Generated artifacts should work on Linux, macOS, and Windows
- No platform-specific dependencies or assumptions
- Consistent behavior across different operating systems

## Success Indicators

The test is considered successful when:

1. ✅ **Weaver Binary Download**: Weaver binaries download successfully from GitHub
2. ✅ **Code Generation**: All target languages generate valid code
3. ✅ **Documentation Generation**: HTML and Markdown docs are created
4. ✅ **Schema Validation**: Validation passes with real policies
5. ✅ **Error Handling**: Invalid schemas fail gracefully with helpful messages
6. ✅ **Artifact Accessibility**: All generated files are accessible and correct
7. ✅ **No Hardcoded Checksums**: Works without requiring manual checksum updates
8. ✅ **Cross-Platform**: Works consistently across different platforms

## Error Scenarios

The test validates proper handling of:

- **Network Failures**: Graceful retry and recovery
- **Invalid Schemas**: Clear error messages and validation failures
- **Missing Dependencies**: Helpful error messages for missing files
- **Unsupported Platforms**: Appropriate error messages for unsupported configurations
- **Rate Limiting**: Proper handling of GitHub API rate limits

## Performance Requirements

- **Execution Time**: Complete test should run under 5 minutes
- **Memory Usage**: Should not exceed reasonable memory limits
- **Network Usage**: Minimize redundant downloads and API calls
- **Disk Usage**: Temporary files should be cleaned up properly

## Debugging

When the test fails, check:

1. **Network Connectivity**: Ensure GitHub access is available
2. **Bazel Configuration**: Verify Bazel is properly configured
3. **Dependencies**: Check that all required dependencies are available
4. **Platform Issues**: Verify platform-specific requirements are met
5. **Permissions**: Ensure proper file and directory permissions

## Local Testing

To run the test locally:

```bash
# Basic test execution
bazel test //tests/e2e:new_user_integration_test

# With verbose output
bazel test //tests/e2e:new_user_integration_test --test_output=all

# With debug mode
DEBUG=1 bazel test //tests/e2e:new_user_integration_test --test_output=all

# With extended timeout
bazel test //tests/e2e:new_user_integration_test --test_timeout=600
``` 