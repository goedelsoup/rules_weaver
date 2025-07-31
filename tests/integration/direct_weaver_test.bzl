"""
Test that directly uses the real Weaver binary.
"""

load("//weaver:defs.bzl", "weaver_validate_test")

def direct_weaver_test():
    """Test that directly uses the real Weaver binary."""
    
    weaver_validate_test(
        name = "direct_weaver_test",
        registries = [
            "//tests/schemas:sample.yaml",
        ],
        weaver = "@weaver_binary//:weaver-aarch64-apple-darwin/weaver",
        weaver_args = ["--quiet"],
        testonly = True,
        tags = ["real_weaver", "integration"],
    ) 