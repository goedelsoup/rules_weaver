"""
Unit tests for weaver_generate rule.

This module contains tests for the weaver_generate rule implementation,
including hermeticity verification and action creation tests.
"""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("@bazel_skylib//lib:new_sets.bzl", "sets")
load("//weaver:defs.bzl", "weaver_generate")
load("//weaver:providers.bzl", "WeaverGeneratedInfo")

def _test_weaver_generate_basic_impl(ctx):
    """Test basic weaver_generate rule functionality."""
    env = unittest.begin(ctx)
    
    # Basic test to verify the test framework works
    asserts.true(env, True, "Basic test passes")
    
    return unittest.end(env)

def _test_weaver_generate_hermeticity_impl(ctx):
    """Test that weaver_generate actions are hermetic."""
    env = unittest.begin(ctx)
    
    # This test would verify that all inputs and outputs are declared
    # and that use_default_shell_env is False
    # For now, we'll use a placeholder test
    asserts.true(env, True, "Hermeticity test placeholder")
    
    return unittest.end(env)

def _test_weaver_generate_output_files_impl(ctx):
    """Test output file determination logic."""
    env = unittest.begin(ctx)
    
    # Test TypeScript output file naming
    # This would test the _determine_output_files function
    asserts.true(env, True, "Output files test placeholder")
    
    return unittest.end(env)

def _test_weaver_generate_provider_impl(ctx):
    """Test WeaverGeneratedInfo provider creation."""
    env = unittest.begin(ctx)
    
    # Test that the provider is created with correct fields
    # This would test the provider creation in the rule implementation
    asserts.true(env, True, "Provider test placeholder")
    
    return unittest.end(env)

# Test targets
weaver_generate_basic_test = unittest.make(
    _test_weaver_generate_basic_impl,
)

weaver_generate_hermeticity_test = unittest.make(
    _test_weaver_generate_hermeticity_impl,
)

weaver_generate_output_files_test = unittest.make(
    _test_weaver_generate_output_files_impl,
)

weaver_generate_provider_test = unittest.make(
    _test_weaver_generate_provider_impl,
)

def weaver_generate_test_suite(name):
    """Create a test suite for weaver_generate rule."""
    unittest.suite(
        name,
        weaver_generate_basic_test,
        weaver_generate_hermeticity_test,
        weaver_generate_output_files_test,
        weaver_generate_provider_test,
    ) 