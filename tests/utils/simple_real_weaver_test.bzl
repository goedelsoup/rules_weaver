"""
Simple Real Weaver Integration Test

This module provides a simple test to verify that real Weaver binaries
can be downloaded and used correctly.
"""

load("//weaver:defs.bzl", "weaver_schema", "weaver_generate")

def simple_real_weaver_test():
    """Simple test with real Weaver binary."""
    
    # Create a simple schema target
    weaver_schema(
        name = "simple_real_schemas",
        srcs = ["//tests/schemas:sample.yaml"],
        testonly = True,
    )
    
    # Try to generate code with real Weaver
    weaver_generate(
        name = "simple_real_generated",
        srcs = [":simple_real_schemas"],
        format = "typescript",
        args = ["--verbose"],
        testonly = True,
    ) 