"""
Multi-platform example for OpenTelemetry Weaver rules.

This example demonstrates how to use Weaver rules across different platforms
including Linux, macOS, and Windows with x86_64 and ARM64 architectures.
"""

load("//weaver:defs.bzl", "weaver_schema", "weaver_generate", "weaver_validate", "weaver_docs")
load("//weaver:platform_constraints.bzl", 
     "get_supported_platforms",
     "get_platform_metadata",
     "is_windows_platform",
     "normalize_path")

def multi_platform_weaver_example():
    """Example demonstrating multi-platform Weaver usage."""
    
    # Example 1: Basic schema definition (works on all platforms)
    weaver_schema(
        name = "multi_platform_schema",
        srcs = [
            "//examples/schemas:api.yaml",
            "//examples/schemas:config.yaml",
        ],
        deps = [
            "//examples/schemas:common",
        ],
        # Platform-specific metadata will be automatically added
        tags = ["multi_platform"],
    )
    
    # Example 2: Code generation with platform-specific output
    weaver_generate(
        name = "multi_platform_generate",
        schemas = [":multi_platform_schema"],
        format = "go",
        output_dir = "generated",
        # Platform-specific optimizations will be applied automatically
        args = [
            "--platform-aware",
            "--optimize-for-target",
        ],
        tags = ["multi_platform"],
    )
    
    # Example 3: Validation with platform-specific policies
    weaver_validate(
        name = "multi_platform_validate",
        schemas = [":multi_platform_schema"],
        policies = [
            "//examples/policies:linux_policy.yaml",
            "//examples/policies:windows_policy.yaml",
            "//examples/policies:macos_policy.yaml",
        ],
        # Platform-specific validation rules will be applied
        args = [
            "--platform-specific-validation",
        ],
        tags = ["multi_platform"],
    )
    
    # Example 4: Documentation generation with platform-specific templates
    weaver_docs(
        name = "multi_platform_docs",
        schemas = [":multi_platform_schema"],
        template = "//examples/templates:platform_specific.html",
        output_dir = "docs",
        # Platform-specific documentation will be generated
        args = [
            "--platform-docs",
            "--include-platform-info",
        ],
        tags = ["multi_platform"],
    )

def platform_specific_examples():
    """Examples for platform-specific configurations."""
    
    # Linux-specific example
    weaver_schema(
        name = "linux_schema",
        srcs = ["//examples/schemas:linux_specific.yaml"],
        # Linux-specific attributes
        tags = ["linux", "x86_64", "aarch64"],
    )
    
    # Windows-specific example
    weaver_schema(
        name = "windows_schema", 
        srcs = ["//examples/schemas:windows_specific.yaml"],
        # Windows-specific attributes
        tags = ["windows", "x86_64", "aarch64"],
    )
    
    # macOS-specific example
    weaver_schema(
        name = "macos_schema",
        srcs = ["//examples/schemas:macos_specific.yaml"],
        # macOS-specific attributes
        tags = ["macos", "x86_64", "aarch64"],
    )
    
    # ARM64-specific example
    weaver_schema(
        name = "arm64_schema",
        srcs = ["//examples/schemas:arm64_specific.yaml"],
        # ARM64-specific attributes
        tags = ["arm64", "aarch64"],
    )

def cross_platform_workflow_example():
    """Example demonstrating cross-platform workflow."""
    
    # Step 1: Define schemas that work across all platforms
    weaver_schema(
        name = "cross_platform_schema",
        srcs = [
            "//examples/schemas:api.yaml",
            "//examples/schemas:models.yaml",
            "//examples/schemas:config.yaml",
        ],
        deps = [
            "//examples/schemas:common",
        ],
        tags = ["cross_platform"],
    )
    
    # Step 2: Generate platform-specific code
    weaver_generate(
        name = "cross_platform_generate",
        schemas = [":cross_platform_schema"],
        format = "go",
        output_dir = "generated",
        args = [
            "--cross-platform",
            "--platform-optimized",
        ],
        tags = ["cross_platform"],
    )
    
    # Step 3: Validate across all platforms
    weaver_validate(
        name = "cross_platform_validate",
        schemas = [":cross_platform_schema"],
        policies = [
            "//examples/policies:cross_platform.yaml",
        ],
        args = [
            "--cross-platform-validation",
        ],
        tags = ["cross_platform"],
    )
    
    # Step 4: Generate cross-platform documentation
    weaver_docs(
        name = "cross_platform_docs",
        schemas = [":cross_platform_schema"],
        template = "//examples/templates:cross_platform.html",
        output_dir = "docs",
        args = [
            "--cross-platform-docs",
        ],
        tags = ["cross_platform"],
    )

