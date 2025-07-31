"""
Example usage of weaver_generate rule.

This file demonstrates how to use the weaver_generate rule for
different code generation scenarios.
"""

load("//weaver:defs.bzl", "weaver_generate")

def basic_typescript_generation():
    """Basic TypeScript code generation from a single schema."""
    weaver_generate(
        name = "basic_generated",
        srcs = ["//tests/schemas:sample.yaml"],
        format = "typescript",
    )

def multiple_schemas_generation():
    """Generate TypeScript code from multiple schemas."""
    weaver_generate(
        name = "multiple_generated",
        srcs = [
            "//tests/schemas:sample.yaml",
            "//tests/schemas:another.yaml",
        ],
        format = "typescript",
        args = ["--verbose"],
    )

def custom_output_directory():
    """Generate code with a custom output directory."""
    weaver_generate(
        name = "custom_output",
        srcs = ["//tests/schemas:sample.yaml"],
        format = "typescript",
        out_dir = "my_custom_output",
    )

def with_environment_variables():
    """Generate code with custom environment variables."""
    weaver_generate(
        name = "env_generated",
        srcs = ["//tests/schemas:sample.yaml"],
        format = "typescript",
        env = {
            "DEBUG": "1",
            "LOG_LEVEL": "info",
        },
        args = ["--log-level", "debug"],
    )

def with_custom_arguments():
    """Generate code with custom Weaver arguments."""
    weaver_generate(
        name = "custom_args_generated",
        srcs = ["//tests/schemas:sample.yaml"],
        format = "typescript",
        args = [
            "--verbose",
            "--no-cache",
            "--output-format", "es6",
        ],
    ) 