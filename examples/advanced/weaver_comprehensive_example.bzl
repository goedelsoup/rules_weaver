"""
Comprehensive example demonstrating all Weaver rule features.

This example shows how to use the Weaver rules for semantic convention registry management,
code generation, validation, and documentation generation with all the new features.
"""

load("@rules_weaver//weaver:defs.bzl", "weaver_generate", "weaver_validate_test")

def weaver_comprehensive_example():
    """Create a comprehensive example using all Weaver rule features."""
    
    # 1. Basic validation of semantic convention registries
    weaver_validate_test(
        name = "validate_semantic_conventions",
        registries = ["//path/to/local/registry"],
        registry_urls = [
            "https://github.com/open-telemetry/semantic-conventions.git[model]",
        ],
        policies = [
            "//path/to/policies/validation.rego",
            "//path/to/policies/naming.rego",
        ],
        policy_dirs = ["//path/to/policy/directory"],
        weaver_args = ["--strict", "--future"],
        testonly = True,
    )
    
    # 2. Generate code from semantic convention registries
    weaver_generate(
        name = "generate_opentelemetry_proto",
        registries = ["//path/to/local/registry"],
        registry_urls = [
            "https://github.com/open-telemetry/semantic-conventions.git[model]",
        ],
        target = "opentelemetry-proto",
        templates = ["//path/to/templates/opentelemetry-proto"],
        policies = ["//path/to/policies/generation.rego"],
        args = ["--verbose", "--parallel", "4"],
        out_dir = "generated/opentelemetry-proto",
        testonly = True,
    )
    
    # 3. Generate SDK code
    weaver_generate(
        name = "generate_opentelemetry_sdk",
        registries = ["//path/to/local/registry"],
        registry_urls = [
            "https://github.com/open-telemetry/semantic-conventions.git[model]",
        ],
        target = "opentelemetry-sdk",
        templates = ["//path/to/templates/opentelemetry-sdk"],
        args = ["--verbose"],
        out_dir = "generated/opentelemetry-sdk",
        testonly = True,
    )
    
    # 4. Generate documentation
    weaver_generate(
        name = "generate_documentation",
        registries = ["//path/to/local/registry"],
        registry_urls = [
            "https://github.com/open-telemetry/semantic-conventions.git[model]",
        ],
        target = "documentation",
        templates = ["//path/to/templates/documentation"],
        args = ["--format", "html", "--verbose"],
        out_dir = "generated/documentation",
        testonly = True,
    )
    
    # 5. Custom registry with local files
    weaver_generate(
        name = "generate_custom_registry",
        registries = [
            "//path/to/custom/registry/semconv.yaml",
            "//path/to/custom/registry/attributes.yaml",
        ],
        target = "custom-target",
        templates = ["//path/to/custom/templates"],
        args = ["--verbose"],
        out_dir = "generated/custom",
        testonly = True,
    )
    
    # 6. Performance-optimized generation for large registries
    weaver_generate(
        name = "generate_large_registry",
        registries = ["//path/to/large/registry"],
        registry_urls = [
            "https://github.com/open-telemetry/semantic-conventions.git[model]",
            "https://github.com/custom/semantic-conventions.git[model]",
        ],
        target = "large-target",
        templates = ["//path/to/templates"],
        args = [
            "--verbose",
            "--parallel", "8",
            "--memory-limit", "4g",
        ],
        out_dir = "generated/large",
        testonly = True,
    )

def weaver_ci_example():
    """Create a CI-optimized example for fast validation."""
    
    # Fast validation for CI
    weaver_validate_test(
        name = "ci_validation",
        registries = ["//path/to/registry"],
        weaver_args = ["--quiet"],
        testonly = True,
    )
    
    # Fast code generation for CI
    weaver_generate(
        name = "ci_generation",
        registries = ["//path/to/registry"],
        target = "opentelemetry-proto",
        args = ["--quiet"],
        testonly = True,
    )

def weaver_development_example():
    """Create a development-focused example with debugging."""
    
    # Development validation with debugging
    weaver_validate_test(
        name = "dev_validation",
        registries = ["//path/to/registry"],
        weaver_args = ["--debug", "--diagnostic-format", "json"],
        testonly = True,
    )
    
    # Development generation with verbose output
    weaver_generate(
        name = "dev_generation",
        registries = ["//path/to/registry"],
        target = "opentelemetry-proto",
        args = ["--debug", "--verbose"],
        testonly = True,
    ) 