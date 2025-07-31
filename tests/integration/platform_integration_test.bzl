"""
Platform-specific integration tests for OpenTelemetry Weaver rules.

This module provides integration tests that verify the complete workflow
works correctly on each supported platform and architecture.
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
     "is_x86_64_architecture")

def _linux_x86_64_integration_test_impl(ctx):
    """Integration test for Linux x86_64 platform."""
    env = analysistest.begin(ctx)
    
    # Test Linux x86_64 specific functionality
    target = analysistest.target_under_test(env)
    
    # Verify Linux x86_64 specific metadata
    if hasattr(target, "weaver_schema_info"):
        metadata = target.weaver_schema_info.metadata
        asserts.true(env, metadata.get("platform") == "linux-x86_64" or "linux-x86_64" in str(metadata), 
                     "Should have Linux x86_64 platform information")
    
    # Verify Unix-style paths
    if hasattr(target, "weaver_generated_info"):
        for file in target.weaver_generated_info.generated_files:
            path = file.path
            asserts.true(env, "/" in path and "\\" not in path, 
                         "Linux paths should use forward slashes")
    
    return analysistest.end(env)

def _linux_aarch64_integration_test_impl(ctx):
    """Integration test for Linux ARM64 platform."""
    env = analysistest.begin(ctx)
    
    # Test Linux ARM64 specific functionality
    target = analysistest.target_under_test(env)
    
    # Verify Linux ARM64 specific metadata
    if hasattr(target, "weaver_schema_info"):
        metadata = target.weaver_schema_info.metadata
        asserts.true(env, metadata.get("platform") == "linux-aarch64" or "linux-aarch64" in str(metadata), 
                     "Should have Linux ARM64 platform information")
    
    # Verify ARM64 architecture support
    if hasattr(target, "weaver_generated_info"):
        metadata = target.weaver_generated_info.metadata
        asserts.true(env, "aarch64" in str(metadata) or "arm64" in str(metadata), 
                     "Should have ARM64 architecture information")
    
    return analysistest.end(env)

def _darwin_x86_64_integration_test_impl(ctx):
    """Integration test for macOS x86_64 platform."""
    env = analysistest.begin(ctx)
    
    # Test macOS x86_64 specific functionality
    target = analysistest.target_under_test(env)
    
    # Verify macOS x86_64 specific metadata
    if hasattr(target, "weaver_schema_info"):
        metadata = target.weaver_schema_info.metadata
        asserts.true(env, metadata.get("platform") == "darwin-x86_64" or "darwin-x86_64" in str(metadata), 
                     "Should have macOS x86_64 platform information")
    
    # Verify Unix-style paths
    if hasattr(target, "weaver_generated_info"):
        for file in target.weaver_generated_info.generated_files:
            path = file.path
            asserts.true(env, "/" in path and "\\" not in path, 
                         "macOS paths should use forward slashes")
    
    return analysistest.end(env)

def _darwin_aarch64_integration_test_impl(ctx):
    """Integration test for macOS ARM64 platform."""
    env = analysistest.begin(ctx)
    
    # Test macOS ARM64 specific functionality
    target = analysistest.target_under_test(env)
    
    # Verify macOS ARM64 specific metadata
    if hasattr(target, "weaver_schema_info"):
        metadata = target.weaver_schema_info.metadata
        asserts.true(env, metadata.get("platform") == "darwin-aarch64" or "darwin-aarch64" in str(metadata), 
                     "Should have macOS ARM64 platform information")
    
    # Verify ARM64 architecture support
    if hasattr(target, "weaver_generated_info"):
        metadata = target.weaver_generated_info.metadata
        asserts.true(env, "aarch64" in str(metadata) or "arm64" in str(metadata), 
                     "Should have ARM64 architecture information")
    
    return analysistest.end(env)

def _windows_x86_64_integration_test_impl(ctx):
    """Integration test for Windows x86_64 platform."""
    env = analysistest.begin(ctx)
    
    # Test Windows x86_64 specific functionality
    target = analysistest.target_under_test(env)
    
    # Verify Windows x86_64 specific metadata
    if hasattr(target, "weaver_schema_info"):
        metadata = target.weaver_schema_info.metadata
        asserts.true(env, metadata.get("platform") == "windows-x86_64" or "windows-x86_64" in str(metadata), 
                     "Should have Windows x86_64 platform information")
    
    # Verify Windows-specific execution requirements
    if hasattr(target, "weaver_generated_info"):
        metadata = target.weaver_generated_info.metadata
        asserts.true(env, "windows" in str(metadata), 
                     "Should have Windows-specific information")
    
    return analysistest.end(env)

def _windows_aarch64_integration_test_impl(ctx):
    """Integration test for Windows ARM64 platform."""
    env = analysistest.begin(ctx)
    
    # Test Windows ARM64 specific functionality
    target = analysistest.target_under_test(env)
    
    # Verify Windows ARM64 specific metadata
    if hasattr(target, "weaver_schema_info"):
        metadata = target.weaver_schema_info.metadata
        asserts.true(env, metadata.get("platform") == "windows-aarch64" or "windows-aarch64" in str(metadata), 
                     "Should have Windows ARM64 platform information")
    
    # Verify ARM64 architecture support
    if hasattr(target, "weaver_generated_info"):
        metadata = target.weaver_generated_info.metadata
        asserts.true(env, "aarch64" in str(metadata) or "arm64" in str(metadata), 
                     "Should have ARM64 architecture information")
    
    # Verify Windows-specific execution requirements
    if hasattr(target, "weaver_generated_info"):
        metadata = target.weaver_generated_info.metadata
        asserts.true(env, "windows" in str(metadata), 
                     "Should have Windows-specific information")
    
    return analysistest.end(env)

def _cross_platform_workflow_test_impl(ctx):
    """Test complete workflow across all platforms."""
    env = analysistest.begin(ctx)
    
    # Test that the complete workflow works on all platforms
    supported_platforms = get_supported_platforms()
    
    for platform in supported_platforms:
        metadata = get_platform_metadata(platform)
        
        # Verify platform has all required components
        asserts.true(env, metadata["remote_execution_supported"], 
                     "Platform {} should support remote execution".format(platform))
        
        # Verify execution requirements are complete
        exec_reqs = metadata["execution_requirements"]
        required_reqs = ["no-sandbox", "supports-workers", "cpu-cores", "memory"]
        for req in required_reqs:
            asserts.true(env, req in exec_reqs, 
                         "Platform {} should have {} execution requirement".format(platform, req))
        
        # Verify environment variables are set
        env_vars = metadata["env_vars"]
        asserts.true(env, "PATH" in env_vars, 
                     "Platform {} should have PATH environment variable".format(platform))
    
    return analysistest.end(env)

# Test rules
linux_x86_64_integration_test = analysistest.make(_linux_x86_64_integration_test_impl)
linux_aarch64_integration_test = analysistest.make(_linux_aarch64_integration_test_impl)
darwin_x86_64_integration_test = analysistest.make(_darwin_x86_64_integration_test_impl)
darwin_aarch64_integration_test = analysistest.make(_darwin_aarch64_integration_test_impl)
windows_x86_64_integration_test = analysistest.make(_windows_x86_64_integration_test_impl)
windows_aarch64_integration_test = analysistest.make(_windows_aarch64_integration_test_impl)
cross_platform_workflow_test = analysistest.make(_cross_platform_workflow_test_impl)

def platform_integration_test_suite(name):
    """Create a test suite for platform-specific integration tests."""
    
    test_targets = []
    
    # Create integration tests for each platform
    platform_tests = {
        "linux-x86_64": linux_x86_64_integration_test,
        "linux-aarch64": linux_aarch64_integration_test,
        "darwin-x86_64": darwin_x86_64_integration_test,
        "darwin-aarch64": darwin_aarch64_integration_test,
        "windows-x86_64": windows_x86_64_integration_test,
        "windows-aarch64": windows_aarch64_integration_test,
    }
    
    for platform, test_rule in platform_tests.items():
        platform_name = platform.replace("-", "_")
        
        # Create test target for each platform
        test_target_name = "{}_integration_test".format(platform_name)
        
        # Create a simple schema target for testing
        weaver_schema(
            name = "{}_test_schema".format(platform_name),
            srcs = ["//tests/schemas:sample.yaml"],
            tags = ["manual"],  # Don't run automatically
        )
        
        test_rule(
            name = test_target_name,
            target_under_test = ":{}_test_schema".format(platform_name),
        )
        test_targets.append(test_target_name)
    
    # Cross-platform workflow test
    cross_platform_workflow_test(
        name = "cross_platform_workflow_test",
    )
    test_targets.append("cross_platform_workflow_test")
    
    # Create the test suite
    native.test_suite(
        name = name,
        tests = test_targets,
    ) 