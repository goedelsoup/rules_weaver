"""
Example usage of the weaver_validate rule.

This module demonstrates various ways to use the weaver_validate rule
for schema validation with OpenTelemetry Weaver.
"""

load("//weaver:defs.bzl", "weaver_validate")

def weaver_validate_examples():
    """Examples of using the weaver_validate rule."""
    
    # Basic validation example
    weaver_validate(
        name = "validate_basic",
        schemas = ["//examples:my_schema.yaml"],
    )
    
    # Validation with policies
    weaver_validate(
        name = "validate_with_policies",
        schemas = ["//examples:my_schema.yaml"],
        policies = ["//examples:my_policy.yaml"],
    )
    
    # Validation as a test
    weaver_validate(
        name = "validate_as_test",
        testonly = True,
        schemas = ["//examples:my_schema.yaml"],
        policies = ["//examples:my_policy.yaml"],
    )
    
    # Validation with custom arguments
    weaver_validate(
        name = "validate_strict",
        schemas = ["//examples:my_schema.yaml"],
        args = ["--strict", "--verbose"],
    )
    
    # Validation with environment variables
    weaver_validate(
        name = "validate_debug",
        schemas = ["//examples:my_schema.yaml"],
        env = {"WEAVER_LOG_LEVEL": "debug"},
    )
    
    # Validation with multiple schemas
    weaver_validate(
        name = "validate_multiple_schemas",
        schemas = [
            "//examples:schema1.yaml",
            "//examples:schema2.yaml",
            "//examples:schema3.yaml",
        ],
    )
    
    # Validation with multiple policies
    weaver_validate(
        name = "validate_multiple_policies",
        schemas = ["//examples:my_schema.yaml"],
        policies = [
            "//examples:policy1.yaml",
            "//examples:policy2.yaml",
            "//examples:policy3.yaml",
        ],
    )
    
    # Validation that doesn't fail on error
    weaver_validate(
        name = "validate_no_fail",
        schemas = ["//examples:my_schema.yaml"],
        fail_on_error = False,
    )
    
    # Validation with custom Weaver binary
    weaver_validate(
        name = "validate_custom_weaver",
        schemas = ["//examples:my_schema.yaml"],
        weaver = "//tools:custom_weaver_binary",
    )
    
    # Validation with all options
    weaver_validate(
        name = "validate_comprehensive",
        schemas = [
            "//examples:schema1.yaml",
            "//examples:schema2.yaml",
        ],
        policies = [
            "//examples:policy1.yaml",
            "//examples:policy2.yaml",
        ],
        args = ["--strict", "--verbose", "--format", "json"],
        env = {
            "WEAVER_LOG_LEVEL": "info",
            "WEAVER_OUTPUT_FORMAT": "json",
        },
        fail_on_error = True,
    ) 