"""
Example usage of the weaver_schema rule.

This module demonstrates how to use the weaver_schema rule to declare
schema files as Bazel targets and manage schema dependencies.
"""

load("//weaver:defs.bzl", "weaver_schema", "weaver_generate", "weaver_validate")

def weaver_schema_example():
    """Example of using weaver_schema with various schema files."""
    
    # Basic schema declaration
    weaver_schema(
        name = "basic_schema",
        srcs = ["schema.yaml"],
        visibility = ["//visibility:public"],
    )
    
    # Schema with multiple files
    weaver_schema(
        name = "multi_schema",
        srcs = [
            "service_schema.yaml",
            "config_schema.json",
        ],
        visibility = ["//visibility:public"],
    )
    
    # Schema with dependencies
    weaver_schema(
        name = "base_schema",
        srcs = ["base.yaml"],
        visibility = ["//visibility:public"],
    )
    
    weaver_schema(
        name = "extended_schema",
        srcs = ["extended.yaml"],
        deps = [":base_schema"],
        visibility = ["//visibility:public"],
    )
    
    # Using schema targets with weaver_generate
    weaver_generate(
        name = "generate_from_schema",
        srcs = [":basic_schema"],
        format = "typescript",
        args = ["--verbose"],
    )
    
    # Using schema targets with weaver_validate
    weaver_validate(
        name = "validate_schema",
        schemas = [":basic_schema"],
        policies = ["policy.yaml"],
        args = ["--strict"],
    )

def weaver_schema_complex_example():
    """Complex example with multiple schema dependencies."""
    
    # Create a hierarchy of schema dependencies
    weaver_schema(
        name = "core_schema",
        srcs = ["core.yaml"],
        visibility = ["//visibility:public"],
    )
    
    weaver_schema(
        name = "service_schema",
        srcs = ["service.yaml"],
        deps = [":core_schema"],
        visibility = ["//visibility:public"],
    )
    
    weaver_schema(
        name = "api_schema",
        srcs = ["api.yaml"],
        deps = [":service_schema"],
        visibility = ["//visibility:public"],
    )
    
    # Generate code from the complete schema hierarchy
    weaver_generate(
        name = "generate_api",
        srcs = [":api_schema"],
        format = "typescript",
        out_dir = "generated_api",
    )
    
    # Validate the complete schema hierarchy
    weaver_validate(
        name = "validate_api",
        schemas = [":api_schema"],
        policies = ["api_policy.yaml"],
        fail_on_error = True,
    )

def weaver_schema_mixed_formats_example():
    """Example with mixed YAML and JSON schema formats."""
    
    # YAML schema
    weaver_schema(
        name = "yaml_schema",
        srcs = ["config.yaml"],
        visibility = ["//visibility:public"],
    )
    
    # JSON schema
    weaver_schema(
        name = "json_schema",
        srcs = ["metadata.json"],
        visibility = ["//visibility:public"],
    )
    
    # Combined schema target
    weaver_schema(
        name = "mixed_schema",
        srcs = [
            ":yaml_schema",
            ":json_schema",
        ],
        visibility = ["//visibility:public"],
    )
    
    # Generate from mixed formats
    weaver_generate(
        name = "generate_mixed",
        srcs = [":mixed_schema"],
        format = "go",
        args = ["--package", "myapp"],
    ) 