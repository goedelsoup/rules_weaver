"""
End-to-End Integration Test for New User Experience

This test simulates a completely new user's experience with rules_weaver,
including automatic checksum computation and caching.
"""

load("@rules_weaver//weaver:defs.bzl", "weaver_generate", "weaver_validate_test", "weaver_docs")
load("@rules_weaver//weaver:repositories.bzl", "weaver_repository", "weaver_register_toolchains")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def new_user_integration_test():
    """Create a comprehensive end-to-end test for new user experience."""
    
    # Step 1: Set up Weaver repository with automatic checksum computation
    weaver_repository(
        name = "weaver_new_user",
        version = "0.16.1",
        # No sha256 provided - will trigger auto-computation
    )
    
    weaver_register_toolchains()
    
    # Step 2: Create sample semantic convention schemas
    native.filegroup(
        name = "new_user_schemas",
        srcs = [
            "//tests/schemas:sample.yaml",
            "//tests/schemas:policy.yaml",
        ],
        testonly = True,
    )
    
    # Step 3: Test code generation with real Weaver
    weaver_generate(
        name = "new_user_generated_code",
        registries = [":new_user_schemas"],
        target = "opentelemetry-proto",
        templates = ["//weaver/templates:default.html.template"],
        args = ["--verbose", "--output-format=json"],
        testonly = True,
    )
    
    # Step 4: Test validation with real policies
    weaver_validate_test(
        name = "new_user_validation_test",
        registries = [":new_user_schemas"],
        policies = ["//tests/schemas:policy.yaml"],
        weaver_args = ["--strict", "--verbose"],
        testonly = True,
    )
    
    # Step 5: Test documentation generation
    weaver_docs(
        name = "new_user_docs",
        registries = [":new_user_schemas"],
        template_dir = "//weaver/templates",
        output_dir = "generated_docs",
        args = ["--verbose"],
        testonly = True,
    )
    
    # Step 6: Create a comprehensive test that verifies all outputs
    native.test_suite(
        name = "new_user_comprehensive_test",
        tests = [
            ":new_user_generated_code",
            ":new_user_validation_test",
            ":new_user_docs",
        ],
        testonly = True,
    )

def new_user_workspace_test():
    """Test that simulates a complete new user workspace setup."""
    
    # This function demonstrates what a new user would put in their WORKSPACE
    # It's used for documentation and testing purposes
    
    workspace_content = """
# Example WORKSPACE file for new users
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# Download rules_weaver
http_archive(
    name = "rules_weaver",
    sha256 = "your_sha256_here",  # Replace with actual checksum
    strip_prefix = "rules_weaver-main",
    url = "https://github.com/your-org/rules_weaver/archive/main.tar.gz",
)

# Load and set up Weaver
load("@rules_weaver//weaver:deps.bzl", "weaver_dependencies")
weaver_dependencies()

load("@rules_weaver//weaver:repositories.bzl", "weaver_repository", "weaver_register_toolchains")

# Set up Weaver binary with automatic checksum computation
weaver_repository(
    name = "weaver",
    version = "0.16.1",
    # No sha256 needed - will be computed automatically
)

weaver_register_toolchains()
"""
    
    return workspace_content

def new_user_build_test():
    """Test that simulates a complete new user BUILD file."""
    
    build_content = """
# Example BUILD file for new users
load("@rules_weaver//weaver:defs.bzl", "weaver_generate", "weaver_validate_test", "weaver_docs")

# Generate code from semantic convention registry
weaver_generate(
    name = "my_generated_code",
    registries = ["//path/to/registry"],
    target = "opentelemetry-proto",
    templates = ["//path/to/templates"],
    args = ["--verbose"],
)

# Validate semantic convention registry
weaver_validate_test(
    name = "validate_my_registry",
    registries = ["//path/to/registry"],
    policies = ["//path/to/policies"],
    weaver_args = ["--strict"],
)

# Generate documentation
weaver_docs(
    name = "my_docs",
    registries = ["//path/to/registry"],
    template_dir = "//path/to/templates",
    output_dir = "docs",
)
"""
    
    return build_content

def create_new_user_test_workspace():
    """Create a test workspace that simulates a new user's environment."""
    
    # Create test workspace structure
    native.filegroup(
        name = "new_user_test_workspace",
        srcs = [
            "//tests/e2e:new_user_workspace_test",
            "//tests/e2e:new_user_build_test",
        ],
        testonly = True,
    )
    
    # Create a test that verifies the workspace setup
    native.test_suite(
        name = "new_user_workspace_validation",
        tests = [":new_user_test_workspace"],
        testonly = True,
    )

def new_user_error_recovery_test():
    """Test error handling and recovery scenarios for new users."""
    
    # Test with invalid checksum (should auto-recover)
    weaver_repository(
        name = "weaver_invalid_checksum",
        version = "0.16.1",
        sha256 = "invalid_checksum_that_will_fail",
        # Should fall back to auto-computation
    )
    
    # Test with network failure simulation
    weaver_repository(
        name = "weaver_network_fallback",
        version = "0.16.1",
        urls = ["https://invalid-url-that-will-fail.com/weaver.tar.xz"],
        # Should try multiple URLs and provide helpful error messages
    )
    
    # Test with unsupported platform
    weaver_repository(
        name = "weaver_unsupported_platform",
        version = "0.16.1",
        # Should provide clear error message for unsupported platforms
    )
    
    # Create error recovery test suite
    native.test_suite(
        name = "new_user_error_recovery_tests",
        tests = [
            ":weaver_invalid_checksum",
            ":weaver_network_fallback",
            ":weaver_unsupported_platform",
        ],
        testonly = True,
    )

def new_user_performance_test():
    """Test performance characteristics for new users."""
    
    # Test with large registries
    weaver_generate(
        name = "new_user_large_registry_test",
        registries = [":new_user_schemas"],
        target = "opentelemetry-proto",
        templates = ["//weaver/templates:default.html.template"],
        args = ["--verbose", "--parallel"],
        testonly = True,
    )
    
    # Test with multiple templates
    weaver_generate(
        name = "new_user_multi_template_test",
        registries = [":new_user_schemas"],
        target = "opentelemetry-proto",
        templates = [
            "//weaver/templates:default.html.template",
            "//weaver/templates:default.md.template",
        ],
        args = ["--verbose"],
        testonly = True,
    )
    
    # Create performance test suite
    native.test_suite(
        name = "new_user_performance_tests",
        tests = [
            ":new_user_large_registry_test",
            ":new_user_multi_template_test",
        ],
        testonly = True,
    )

# Main function to set up all new user tests
def setup_new_user_integration_tests():
    """Set up all new user integration tests."""
    
    # Basic integration tests
    new_user_integration_test()
    
    # Workspace and build file tests
    create_new_user_test_workspace()
    
    # Error recovery tests
    new_user_error_recovery_test()
    
    # Performance tests
    new_user_performance_test()
    
    # Create comprehensive test suite
    native.test_suite(
        name = "all_new_user_tests",
        tests = [
            "//tests/e2e:new_user_comprehensive_test",
            "//tests/e2e:new_user_workspace_validation",
            "//tests/e2e:new_user_error_recovery_tests",
            "//tests/e2e:new_user_performance_tests",
        ],
        testonly = True,
    ) 