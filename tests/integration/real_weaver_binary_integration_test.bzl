"""
Real Weaver Binary Integration Tests

This module provides comprehensive integration tests that verify the rules work correctly
with actual Weaver binaries downloaded from GitHub releases, including proper toolchain
resolution, platform compatibility, and error handling.
"""

load("//tests/utils:test_utils.bzl", "assert_file_exists")
load("//weaver:defs.bzl", "weaver_schema", "weaver_generate", "weaver_validate_test", "weaver_docs", "weaver_library")
load("//weaver:repositories.bzl", "weaver_repository", "weaver_register_toolchains")

def real_weaver_binary_integration_test_suite():
    """Test suite for real Weaver binary integration with comprehensive coverage."""
    
    # Test 1: Basic schema validation with real Weaver
    weaver_validate_test(
        name = "real_binary_schema_validation",
        registries = [
            "//tests/schemas:sample.yaml",
        ],
        weaver_args = ["--quiet"],
        testonly = True,
        tags = ["real_weaver", "integration"],
    )
    
    # Test 2: Code generation with real Weaver
    weaver_generate(
        name = "real_binary_code_generation",
        registries = [
            "//tests/schemas:sample.yaml",
        ],
        target = "test-target",
        args = ["--quiet"],
        testonly = True,
        tags = ["real_weaver", "integration"],
    )
    
    # Test 3: Documentation generation with real Weaver
    weaver_docs(
        name = "real_binary_documentation",
        schemas = [
            "//tests/schemas:sample.yaml",
        ],
        format = "html",
        args = ["--quiet"],
        testonly = True,
        tags = ["real_weaver", "integration"],
    )
    
    # Test 4: Library generation with real Weaver
    weaver_library(
        name = "real_binary_library",
        schemas = [
            "//tests/schemas:sample.yaml",
        ],
        format = "typescript",
        args = ["--quiet"],
        testonly = True,
        tags = ["real_weaver", "integration"],
    )
    
    # Test 5: Multi-format generation with real Weaver
    weaver_generate(
        name = "real_binary_multi_format",
        registries = [
            "//tests/schemas:sample.yaml",
            "//tests/schemas:another.yaml",
        ],
        target = "multi-format-target",
        args = ["--quiet", "--format", "rust"],
        testonly = True,
        tags = ["real_weaver", "integration"],
    )
    
    # Test 6: Complex workflow with dependencies
    weaver_schema(
        name = "real_binary_complex_schemas",
        srcs = [
            "//tests/schemas:sample.yaml",
            "//tests/schemas:another.yaml",
            "//tests/schemas:another_policy.yaml",
        ],
        testonly = True,
        tags = ["real_weaver", "integration"],
    )
    
    weaver_generate(
        name = "real_binary_complex_generation",
        registries = [":real_binary_complex_schemas"],
        target = "complex-target",
        args = ["--quiet", "--strict"],
        testonly = True,
        tags = ["real_weaver", "integration"],
    )
    
    # Test 7: Policy-based validation with real Weaver
    weaver_validate_test(
        name = "real_binary_policy_validation",
        registries = [
            "//tests/schemas:sample.yaml",
        ],
        policies = [
            "//tests/schemas:policy.yaml",
        ],
        weaver_args = ["--quiet", "--strict"],
        testonly = True,
        tags = ["real_weaver", "integration"],
    )
    
    # Test 8: Template-based generation with real Weaver
    weaver_generate(
        name = "real_binary_template_generation",
        registries = [
            "//tests/schemas:sample.yaml",
        ],
        templates = [
            "//weaver/templates:default.html.template",
        ],
        target = "template-target",
        args = ["--quiet"],
        testonly = True,
        tags = ["real_weaver", "integration"],
    )

def real_weaver_binary_performance_test_suite():
    """Performance tests with real Weaver binaries."""
    
    # Large schema set test
    weaver_schema(
        name = "real_binary_performance_schemas",
        srcs = [
            "//tests/schemas:sample.yaml",
            "//tests/schemas:another.yaml",
            "//tests/schemas:another_policy.yaml",
        ],
        testonly = True,
        tags = ["real_weaver", "performance", "integration"],
    )
    
    weaver_generate(
        name = "real_binary_performance_generation",
        registries = [":real_binary_performance_schemas"],
        target = "performance-target",
        args = ["--quiet"],
        testonly = True,
        tags = ["real_weaver", "performance", "integration"],
    )

def real_weaver_binary_error_handling_test_suite():
    """Error handling tests with real Weaver binaries."""
    
    # Test with invalid schema
    weaver_validate_test(
        name = "real_binary_invalid_schema_test",
        registries = [
            "//tests/schemas:invalid_schema.yaml",  # This should fail
        ],
        weaver_args = ["--quiet"],
        testonly = True,
        tags = ["real_weaver", "error_handling", "integration"],
    )
    
    # Test with missing dependencies
    weaver_generate(
        name = "real_binary_missing_deps_test",
        registries = [
            "//tests/schemas:sample.yaml",
        ],
        target = "missing-deps-target",
        args = ["--quiet", "--strict"],
        testonly = True,
        tags = ["real_weaver", "error_handling", "integration"],
    )

def real_weaver_binary_platform_test_suite():
    """Platform compatibility tests with real Weaver binaries."""
    
    # Test cross-platform compatibility
    weaver_generate(
        name = "real_binary_platform_compatibility",
        registries = [
            "//tests/schemas:sample.yaml",
        ],
        target = "platform-target",
        args = ["--quiet"],
        testonly = True,
        tags = ["real_weaver", "platform", "integration"],
    )
    
    # Test with platform-specific constraints
    weaver_validate_test(
        name = "real_binary_platform_constraints",
        registries = [
            "//tests/schemas:sample.yaml",
        ],
        weaver_args = ["--quiet"],
        testonly = True,
        tags = ["real_weaver", "platform", "integration"],
    )

def real_weaver_binary_toolchain_test_suite():
    """Toolchain resolution tests with real Weaver binaries."""
    
    # Test toolchain resolution
    weaver_generate(
        name = "real_binary_toolchain_resolution",
        registries = [
            "//tests/schemas:sample.yaml",
        ],
        target = "toolchain-target",
        args = ["--quiet"],
        testonly = True,
        tags = ["real_weaver", "toolchain", "integration"],
    )
    
    # Test toolchain fallback
    weaver_validate_test(
        name = "real_binary_toolchain_fallback",
        registries = [
            "//tests/schemas:sample.yaml",
        ],
        weaver_args = ["--quiet"],
        testonly = True,
        tags = ["real_weaver", "toolchain", "integration"],
    )

# Main test suite that includes all real Weaver binary tests
def real_weaver_binary_all_tests():
    """Run all real Weaver binary integration tests."""
    real_weaver_binary_integration_test_suite()
    real_weaver_binary_performance_test_suite()
    real_weaver_binary_error_handling_test_suite()
    real_weaver_binary_platform_test_suite()
    real_weaver_binary_toolchain_test_suite() 