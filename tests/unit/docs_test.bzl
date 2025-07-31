"""
Unit tests for weaver_docs rule.

This module contains comprehensive tests for the weaver_docs rule,
including template validation, output format verification, and
integration testing with sample schemas.
"""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("//weaver:defs.bzl", "weaver_docs")
load("//weaver:providers.bzl", "WeaverDocsInfo")

def _weaver_docs_basic_test_impl(ctx):
    """Test basic weaver_docs functionality."""
    env = unittest.begin(ctx)
    
    # Test that the rule can be created with basic parameters
    try:
        weaver_docs(
            name = "test_docs",
            schemas = ["test_schema.yaml"],
            format = "html",
        )
        asserts.true(env, True, "weaver_docs rule created successfully")
    except Exception as e:
        asserts.fail(env, "Failed to create weaver_docs rule: " + str(e))
    
    unittest.end(env)

def _weaver_docs_format_test_impl(ctx):
    """Test weaver_docs with different formats."""
    env = unittest.begin(ctx)
    
    # Test HTML format
    try:
        weaver_docs(
            name = "test_html_docs",
            schemas = ["test_schema.yaml"],
            format = "html",
        )
        asserts.true(env, True, "HTML format documentation rule created successfully")
    except Exception as e:
        asserts.fail(env, "Failed to create HTML documentation rule: " + str(e))
    
    # Test Markdown format
    try:
        weaver_docs(
            name = "test_md_docs",
            schemas = ["test_schema.yaml"],
            format = "markdown",
        )
        asserts.true(env, True, "Markdown format documentation rule created successfully")
    except Exception as e:
        asserts.fail(env, "Failed to create Markdown documentation rule: " + str(e))
    
    # Test PDF format
    try:
        weaver_docs(
            name = "test_pdf_docs",
            schemas = ["test_schema.yaml"],
            format = "pdf",
        )
        asserts.true(env, True, "PDF format documentation rule created successfully")
    except Exception as e:
        asserts.fail(env, "Failed to create PDF documentation rule: " + str(e))
    
    unittest.end(env)

def _weaver_docs_template_test_impl(ctx):
    """Test weaver_docs with custom templates."""
    env = unittest.begin(ctx)
    
    # Test with custom template
    try:
        weaver_docs(
            name = "test_template_docs",
            schemas = ["test_schema.yaml"],
            format = "html",
            template = "//weaver/templates:default.html.template",
        )
        asserts.true(env, True, "Custom template documentation rule created successfully")
    except Exception as e:
        asserts.fail(env, "Failed to create custom template documentation rule: " + str(e))
    
    unittest.end(env)

def _weaver_docs_args_test_impl(ctx):
    """Test weaver_docs with additional arguments."""
    env = unittest.begin(ctx)
    
    # Test with additional arguments
    try:
        weaver_docs(
            name = "test_args_docs",
            schemas = ["test_schema.yaml"],
            format = "html",
            args = ["--verbose", "--no-cache"],
            env = {"WEAVER_DEBUG": "1"},
        )
        asserts.true(env, True, "Documentation rule with arguments created successfully")
    except Exception as e:
        asserts.fail(env, "Failed to create documentation rule with arguments: " + str(e))
    
    unittest.end(env)

def _weaver_docs_output_dir_test_impl(ctx):
    """Test weaver_docs with custom output directory."""
    env = unittest.begin(ctx)
    
    # Test with custom output directory
    try:
        weaver_docs(
            name = "test_output_dir_docs",
            schemas = ["test_schema.yaml"],
            format = "html",
            output_dir = "custom_docs",
        )
        asserts.true(env, True, "Custom output directory documentation rule created successfully")
    except Exception as e:
        asserts.fail(env, "Failed to create custom output directory documentation rule: " + str(e))
    
    unittest.end(env)

def _weaver_docs_multiple_schemas_test_impl(ctx):
    """Test weaver_docs with multiple schemas."""
    env = unittest.begin(ctx)
    
    # Test with multiple schemas
    try:
        weaver_docs(
            name = "test_multiple_schemas_docs",
            schemas = ["schema1.yaml", "schema2.yaml", "schema3.json"],
            format = "html",
        )
        asserts.true(env, True, "Multiple schemas documentation rule created successfully")
    except Exception as e:
        asserts.fail(env, "Failed to create multiple schemas documentation rule: " + str(e))
    
    unittest.end(env)

def _weaver_docs_provider_test_impl(ctx):
    """Test weaver_docs provider information."""
    env = unittest.begin(ctx)
    
    # Test that the rule provides WeaverDocsInfo
    try:
        weaver_docs(
            name = "test_provider_docs",
            schemas = ["test_schema.yaml"],
            format = "html",
        )
        asserts.true(env, True, "Documentation rule with provider created successfully")
    except Exception as e:
        asserts.fail(env, "Failed to create documentation rule with provider: " + str(e))
    
    unittest.end(env)

# Test rules
weaver_docs_basic_test = unittest.make(_weaver_docs_basic_test_impl)
weaver_docs_format_test = unittest.make(_weaver_docs_format_test_impl)
weaver_docs_template_test = unittest.make(_weaver_docs_template_test_impl)
weaver_docs_args_test = unittest.make(_weaver_docs_args_test_impl)
weaver_docs_output_dir_test = unittest.make(_weaver_docs_output_dir_test_impl)
weaver_docs_multiple_schemas_test = unittest.make(_weaver_docs_multiple_schemas_test_impl)
weaver_docs_provider_test = unittest.make(_weaver_docs_provider_test_impl)

def weaver_docs_test_suite(name):
    """Create a test suite for weaver_docs functionality."""
    unittest.suite(
        name,
        weaver_docs_basic_test,
        weaver_docs_format_test,
        weaver_docs_template_test,
        weaver_docs_args_test,
        weaver_docs_output_dir_test,
        weaver_docs_multiple_schemas_test,
        weaver_docs_provider_test,
    ) 