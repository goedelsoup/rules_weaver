"""
Real Weaver Integration Tests

This module provides integration tests that use actual Weaver binaries
downloaded from GitHub releases to ensure the rules work correctly
with the real Weaver tool.
"""

load("//tests/utils:test_utils.bzl", "assert_file_exists")
load("//weaver:defs.bzl", "weaver_schema", "weaver_generate", "weaver_validate_test", "weaver_docs")
load("//weaver:repositories.bzl", "weaver_repository", "weaver_register_toolchains")

def real_weaver_integration_test_suite():
    """Test suite for real Weaver binary integration."""
    
    # Note: Repository is already set up in WORKSPACE file
    # weaver_repository and weaver_register_toolchains are called there
    
    # Test 1: Basic registry validation with real Weaver
    weaver_validate_test(
        name = "real_validation_test",
        registries = [
            "//tests/schemas:sample.yaml",  # Use existing schema as registry
        ],
        weaver_args = ["--quiet"],
        testonly = True,
    )
    
    # Test 2: Code generation with real Weaver (using a simple target)
    weaver_generate(
        name = "real_generated_code",
        registries = [
            "//tests/schemas:sample.yaml",  # Use existing schema as registry
        ],
        target = "test-target",
        args = ["--quiet"],
        testonly = True,
    )
    
    # Test 3: Schema validation with real Weaver
    weaver_validate_test(
        name = "real_validation_test",
        schemas = [":real_test_schemas"],
        policies = ["//tests/schemas:policy.yaml"],
        weaver_args = ["--strict"],
        testonly = True,
    )
    
    # Test 4: Documentation generation with real Weaver
    weaver_docs(
        name = "real_documentation",
        schemas = [":real_test_schemas"],
        format = "html",
        args = ["--verbose"],
        testonly = True,
    )
    
    # Test 5: Multi-format generation
    weaver_generate(
        name = "real_generated_rust",
        srcs = [":real_test_schemas"],
        format = "rust",
        args = ["--verbose"],
        testonly = True,
    )
    
    # Test 6: Complex workflow with dependencies
    weaver_schema(
        name = "real_complex_schemas",
        srcs = [
            "//tests/schemas:sample.yaml",
            "//tests/schemas:another.yaml",
            "//tests/schemas:another_policy.yaml",
        ],
        deps = [":real_test_schemas"],
        testonly = True,
    )
    
    weaver_generate(
        name = "real_complex_generated",
        srcs = [":real_complex_schemas"],
        format = "typescript",
        args = ["--verbose", "--strict"],
        testonly = True,
    )

def real_weaver_performance_test_suite():
    """Performance tests with real Weaver binaries."""
    
    # Large schema set test - create multiple schema targets instead of duplicating
    weaver_schema(
        name = "real_performance_schemas_1",
        srcs = [
            "//tests/schemas:sample.yaml",
            "//tests/schemas:another.yaml",
        ],
        testonly = True,
    )
    
    weaver_schema(
        name = "real_performance_schemas_2",
        srcs = [
            "//tests/schemas:another_policy.yaml",
            "//tests/schemas:policy.yaml",
        ],
        testonly = True,
    )
    
    weaver_generate(
        name = "real_performance_generated",
        srcs = [
            ":real_performance_schemas_1",
            ":real_performance_schemas_2",
        ],
        format = "typescript",
        args = ["--verbose"],
        testonly = True,
    )

def real_weaver_error_test_suite():
    """Error handling tests with real Weaver binaries."""
    
    # Test with invalid schema
    weaver_schema(
        name = "real_invalid_schemas",
        srcs = ["//tests:test1.yaml"],  # This might be invalid
        testonly = True,
    )
    
    # This should fail gracefully
    weaver_validate_test(
        name = "real_invalid_validation",
        schemas = [":real_invalid_schemas"],
        weaver_args = ["--strict"],
        fail_on_error = False,  # Don't fail the build, just report as test failure
        testonly = True,
    )

def real_weaver_platform_test_suite():
    """Platform-specific tests with real Weaver binaries."""
    
    # Test different output formats
    for format_type in ["typescript", "rust", "go", "python"]:
        weaver_generate(
            name = "real_platform_{}_generated".format(format_type),
            srcs = [":real_test_schemas"],
            format = format_type,
            args = ["--verbose"],
            testonly = True,
        )
    
    # Test different documentation formats
    for doc_format in ["html", "markdown", "pdf"]:
        weaver_docs(
            name = "real_platform_{}_docs".format(doc_format),
            schemas = [":real_test_schemas"],
            format = doc_format,
            args = ["--verbose"],
            testonly = True,
        )

def real_weaver_workflow_test_suite():
    """End-to-end workflow tests with real Weaver binaries."""
    
    # Complete workflow: schema -> generate -> validate -> docs
    weaver_schema(
        name = "real_workflow_schemas",
        srcs = [
            "//tests/schemas:sample.yaml",
            "//tests/schemas:another.yaml",
        ],
        testonly = True,
    )
    
    # Generate code
    weaver_generate(
        name = "real_workflow_generated",
        srcs = [":real_workflow_schemas"],
        format = "typescript",
        args = ["--verbose"],
        testonly = True,
    )
    
    # Validate schemas
    weaver_validate_test(
        name = "real_workflow_validation",
        schemas = [":real_workflow_schemas"],
        policies = ["//tests/schemas:policy.yaml"],
        weaver_args = ["--strict"],
        testonly = True,
    )
    
    # Generate documentation
    weaver_docs(
        name = "real_workflow_docs",
        schemas = [":real_workflow_schemas"],
        format = "html",
        args = ["--verbose"],
        testonly = True,
    )
    
    # Test that generated files are accessible
    native.test_suite(
        name = "real_workflow_test_suite",
        tests = [
            ":real_workflow_generated",
            ":real_workflow_validation",
            ":real_workflow_docs",
        ],
        testonly = True,
    ) 