"""
Simple test to verify real Weaver binary integration.
"""

load("//weaver:defs.bzl", "weaver_validate_test")

def real_weaver_simple_test():
    """Simple test with real Weaver binary."""
    
    weaver_validate_test(
        name = "real_weaver_simple_test",
        registries = [
            "//tests/schemas:sample.yaml",
        ],
        weaver_args = ["--quiet"],
        testonly = True,
        tags = ["real_weaver", "integration"],
    ) 