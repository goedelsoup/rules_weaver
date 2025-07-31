"""
Mock Weaver repository for testing purposes.

This module provides a mock Weaver repository that uses a local mock binary
instead of downloading a real Weaver binary from the internet.
"""

def _mock_weaver_repository_impl(repository_ctx):
    """Implementation of mock weaver repository."""
    
    # Get the mock binary path
    mock_binary_path = repository_ctx.path(Label("//tests:mock_weaver.py"))
    
    # Create BUILD file for the mock weaver
    repository_ctx.file("BUILD", """
package(default_visibility = ["//visibility:public"])

filegroup(
    name = "weaver_binary",
    srcs = ["mock_weaver.py"],
    data = ["mock_weaver.py"],
)

exports_files(["mock_weaver.py"])
""")
    
    # Copy the mock binary to the repository
    repository_ctx.symlink(mock_binary_path, "mock_weaver.py")

def mock_weaver_repository(name):
    """Create a mock Weaver repository for testing.
    
    Args:
        name: Name of the repository
    """
    repository_ctx = repository_ctx(
        name = name,
        implementation = _mock_weaver_repository_impl,
        local = True,
    )

def mock_weaver_toolchain_impl(ctx):
    """Implementation of mock weaver toolchain."""
    return [platform_common.ToolchainInfo(
        weaver_binary = ctx.file.weaver_binary,
        version = "mock-0.1.0",
        platform = "mock",
    )]

def mock_weaver_toolchain(name, weaver_binary):
    """Create a mock Weaver toolchain for testing.
    
    Args:
        name: Name of the toolchain
        weaver_binary: Label to the mock weaver binary
    """
    native.toolchain(
        name = name,
        toolchain = weaver_binary,
        toolchain_type = "@rules_weaver//weaver:toolchain_type",
    )

def mock_weaver_register_toolchains():
    """Register mock Weaver toolchains for testing."""
    native.register_toolchains("//tests:mock_weaver_toolchain") 