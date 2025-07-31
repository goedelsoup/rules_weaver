"""
Multi-platform compatibility tests for OpenTelemetry Weaver rules.

This module provides comprehensive tests to ensure Weaver rules work correctly
across all supported platforms including Linux, macOS, and Windows with
x86_64 and ARM64 architectures.
"""

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts", "unittest")
load("@bazel_skylib//lib:paths.bzl", "paths")
load("//weaver:defs.bzl", "weaver_schema", "weaver_generate", "weaver_validate", "weaver_docs")
load("//weaver:platform_constraints.bzl", 
     "get_supported_platforms",
     "get_platform_metadata",
     "is_windows_platform",
     "is_linux_platform",
     "is_darwin_platform",
     "is_arm64_architecture",
     "is_x86_64_architecture",
     "normalize_path",
     "get_platform_specific_binary_name")

def _multi_platform_schema_test_impl(ctx):
    """Test implementation for multi-platform schema compatibility."""
    env = analysistest.begin(ctx)
    
    # Get the target under test
    target = analysistest.target_under_test(env)
    
    # Verify that the schema info is available
    asserts.true(env, hasattr(target, "weaver_schema_info"), 
                 "Target should have weaver_schema_info provider")
    
    # Verify schema files are present
    schema_info = target.weaver_schema_info
    asserts.true(env, len(schema_info.schema_files) > 0, 
                 "Schema files should be present")
    
    # Verify metadata contains platform information
    asserts.true(env, "platform" in schema_info.metadata, 
                 "Metadata should contain platform information")
    
    # Verify all schema files have valid paths
    for schema_file in schema_info.schema_files:
        asserts.true(env, schema_file.path, 
                     "Schema file should have a valid path")
    
    return analysistest.end(env)

def _multi_platform_generate_test_impl(ctx):
    """Test implementation for multi-platform code generation compatibility."""
    env = analysistest.begin(ctx)
    
    # Get the target under test
    target = analysistest.target_under_test(env)
    
    # Verify that the generated info is available
    asserts.true(env, hasattr(target, "weaver_generated_info"), 
                 "Target should have weaver_generated_info provider")
    
    # Verify generated files are present
    generated_info = target.weaver_generated_info
    asserts.true(env, len(generated_info.generated_files) > 0, 
                 "Generated files should be present")
    
    # Verify metadata contains platform information
    asserts.true(env, "platform" in generated_info.metadata, 
                 "Metadata should contain platform information")
    
    # Verify all generated files have valid paths
    for generated_file in generated_info.generated_files:
        asserts.true(env, generated_file.path, 
                     "Generated file should have a valid path")
    
    return analysistest.end(env)

def _multi_platform_validate_test_impl(ctx):
    """Test implementation for multi-platform validation compatibility."""
    env = analysistest.begin(ctx)
    
    # Get the target under test
    target = analysistest.target_under_test(env)
    
    # Verify that the validation info is available
    asserts.true(env, hasattr(target, "weaver_validation_info"), 
                 "Target should have weaver_validation_info provider")
    
    # Verify validation results are present
    validation_info = target.weaver_validation_info
    asserts.true(env, validation_info.validation_results, 
                 "Validation results should be present")
    
    # Verify metadata contains platform information
    asserts.true(env, "platform" in validation_info.metadata, 
                 "Metadata should contain platform information")
    
    return analysistest.end(env)

def _multi_platform_docs_test_impl(ctx):
    """Test implementation for multi-platform documentation compatibility."""
    env = analysistest.begin(ctx)
    
    # Get the target under test
    target = analysistest.target_under_test(env)
    
    # Verify that the docs info is available
    asserts.true(env, hasattr(target, "weaver_docs_info"), 
                 "Target should have weaver_docs_info provider")
    
    # Verify documentation files are present
    docs_info = target.weaver_docs_info
    asserts.true(env, len(docs_info.documentation_files) > 0, 
                 "Documentation files should be present")
    
    # Verify metadata contains platform information
    asserts.true(env, "platform" in docs_info.metadata, 
                 "Metadata should contain platform information")
    
    # Verify all documentation files have valid paths
    for doc_file in docs_info.documentation_files:
        asserts.true(env, doc_file.path, 
                     "Documentation file should have a valid path")
    
    return analysistest.end(env)

