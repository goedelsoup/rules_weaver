"""
Example usage of the weaver_library macro.

This module demonstrates how to use the weaver_library macro to create
multiple Weaver targets with proper dependencies in a single declaration.
"""

load("//weaver:defs.bzl", "weaver_library")

def weaver_library_basic_example():
    """Basic example of using weaver_library macro."""
    
    # Simple library with default settings
    weaver_library(
        name = "basic_library",
        srcs = ["schema.yaml"],
    )

def weaver_library_with_custom_args():
    """Example with custom Weaver generation arguments."""
    
    weaver_library(
        name = "custom_library",
        srcs = ["schema.yaml"],
        weaver_args = [
            "--verbose",
            "--format", "typescript",
            "--output-format", "es6",
        ],
    )

def weaver_library_without_validation():
    """Example without validation target creation."""
    
    weaver_library(
        name = "no_validation_library",
        srcs = ["schema.yaml"],
        validation = False,
    )

def weaver_library_with_policies():
    """Example with validation policies."""
    
    weaver_library(
        name = "policy_library",
        srcs = ["schema.yaml"],
        policies = ["policy.yaml"],
        weaver_args = ["--verbose"],
    )

def weaver_library_with_custom_format():
    """Example with custom output format."""
    
    weaver_library(
        name = "go_library",
        srcs = ["schema.yaml"],
        format = "go",
        weaver_args = ["--package", "myapp"],
    )

def weaver_library_with_custom_output():
    """Example with custom output directory."""
    
    weaver_library(
        name = "custom_output_library",
        srcs = ["schema.yaml"],
        out_dir = "my_generated_code",
        weaver_args = ["--verbose"],
    )

def weaver_library_with_dependencies():
    """Example with schema dependencies."""
    
    # Base schema
    weaver_library(
        name = "base_library",
        srcs = ["base.yaml"],
    )
    
    # Extended schema with dependency
    weaver_library(
        name = "extended_library",
        srcs = ["extended.yaml"],
        deps = [":base_library"],
        weaver_args = ["--verbose"],
    )

def weaver_library_with_environment():
    """Example with custom environment variables."""
    
    weaver_library(
        name = "env_library",
        srcs = ["schema.yaml"],
        env = {
            "DEBUG": "1",
            "LOG_LEVEL": "info",
        },
        weaver_args = ["--log-level", "debug"],
    )

def weaver_library_comprehensive_example():
    """Comprehensive example with all features."""
    
    weaver_library(
        name = "comprehensive_library",
        srcs = [
            "service_schema.yaml",
            "config_schema.json",
        ],
        deps = [":base_schemas"],
        weaver_args = [
            "--verbose",
            "--format", "typescript",
            "--output-format", "es6",
        ],
        format = "typescript",
        out_dir = "generated_api",
        env = {
            "DEBUG": "1",
            "LOG_LEVEL": "info",
        },
        policies = [
            "api_policy.yaml",
            "security_policy.yaml",
        ],
        fail_on_error = True,
        visibility = ["//visibility:public"],
    )

def weaver_library_test_example():
    """Example with test-only validation."""
    
    weaver_library(
        name = "test_library",
        srcs = ["schema.yaml"],
        testonly = True,
        policies = ["test_policy.yaml"],
        weaver_args = ["--verbose"],
    ) 