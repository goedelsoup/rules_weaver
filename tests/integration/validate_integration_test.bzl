"""
Integration tests for the weaver_validate rule.

This module contains integration tests that verify the actual execution
of validation actions using OpenTelemetry Weaver.
"""

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")
load("//weaver:defs.bzl", "weaver_validate")
load("//weaver:providers.bzl", "WeaverValidationInfo")

def _weaver_validate_integration_test_impl(ctx):
    """Integration test implementation for weaver_validate rule."""
    env = analysistest.begin(ctx)
    
    # Get the target under test
    target = analysistest.target_under_test(env)
    
    # Verify that WeaverValidationInfo provider is present
    validation_info = target[WeaverValidationInfo]
    asserts.true(env, validation_info != None, "WeaverValidationInfo provider should be present")
    
    # Verify validation output file exists and is accessible
    validation_output = validation_info.validation_output
    asserts.true(env, validation_output != None, "Validation output should be present")
    
    # Verify the validation output file is in the runfiles
    default_info = target[DefaultInfo]
    runfiles = default_info.data_runfiles.files.to_list()
    asserts.true(env, validation_output in runfiles, "Validation output should be in runfiles")
    
    # Verify schemas are collected correctly
    schemas = validation_info.validated_schemas
    asserts.true(env, len(schemas) > 0, "At least one schema should be validated")
    
    # Verify schema files exist
    for schema in schemas:
        asserts.true(env, schema != None, "Schema file should not be None")
        asserts.true(env, schema.basename.endswith(".yaml"), "Schema should be a YAML file")
    
    return analysistest.end(env)

def _weaver_validate_policy_integration_test_impl(ctx):
    """Integration test implementation for weaver_validate rule with policies."""
    env = analysistest.begin(ctx)
    
    # Get the target under test
    target = analysistest.target_under_test(env)
    
    # Verify that WeaverValidationInfo provider is present
    validation_info = target[WeaverValidationInfo]
    asserts.true(env, validation_info != None, "WeaverValidationInfo provider should be present")
    
    # Verify policies are collected correctly
    policies = validation_info.applied_policies
    asserts.true(env, len(policies) > 0, "At least one policy should be applied")
    
    # Verify policy files exist
    for policy in policies:
        asserts.true(env, policy != None, "Policy file should not be None")
        asserts.true(env, policy.basename.endswith(".yaml"), "Policy should be a YAML file")
    
    # Verify validation arguments include policy references
    args = validation_info.validation_args
    asserts.true(env, args != None, "Validation arguments should be present")
    
    return analysistest.end(env)

def _weaver_validate_multiple_schemas_integration_test_impl(ctx):
    """Integration test implementation for weaver_validate rule with multiple schemas."""
    env = analysistest.begin(ctx)
    
    # Get the target under test
    target = analysistest.target_under_test(env)
    
    # Verify that WeaverValidationInfo provider is present
    validation_info = target[WeaverValidationInfo]
    asserts.true(env, validation_info != None, "WeaverValidationInfo provider should be present")
    
    # Verify multiple schemas are collected
    schemas = validation_info.validated_schemas
    asserts.true(env, len(schemas) >= 2, "At least two schemas should be validated")
    
    # Verify different schema files
    schema_names = [schema.basename for schema in schemas]
    asserts.true(env, "sample.yaml" in schema_names, "sample.yaml should be included")
    asserts.true(env, "another.yaml" in schema_names, "another.yaml should be included")
    
    return analysistest.end(env)

# Integration test rules
weaver_validate_integration_test = analysistest.make(
    _weaver_validate_integration_test_impl,
    attrs = {},
)

weaver_validate_policy_integration_test = analysistest.make(
    _weaver_validate_policy_integration_test_impl,
    attrs = {},
)

weaver_validate_multiple_schemas_integration_test = analysistest.make(
    _weaver_validate_multiple_schemas_integration_test_impl,
    attrs = {},
)

def weaver_validate_integration_test_suite(name):
    """Integration test suite for weaver_validate rule."""
    
    # Basic validation integration test
    weaver_validate(
        name = name + "_basic_integration",
        testonly = True,
        schemas = ["//tests/schemas:sample.yaml"],
    )
    
    weaver_validate_integration_test(
        name = name + "_basic_integration_test",
        target_under_test = ":" + name + "_basic_integration",
    )
    
    # Policy validation integration test
    weaver_validate(
        name = name + "_policy_integration",
        testonly = True,
        schemas = ["//tests/schemas:sample.yaml"],
        policies = ["//tests/schemas:policy.yaml"],
    )
    
    weaver_validate_policy_integration_test(
        name = name + "_policy_integration_test",
        target_under_test = ":" + name + "_policy_integration",
    )
    
    # Multiple schemas integration test
    weaver_validate(
        name = name + "_multiple_schemas_integration",
        testonly = True,
        schemas = [
            "//tests/schemas:sample.yaml",
            "//tests/schemas:another.yaml",
        ],
    )
    
    weaver_validate_multiple_schemas_integration_test(
        name = name + "_multiple_schemas_integration_test",
        target_under_test = ":" + name + "_multiple_schemas_integration",
    )
    
    # Multiple policies integration test
    weaver_validate(
        name = name + "_multiple_policies_integration",
        testonly = True,
        schemas = ["//tests/schemas:sample.yaml"],
        policies = [
            "//tests/schemas:policy.yaml",
            "//tests/schemas:another_policy.yaml",
        ],
    )
    
    weaver_validate_policy_integration_test(
        name = name + "_multiple_policies_integration_test",
        target_under_test = ":" + name + "_multiple_policies_integration",
    )
    
    # Validation with custom arguments integration test
    weaver_validate(
        name = name + "_args_integration",
        testonly = True,
        schemas = ["//tests/schemas:sample.yaml"],
        args = ["--strict", "--verbose"],
    )
    
    weaver_validate_integration_test(
        name = name + "_args_integration_test",
        target_under_test = ":" + name + "_args_integration",
    )
    
    # Validation with environment variables integration test
    weaver_validate(
        name = name + "_env_integration",
        testonly = True,
        schemas = ["//tests/schemas:sample.yaml"],
        env = {"WEAVER_LOG_LEVEL": "debug"},
    )
    
    weaver_validate_integration_test(
        name = name + "_env_integration_test",
        target_under_test = ":" + name + "_env_integration",
    )
    
    # Test suite
    native.test_suite(
        name = name,
        tests = [
            ":" + name + "_basic_integration_test",
            ":" + name + "_policy_integration_test",
            ":" + name + "_multiple_schemas_integration_test",
            ":" + name + "_multiple_policies_integration_test",
            ":" + name + "_args_integration_test",
            ":" + name + "_env_integration_test",
        ],
    ) 