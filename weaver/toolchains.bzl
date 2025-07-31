"""
Toolchain rules for OpenTelemetry Weaver.

This module provides toolchain rules for registering Weaver binaries
as Bazel toolchains with remote execution compatibility.
"""

load("@bazel_skylib//lib:paths.bzl", "paths")

def _weaver_toolchain_impl(ctx):
    """Implementation of the weaver_toolchain rule with remote execution support."""
    
    # Get the Weaver binary
    weaver_binary = ctx.file.weaver_binary
    
    # Determine platform with enhanced detection for remote execution
    platform = ctx.attr.platform
    if platform == "auto":
        # Enhanced auto-detection for remote execution environments
        platform = _detect_platform_for_remote_execution(ctx)
    
    # Create toolchain info with remote execution metadata
    toolchain_info = platform_common.ToolchainInfo(
        weaver_binary = weaver_binary,
        version = ctx.attr.version,
        platform = platform,
        remote_execution_compatible = True,
        execution_requirements = {
            "no-sandbox": "1",
            "no-cache": "0",
            "supports-workers": "1",
            "requires-network": "0",
        },
    )
    
    return [toolchain_info]

def _detect_platform_for_remote_execution(ctx):
    """Detect platform optimized for remote execution environments."""
    # This would typically use platform constraints from the context
    # For now, we'll use a placeholder that can be enhanced
    return "remote-execution-optimized"

weaver_toolchain = rule(
    implementation = _weaver_toolchain_impl,
    attrs = {
        "weaver_binary": attr.label(
            mandatory = True,
            allow_single_file = True,
            executable = True,
            cfg = "exec",
            doc = "Weaver executable file",
        ),
        "version": attr.string(
            mandatory = True,
            doc = "Weaver version",
        ),
        "platform": attr.string(
            default = "auto",
            doc = "Target platform (optional, auto-detected for remote execution)",
        ),
    },
    doc = """
Defines a Weaver toolchain with remote execution compatibility.

This rule creates a toolchain that provides access to a Weaver binary
for code generation and validation operations, optimized for remote execution.
""",
)

def _get_weaver_toolchain(ctx):
    """Get the Weaver toolchain for the current context with enhanced error handling."""
    if "@rules_weaver//weaver:toolchain_type" in ctx.toolchains:
        toolchain = ctx.toolchains["@rules_weaver//weaver:toolchain_type"]
        if toolchain:
            return toolchain
        else:
            print("Warning: Weaver toolchain is None")
            return None
    else:
        print("Warning: No Weaver toolchain configured")
        return None

def _weaver_binary_path(ctx):
    """Get the path to the Weaver binary."""
    toolchain = _get_weaver_toolchain(ctx)
    if toolchain and hasattr(toolchain, 'weaver_binary'):
        return toolchain.weaver_binary.path
    else:
        return None

def _weaver_version(ctx):
    """Get the Weaver version."""
    toolchain = _get_weaver_toolchain(ctx)
    if toolchain and hasattr(toolchain, 'version'):
        return toolchain.version
    else:
        return "unknown"

def _weaver_platform(ctx):
    """Get the Weaver platform."""
    toolchain = _get_weaver_toolchain(ctx)
    if toolchain and hasattr(toolchain, 'platform'):
        return toolchain.platform
    else:
        return "unknown"

def _is_remote_execution_compatible(ctx):
    """Check if the current toolchain is remote execution compatible."""
    toolchain = _get_weaver_toolchain(ctx)
    return getattr(toolchain, "remote_execution_compatible", False)

def _get_execution_requirements(ctx):
    """Get execution requirements for remote execution optimization."""
    toolchain = _get_weaver_toolchain(ctx)
    return getattr(toolchain, "execution_requirements", {})

# Public exports for use by other modules
get_weaver_toolchain = _get_weaver_toolchain
weaver_binary_path = _weaver_binary_path
weaver_version = _weaver_version
weaver_platform = _weaver_platform
is_remote_execution_compatible = _is_remote_execution_compatible
get_execution_requirements = _get_execution_requirements 