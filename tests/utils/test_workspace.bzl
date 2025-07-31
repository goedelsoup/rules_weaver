"""
Test workspace configuration for integration testing.

This module provides a test workspace setup that uses mock Weaver binaries
for comprehensive integration testing.
"""

load(":mock_weaver_repository.bzl", "mock_weaver_repository", "mock_weaver_register_toolchains")

def setup_test_workspace():
    """Set up the test workspace with mock Weaver."""
    
    # Set up mock Weaver repository
    mock_weaver_repository(
        name = "mock_weaver",
    )
    
    # Register mock toolchains
    mock_weaver_register_toolchains()
    
    # Return the workspace configuration
    return struct(
        weaver_repository = "@mock_weaver",
        toolchain_target = "//tests:mock_weaver_toolchain",
    ) 