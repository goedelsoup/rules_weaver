"""
Sample BUILD file demonstrating weaver_library macro usage.

This file shows how to use the weaver_library macro in a real BUILD file
with various configurations and scenarios.
"""

load("//weaver:defs.bzl", "weaver_library")

# Basic usage - creates sample, sample_generated, and sample_validation targets
weaver_library(
    name = "sample",
    srcs = ["sample.yaml"],
)

# Usage with custom Weaver arguments
weaver_library(
    name = "another",
    srcs = ["another.yaml"],
    weaver_args = [
        "--verbose",
        "--format", "typescript",
    ],
)

# Usage without validation target
weaver_library(
    name = "no_validation",
    srcs = ["sample.yaml"],
    validation = False,
)

# Usage with validation policies
weaver_library(
    name = "with_policies",
    srcs = ["sample.yaml"],
    policies = ["policy.yaml"],
    weaver_args = ["--verbose"],
)

# Usage with custom output format
weaver_library(
    name = "go_schema",
    srcs = ["sample.yaml"],
    format = "go",
    weaver_args = ["--package", "myapp"],
)

# Usage with custom output directory
weaver_library(
    name = "custom_output",
    srcs = ["sample.yaml"],
    out_dir = "my_generated_code",
    weaver_args = ["--verbose"],
)

# Usage with dependencies
weaver_library(
    name = "dependent_schema",
    srcs = ["another.yaml"],
    deps = [":sample"],
    weaver_args = ["--verbose"],
)

# Usage with environment variables
weaver_library(
    name = "env_schema",
    srcs = ["sample.yaml"],
    env = {
        "DEBUG": "1",
        "LOG_LEVEL": "info",
    },
    weaver_args = ["--log-level", "debug"],
)

# Comprehensive usage example
weaver_library(
    name = "comprehensive",
    srcs = [
        "sample.yaml",
        "another.yaml",
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
        "policy.yaml",
        "another_policy.yaml",
    ],
    fail_on_error = True,
    visibility = ["//visibility:public"],
) 