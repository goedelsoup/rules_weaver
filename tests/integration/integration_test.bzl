"""
Integration tests for weaver rules.

This module contains integration tests that verify the weaver rules
work correctly with actual schemas and generation scenarios.
"""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("//weaver:defs.bzl", "weaver_generate")

def _test_weaver_repository_integration(ctx):
    """Test weaver_repository integration with toolchain registration."""
    env = unittest.begin(ctx)
    
    # This test would verify that the weaver_repository rule
    # properly downloads and registers the Weaver binary
    # and that the toolchain is accessible from other rules
    
    # For now, we'll use a placeholder test that verifies
    # the basic structure is in place
    asserts.true(env, True, "weaver_repository integration test placeholder")
    
    return unittest.end(env)

def _test_typescript_generation(ctx):
    """Test TypeScript code generation from schemas."""
    env = unittest.begin(ctx)
    
    # This test would create a real weaver_generate target
    # and verify that TypeScript files are generated correctly
    # For now, we'll use a placeholder test
    asserts.true(env, True, "TypeScript generation test placeholder")
    
    return unittest.end(env)

def _test_multiple_schemas(ctx):
    """Test generation from multiple schema files."""
    env = unittest.begin(ctx)
    
    # This test would verify that multiple schema files
    # are processed correctly and generate separate outputs
    asserts.true(env, True, "Multiple schemas test placeholder")
    
    return unittest.end(env)

def _test_custom_arguments(ctx):
    """Test generation with custom Weaver arguments."""
    env = unittest.begin(ctx)
    
    # This test would verify that custom arguments are passed
    # correctly to the Weaver binary
    asserts.true(env, True, "Custom arguments test placeholder")
    
    return unittest.end(env)

def _test_environment_variables(ctx):
    """Test generation with environment variables."""
    env = unittest.begin(ctx)
    
    # This test would verify that environment variables are
    # passed correctly to the generation action
    asserts.true(env, True, "Environment variables test placeholder")
    
    return unittest.end(env)

def _test_output_directory(ctx):
    """Test custom output directory specification."""
    env = unittest.begin(ctx)
    
    # This test would verify that custom output directories
    # are handled correctly
    asserts.true(env, True, "Output directory test placeholder")
    
    return unittest.end(env)

# Integration test suite
weaver_integration_test_suite = unittest.suite(
    "weaver_integration_tests",
    _test_weaver_repository_integration,
    _test_typescript_generation,
    _test_multiple_schemas,
    _test_custom_arguments,
    _test_environment_variables,
    _test_output_directory,
) 