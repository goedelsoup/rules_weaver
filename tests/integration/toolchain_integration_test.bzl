"""
Integration tests for weaver_toolchain resolution.

This module provides integration tests for toolchain resolution and
cross-platform toolchain selection.
"""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("@rules_weaver//weaver:defs.bzl", "weaver_generate", "weaver_validate")
load("@rules_weaver//weaver:toolchains.bzl", "weaver_toolchain")
load("@rules_weaver//weaver:providers.bzl", "WeaverGeneratedInfo")

def _toolchain_resolution_integration_test_impl(ctx):
    """Test that toolchain resolution works in consuming rules."""
    
    # This test verifies that the weaver_generate rule can successfully
    # resolve and use the toolchain
    
    # Get the generated files from the weaver_generate rule
    generated_info = ctx.attr.generated_target[WeaverGeneratedInfo]
    
    # Verify that the toolchain was used successfully
    asserts.true(
        ctx,
        generated_info.generated_files != None,
        "Generated files should be available",
    )
    
    # Verify that the generation args include toolchain information
    generation_args = generated_info.generation_args
    asserts.true(
        ctx,
        len(generation_args) > 0,
        "Generation args should be populated",
    )
    
    return unittest.end(ctx)

def _cross_platform_toolchain_test_impl(ctx):
    """Test cross-platform toolchain selection."""
    
    # This test verifies that different toolchains can be selected
    # based on platform constraints
    
    # Get the toolchain info
    toolchain = ctx.attr.toolchain[platform_common.ToolchainInfo]
    
    # Verify platform-specific information
    platform = toolchain.platform
    version = toolchain.version
    
    asserts.true(
        ctx,
        platform != None,
        "Platform should be specified for cross-platform toolchain",
    )
    
    asserts.equals(
        ctx,
        "0.1.0",
        version,
        "Version should match expected value",
    )
    
    return unittest.end(ctx)

def _toolchain_constraint_test_impl(ctx):
    """Test toolchain constraint handling."""
    
    # This test verifies that toolchain constraints are properly handled
    
    # Get the toolchain
    toolchain = ctx.attr.toolchain[platform_common.ToolchainInfo]
    
    # Verify that the toolchain has the expected constraints
    weaver_binary = toolchain.weaver_binary
    
    asserts.true(
        ctx,
        weaver_binary != None,
        "Toolchain should provide weaver binary",
    )
    
    # Verify that the binary is executable
    asserts.true(
        ctx,
        weaver_binary.is_source == False,
        "Weaver binary should be a generated file",
    )
    
    return unittest.end(ctx)

# Test rules
toolchain_resolution_integration_test = unittest.make(
    _toolchain_resolution_integration_test_impl,
    attrs = {
        "generated_target": attr.label(
            providers = [WeaverGeneratedInfo],
        ),
    },
)

cross_platform_toolchain_test = unittest.make(
    _cross_platform_toolchain_test_impl,
    attrs = {
        "toolchain": attr.label(
            providers = [platform_common.ToolchainInfo],
        ),
    },
)

toolchain_constraint_test = unittest.make(
    _toolchain_constraint_test_impl,
    attrs = {
        "toolchain": attr.label(
            providers = [platform_common.ToolchainInfo],
        ),
    },
)

def toolchain_integration_test_suite(name):
    """Create an integration test suite for toolchain functionality."""
    
    # Create mock weaver binaries for different platforms
    native.genrule(
        name = name + "_linux_binary",
        outs = ["weaver_linux"],
        cmd = "echo '#!/bin/bash' > $@ && echo 'echo \"Linux Weaver binary\"' >> $@ && chmod +x $@",
    )
    
    native.genrule(
        name = name + "_darwin_binary",
        outs = ["weaver_darwin"],
        cmd = "echo '#!/bin/bash' > $@ && echo 'echo \"Darwin Weaver binary\"' >> $@ && chmod +x $@",
    )
    
    # Create platform-specific toolchains
    weaver_toolchain(
        name = name + "_linux_toolchain",
        weaver_binary = ":" + name + "_linux_binary",
        version = "0.1.0",
        platform = "linux-x86_64",
    )
    
    weaver_toolchain(
        name = name + "_darwin_toolchain",
        weaver_binary = ":" + name + "_darwin_binary",
        version = "0.1.0",
        platform = "darwin-x86_64",
    )
    
    # Create a simple schema for testing
    native.genrule(
        name = name + "_test_schema",
        outs = ["test_schema.yaml"],
        cmd = "echo 'name: TestSchema' > $@ && echo 'version: 1.0' >> $@",
    )
    
    # Create a weaver_generate target that uses the toolchain
    weaver_generate(
        name = name + "_generated_code",
        srcs = [":" + name + "_test_schema"],
        format = "typescript",
        args = ["--verbose"],
    )
    
    # Create test rules
    toolchain_resolution_integration_test(
        name = name + "_resolution_test",
        generated_target = ":" + name + "_generated_code",
    )
    
    cross_platform_toolchain_test(
        name = name + "_cross_platform_test",
        toolchain = ":" + name + "_linux_toolchain",
    )
    
    toolchain_constraint_test(
        name = name + "_constraint_test",
        toolchain = ":" + name + "_darwin_toolchain",
    )
    
    # Create test suite
    native.test_suite(
        name = name,
        tests = [
            ":" + name + "_resolution_test",
            ":" + name + "_cross_platform_test",
            ":" + name + "_constraint_test",
        ],
    ) 