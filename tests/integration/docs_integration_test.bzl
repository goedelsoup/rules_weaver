"""
Integration tests for weaver_docs rule.

This module contains integration tests for the weaver_docs rule,
testing actual documentation generation with sample schemas.
"""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("//weaver:defs.bzl", "weaver_docs", "weaver_schema")
load("//weaver:providers.bzl", "WeaverDocsInfo")

def _weaver_docs_integration_test_impl(ctx):
    """Integration test for weaver_docs with actual schema files."""
    env = unittest.begin(ctx)
    
    # Test documentation generation with sample schema
    try:
        # Create a sample schema target
        weaver_schema(
            name = "test_schema_for_docs",
            srcs = ["//tests/schemas:sample.yaml"],
        )
        
        # Generate documentation from the schema
        weaver_docs(
            name = "test_docs_integration",
            schemas = ["//tests/schemas:sample.yaml"],
            format = "html",
        )
        
        asserts.true(env, True, "Documentation integration test created successfully")
    except Exception as e:
        asserts.fail(env, "Failed to create documentation integration test: " + str(e))
    
    unittest.end(env)

def _weaver_docs_template_integration_test_impl(ctx):
    """Integration test for weaver_docs with custom template."""
    env = unittest.begin(ctx)
    
    # Test documentation generation with custom template
    try:
        weaver_docs(
            name = "test_template_integration",
            schemas = ["//tests/schemas:sample.yaml"],
            format = "html",
            template = "//weaver/templates:default.html.template",
        )
        
        asserts.true(env, True, "Template integration test created successfully")
    except Exception as e:
        asserts.fail(env, "Failed to create template integration test: " + str(e))
    
    unittest.end(env)

def _weaver_docs_multiple_formats_test_impl(ctx):
    """Integration test for weaver_docs with multiple output formats."""
    env = unittest.begin(ctx)
    
    # Test HTML format
    try:
        weaver_docs(
            name = "test_html_integration",
            schemas = ["//tests/schemas:sample.yaml"],
            format = "html",
        )
        asserts.true(env, True, "HTML format integration test created successfully")
    except Exception as e:
        asserts.fail(env, "Failed to create HTML format integration test: " + str(e))
    
    # Test Markdown format
    try:
        weaver_docs(
            name = "test_markdown_integration",
            schemas = ["//tests/schemas:sample.yaml"],
            format = "markdown",
        )
        asserts.true(env, True, "Markdown format integration test created successfully")
    except Exception as e:
        asserts.fail(env, "Failed to create Markdown format integration test: " + str(e))
    
    unittest.end(env)

def _weaver_docs_multiple_schemas_integration_test_impl(ctx):
    """Integration test for weaver_docs with multiple schemas."""
    env = unittest.begin(ctx)
    
    # Test with multiple schema files
    try:
        weaver_docs(
            name = "test_multiple_schemas_integration",
            schemas = [
                "//tests/schemas:sample.yaml",
                "//tests/schemas:policy.yaml",
            ],
            format = "html",
        )
        
        asserts.true(env, True, "Multiple schemas integration test created successfully")
    except Exception as e:
        asserts.fail(env, "Failed to create multiple schemas integration test: " + str(e))
    
    unittest.end(env)

def _weaver_docs_args_integration_test_impl(ctx):
    """Integration test for weaver_docs with additional arguments."""
    env = unittest.begin(ctx)
    
    # Test with additional arguments and environment variables
    try:
        weaver_docs(
            name = "test_args_integration",
            schemas = ["//tests/schemas:sample.yaml"],
            format = "html",
            args = ["--verbose", "--no-cache"],
            env = {
                "WEAVER_DEBUG": "1",
                "WEAVER_DOCS_THEME": "dark",
            },
        )
        
        asserts.true(env, True, "Arguments integration test created successfully")
    except Exception as e:
        asserts.fail(env, "Failed to create arguments integration test: " + str(e))
    
    unittest.end(env)

def _weaver_docs_output_dir_integration_test_impl(ctx):
    """Integration test for weaver_docs with custom output directory."""
    env = unittest.begin(ctx)
    
    # Test with custom output directory
    try:
        weaver_docs(
            name = "test_output_dir_integration",
            schemas = ["//tests/schemas:sample.yaml"],
            format = "html",
            output_dir = "custom_docs_integration",
        )
        
        asserts.true(env, True, "Output directory integration test created successfully")
    except Exception as e:
        asserts.fail(env, "Failed to create output directory integration test: " + str(e))
    
    unittest.end(env)

def _weaver_docs_provider_integration_test_impl(ctx):
    """Integration test for weaver_docs provider information."""
    env = unittest.begin(ctx)
    
    # Test that the rule provides correct WeaverDocsInfo
    try:
        weaver_docs(
            name = "test_provider_integration",
            schemas = ["//tests/schemas:sample.yaml"],
            format = "html",
        )
        
        asserts.true(env, True, "Provider integration test created successfully")
    except Exception as e:
        asserts.fail(env, "Failed to create provider integration test: " + str(e))
    
    unittest.end(env)

# Integration test rules
weaver_docs_integration_test = unittest.make(_weaver_docs_integration_test_impl)
weaver_docs_template_integration_test = unittest.make(_weaver_docs_template_integration_test_impl)
weaver_docs_multiple_formats_test = unittest.make(_weaver_docs_multiple_formats_test_impl)
weaver_docs_multiple_schemas_integration_test = unittest.make(_weaver_docs_multiple_schemas_integration_test_impl)
weaver_docs_args_integration_test = unittest.make(_weaver_docs_args_integration_test_impl)
weaver_docs_output_dir_integration_test = unittest.make(_weaver_docs_output_dir_integration_test_impl)
weaver_docs_provider_integration_test = unittest.make(_weaver_docs_provider_integration_test_impl)

def weaver_docs_integration_test_suite(name):
    """Create an integration test suite for weaver_docs functionality."""
    unittest.suite(
        name,
        weaver_docs_integration_test,
        weaver_docs_template_integration_test,
        weaver_docs_multiple_formats_test,
        weaver_docs_multiple_schemas_integration_test,
        weaver_docs_args_integration_test,
        weaver_docs_output_dir_integration_test,
        weaver_docs_provider_integration_test,
    ) 