def platform_optimization_example():
    """Example demonstrating platform-specific optimizations."""
    
    # Platform-optimized schema processing
    weaver_schema(
        name = "optimized_schema",
        srcs = ["//examples/schemas:large_schema.yaml"],
        # Platform-specific optimizations will be applied
        enable_performance_monitoring = True,
        tags = ["optimized"],
    )
    
    # Platform-optimized code generation
    weaver_generate(
        name = "optimized_generate",
        schemas = [":optimized_schema"],
        format = "go",
        output_dir = "generated",
        args = [
            "--platform-optimized",
            "--parallel-processing",
            "--memory-optimized",
        ],
        tags = ["optimized"],
    )

def platform_testing_example():
    """Example demonstrating platform-specific testing."""
    
    # Test schema on all platforms
    weaver_schema(
        name = "test_schema",
        srcs = ["//examples/schemas:test.yaml"],
        tags = ["test", "multi_platform"],
    )
    
    # Generate test code for all platforms
    weaver_generate(
        name = "test_generate",
        schemas = [":test_schema"],
        format = "go",
        output_dir = "test_generated",
        args = [
            "--test-mode",
            "--platform-testing",
        ],
        tags = ["test", "multi_platform"],
    )
    
    # Validate test schemas on all platforms
    weaver_validate(
        name = "test_validate",
        schemas = [":test_schema"],
        policies = ["//examples/policies:test.yaml"],
        args = [
            "--test-validation",
        ],
        tags = ["test", "multi_platform"],
    )

def platform_deployment_example():
    """Example demonstrating platform-specific deployment."""
    
    # Production schema with platform-specific deployment
    weaver_schema(
        name = "production_schema",
        srcs = ["//examples/schemas:production.yaml"],
        tags = ["production", "multi_platform"],
    )
    
    # Generate production code for all platforms
    weaver_generate(
        name = "production_generate",
        schemas = [":production_schema"],
        format = "go",
        output_dir = "production_generated",
        args = [
            "--production-mode",
            "--platform-deployment",
            "--optimize-for-production",
        ],
        tags = ["production", "multi_platform"],
    )
    
    # Validate production schemas
    weaver_validate(
        name = "production_validate",
        schemas = [":production_schema"],
        policies = [
            "//examples/policies:production.yaml",
            "//examples/policies:security.yaml",
        ],
        args = [
            "--production-validation",
            "--security-check",
        ],
        tags = ["production", "multi_platform"],
    )
    
    # Generate production documentation
    weaver_docs(
        name = "production_docs",
        schemas = [":production_schema"],
        template = "//examples/templates:production.html",
        output_dir = "production_docs",
        args = [
            "--production-docs",
            "--include-deployment-info",
        ],
        tags = ["production", "multi_platform"],
    )

# Helper functions for platform-specific logic
def get_platform_specific_config(platform):
    """Get platform-specific configuration."""
    metadata = get_platform_metadata(platform)
    
    config = {
        "platform": platform,
        "os_name": metadata["os_name"],
        "architecture": metadata["architecture"],
        "path_separator": metadata["path_separator"],
        "executable_extension": metadata["executable_extension"],
    }
    
    # Add platform-specific optimizations
    if is_windows_platform(platform):
        config.update({
            "shell": "cmd.exe",
            "path_style": "windows",
            "binary_extension": ".exe",
        })
    else:
        config.update({
            "shell": "/bin/bash",
            "path_style": "unix",
            "binary_extension": "",
        })
    
    return config

def create_platform_specific_targets():
    """Create targets for all supported platforms."""
    targets = {}
    
    for platform in get_supported_platforms():
        platform_name = platform.replace("-", "_")
        config = get_platform_specific_config(platform)
        
        # Create platform-specific schema
        weaver_schema(
            name = "{}_schema".format(platform_name),
            srcs = ["//examples/schemas:platform_specific.yaml"],
            tags = [platform, config["os_name"], config["architecture"]],
        )
        
        # Create platform-specific generation
        weaver_generate(
            name = "{}_generate".format(platform_name),
            schemas = [":{}_schema".format(platform_name)],
            format = "go",
            output_dir = "generated_{}".format(platform_name),
            args = [
                "--platform", platform,
                "--os", config["os_name"],
                "--arch", config["architecture"],
            ],
            tags = [platform, config["os_name"], config["architecture"]],
        )
        
        targets[platform] = {
            "schema": ":{}_schema".format(platform_name),
            "generate": ":{}_generate".format(platform_name),
            "config": config,
        }
    
    return targets 