def _platform_constraints_test_impl(ctx):
    """Test implementation for platform constraints functionality."""
    env = analysistest.begin(ctx)
    
    # Test platform detection functions
    supported_platforms = get_supported_platforms()
    asserts.true(env, len(supported_platforms) > 0, 
                 "Should have supported platforms")
    
    # Test platform-specific functions
    for platform in supported_platforms:
        # Test platform type detection
        if is_windows_platform(platform):
            asserts.true(env, platform.startswith("windows-"), 
                         "Windows platform should start with 'windows-'")
        elif is_linux_platform(platform):
            asserts.true(env, platform.startswith("linux-"), 
                         "Linux platform should start with 'linux-'")
        elif is_darwin_platform(platform):
            asserts.true(env, platform.startswith("darwin-"), 
                         "Darwin platform should start with 'darwin-'")
        
        # Test architecture detection
        if is_arm64_architecture(platform):
            asserts.true(env, platform.endswith("-aarch64"), 
                         "ARM64 platform should end with '-aarch64'")
        elif is_x86_64_architecture(platform):
            asserts.true(env, platform.endswith("-x86_64"), 
                         "x86_64 platform should end with '-x86_64'")
        
        # Test platform metadata
        metadata = get_platform_metadata(platform)
        asserts.true(env, metadata["platform"] == platform, 
                     "Platform metadata should match platform")
        asserts.true(env, "os_name" in metadata, 
                     "Metadata should contain OS name")
        asserts.true(env, "architecture" in metadata, 
                     "Metadata should contain architecture")
        
        # Test path normalization
        test_path = "path/to/file"
        normalized = normalize_path(test_path, platform)
        if is_windows_platform(platform):
            asserts.true(env, "\\" in normalized, 
                         "Windows paths should use backslashes")
        else:
            asserts.true(env, "/" in normalized, 
                         "Unix paths should use forward slashes")
        
        # Test binary name generation
        binary_name = get_platform_specific_binary_name("weaver", platform)
        if is_windows_platform(platform):
            asserts.true(env, binary_name.endswith(".exe"), 
                         "Windows binary should have .exe extension")
        else:
            asserts.true(env, not binary_name.endswith(".exe"), 
                         "Unix binary should not have .exe extension")
    
    return analysistest.end(env)

def _cross_platform_compatibility_test_impl(ctx):
    """Test implementation for cross-platform compatibility."""
    env = analysistest.begin(ctx)
    
    # Test that all platforms support the same basic functionality
    supported_platforms = get_supported_platforms()
    
    for platform in supported_platforms:
        metadata = get_platform_metadata(platform)
        
        # Verify all platforms have required metadata fields
        required_fields = ["platform", "os_name", "architecture", "os_constraint", "cpu_constraint"]
        for field in required_fields:
            asserts.true(env, field in metadata, 
                         "Platform {} should have {} field".format(platform, field))
        
        # Verify execution requirements are available
        exec_reqs = metadata["execution_requirements"]
        required_exec_fields = ["no-sandbox", "supports-workers", "cpu-cores", "memory"]
        for field in required_exec_fields:
            asserts.true(env, field in exec_reqs, 
                         "Platform {} should have {} execution requirement".format(platform, field))
    
    return analysistest.end(env)

# Test rules
multi_platform_schema_test = analysistest.make(_multi_platform_schema_test_impl)
multi_platform_generate_test = analysistest.make(_multi_platform_generate_test_impl)
multi_platform_validate_test = analysistest.make(_multi_platform_validate_test_impl)
multi_platform_docs_test = analysistest.make(_multi_platform_docs_test_impl)
platform_constraints_test = analysistest.make(_platform_constraints_test_impl)
cross_platform_compatibility_test = analysistest.make(_cross_platform_compatibility_test_impl)

def multi_platform_test_suite(name):
    """Create a test suite for multi-platform compatibility."""
    
    # Create test targets for each platform
    test_targets = []
    
    for platform in get_supported_platforms():
        platform_name = platform.replace("-", "_")
        
        # Schema test
        schema_test_name = "{}_schema_test".format(platform_name)
        weaver_schema(
            name = "{}_schema".format(platform_name),
            srcs = ["//tests/schemas:sample.yaml"],
            tags = ["manual"],  # Don't run automatically
        )
        multi_platform_schema_test(
            name = schema_test_name,
            target_under_test = ":{}_schema".format(platform_name),
        )
        test_targets.append(schema_test_name)
        
        # Generate test
        generate_test_name = "{}_generate_test".format(platform_name)
        weaver_generate(
            name = "{}_generate".format(platform_name),
            schemas = ["//tests/schemas:sample.yaml"],
            format = "go",
            tags = ["manual"],  # Don't run automatically
        )
        multi_platform_generate_test(
            name = generate_test_name,
            target_under_test = ":{}_generate".format(platform_name),
        )
        test_targets.append(generate_test_name)
        
        # Validate test
        validate_test_name = "{}_validate_test".format(platform_name)
        weaver_validate(
            name = "{}_validate".format(platform_name),
            schemas = ["//tests/schemas:sample.yaml"],
            policies = ["//tests/schemas:policy.yaml"],
            tags = ["manual"],  # Don't run automatically
        )
        multi_platform_validate_test(
            name = validate_test_name,
            target_under_test = ":{}_validate".format(platform_name),
        )
        test_targets.append(validate_test_name)
        
        # Docs test
        docs_test_name = "{}_docs_test".format(platform_name)
        weaver_docs(
            name = "{}_docs".format(platform_name),
            schemas = ["//tests/schemas:sample.yaml"],
            tags = ["manual"],  # Don't run automatically
        )
        multi_platform_docs_test(
            name = docs_test_name,
            target_under_test = ":{}_docs".format(platform_name),
        )
        test_targets.append(docs_test_name)
    
    # Platform constraints test
    platform_constraints_test(
        name = "platform_constraints_test",
    )
    test_targets.append("platform_constraints_test")
    
    # Cross-platform compatibility test
    cross_platform_compatibility_test(
        name = "cross_platform_compatibility_test",
    )
    test_targets.append("cross_platform_compatibility_test")
    
    # Create the test suite
    native.test_suite(
        name = name,
        tests = test_targets,
    ) 