"""
Toolchain type definition for OpenTelemetry Weaver.

This module defines the toolchain type for Weaver operations.
"""

toolchain_type = rule(
    implementation = lambda ctx: [],
    attrs = {},
    doc = "Toolchain type for OpenTelemetry Weaver operations",
)

# Export the toolchain type for use in BUILD files
weaver_toolchain_type = toolchain_type 