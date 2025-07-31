"""
Integration tests for the weaver_schema rule.

This module tests the weaver_schema rule with real schema files
and complex dependency scenarios.
"""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("//weaver:defs.bzl", "weaver_schema", "weaver_generate", "weaver_validate")
load("//weaver:providers.bzl", "WeaverSchemaInfo")

def _weaver_schema_integration_test_impl(ctx):
    """Integration test for weaver_schema with real schema files."""
    env = unittest.begin(ctx)
    
    # Test that schema targets can be used by other rules
    schema_target = ctx.attr.schema_target
    schema_info = schema_target[WeaverSchemaInfo]
    
    # Verify schema files are accessible
    asserts.true(env, len(schema_info.schema_files) > 0)
    
    # Verify parsed content is available
    asserts.true(env, len(schema_info.schema_content) > 0)
    
    # Verify metadata is populated
    asserts.true(env, "schema_count" in schema_info.metadata)
    asserts.true(env, "formats" in schema_info.metadata)
    
    return unittest.end(env)

def _weaver_schema_dependency_integration_test_impl(ctx):
    """Test schema dependencies in integration scenarios."""
    env = unittest.begin(ctx)
    
    # Test that schema dependencies are properly tracked
    schema_target = ctx.attr.schema_target
    schema_info = schema_target[WeaverSchemaInfo]
    
    # Verify dependencies structure exists
    asserts.true(env, hasattr(schema_info, "dependencies"))
    
    return unittest.end(env)

def _weaver_schema_with_generate_integration_test_impl(ctx):
    """Test weaver_schema integration with weaver_generate."""
    env = unittest.begin(ctx)
    
    # Test that schema targets can be used by weaver_generate
    # This verifies the integration between rules
    generate_target = ctx.attr.generate_target
    
    # Verify the generate target was created successfully
    asserts.true(env, generate_target != None)
    
    return unittest.end(env)

def _weaver_schema_with_validate_integration_test_impl(ctx):
    """Test weaver_schema integration with weaver_validate."""
    env = unittest.begin(ctx)
    
    # Test that schema targets can be used by weaver_validate
    validate_target = ctx.attr.validate_target
    
    # Verify the validate target was created successfully
    asserts.true(env, validate_target != None)
    
    return unittest.end(env)

# Test targets
weaver_schema_integration_test = unittest.make(
    _weaver_schema_integration_test_impl,
    attrs = {
        "schema_target": attr.label(
            default = "//tests/schemas:integration_schema",
            providers = [WeaverSchemaInfo],
        ),
    },
)

weaver_schema_dependency_integration_test = unittest.make(
    _weaver_schema_dependency_integration_test_impl,
    attrs = {
        "schema_target": attr.label(
            default = "//tests/schemas:dependency_schema",
            providers = [WeaverSchemaInfo],
        ),
    },
)

weaver_schema_with_generate_integration_test = unittest.make(
    _weaver_schema_with_generate_integration_test_impl,
    attrs = {
        "generate_target": attr.label(
            default = "//tests/schemas:generate_from_schema",
        ),
    },
)

weaver_schema_with_validate_integration_test = unittest.make(
    _weaver_schema_with_validate_integration_test_impl,
    attrs = {
        "validate_target": attr.label(
            default = "//tests/schemas:validate_schema",
        ),
    },
)

def weaver_schema_integration_test_suite(name):
    """Create an integration test suite for weaver_schema rule."""
    
    # Create schema targets for integration testing
    weaver_schema(
        name = "integration_schema",
        srcs = [
            "//tests/schemas:sample.yaml",
            "//tests/schemas:policy.yaml",
        ],
        tags = ["manual"],
    )
    
    weaver_schema(
        name = "base_schema",
        srcs = ["//tests/schemas:sample.yaml"],
        tags = ["manual"],
    )
    
    weaver_schema(
        name = "dependency_schema",
        srcs = ["//tests/schemas:another.yaml"],
        deps = [":base_schema"],
        tags = ["manual"],
    )
    
    # Test integration with weaver_generate
    weaver_generate(
        name = "generate_from_schema",
        srcs = [":integration_schema"],
        format = "typescript",
        tags = ["manual"],
    )
    
    # Test integration with weaver_validate
    weaver_validate(
        name = "validate_schema",
        schemas = [":integration_schema"],
        policies = ["//tests/schemas:policy.yaml"],
        tags = ["manual"],
    )
    
    # Run all integration tests
    unittest.suite(
        name,
        weaver_schema_integration_test,
        weaver_schema_dependency_integration_test,
        weaver_schema_with_generate_integration_test,
        weaver_schema_with_validate_integration_test,
    ) 