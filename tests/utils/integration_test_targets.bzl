"""
Integration test targets for Weaver rules.

This module creates actual BUILD file targets that use the Weaver rules
for comprehensive integration testing.
"""

load("@rules_weaver//weaver:defs.bzl", "weaver_generate", "weaver_validate_test")

def create_integration_test_targets():
    """Create integration test targets using actual Weaver rules."""
    
    # Test weaver_generate rule with registry
    weaver_generate(
        name = "test_generated_code",
        registries = ["test1.yaml", "test2.yaml"],
        target = "test-target",
        args = ["--quiet"],
    )
    
    # Test weaver_validate_test rule with registry
    weaver_validate_test(
        name = "test_validation",
        registries = ["test1.yaml", "test2.yaml"],
        policies = [],
        weaver_args = ["--quiet"],
    ) 