"""
Example usage of the weaver_toolchain rule.

This module demonstrates how to create and use Weaver toolchains
for different platforms and scenarios.
"""

load("@rules_weaver//weaver:toolchains.bzl", "weaver_toolchain")
load("@rules_weaver//weaver:defs.bzl", "weaver_generate", "weaver_validate")

def create_weaver_toolchains():
    """Create Weaver toolchains for different platforms."""
    
    # Create a mock Weaver binary for demonstration
    native.genrule(
        name = "weaver_binary",
        outs = ["weaver"],
        cmd = """
        echo '#!/bin/bash' > $@
        echo 'echo "Weaver binary version 0.1.0"' >> $@
        echo 'echo "Platform: $1"' >> $@
        echo 'echo "Input: $2"' >> $@
        echo 'echo "Output: $3"' >> $@
        echo 'echo "Generated code for $2" > $3' >> $@
        chmod +x $@
        """,
    )
    
    # Create toolchain with specified platform
    weaver_toolchain(
        name = "weaver_linux_toolchain",
        weaver_binary = ":weaver_binary",
        version = "0.1.0",
        platform = "linux-x86_64",
    )
    
    # Create toolchain with auto platform detection
    weaver_toolchain(
        name = "weaver_auto_toolchain",
        weaver_binary = ":weaver_binary",
        version = "0.1.0",
        # platform defaults to "auto"
    )
    
    # Create toolchain for macOS
    weaver_toolchain(
        name = "weaver_darwin_toolchain",
        weaver_binary = ":weaver_binary",
        version = "0.1.0",
        platform = "darwin-x86_64",
    )

def create_sample_schema():
    """Create a sample schema for testing."""
    
    native.genrule(
        name = "sample_schema",
        outs = ["sample.yaml"],
        cmd = """
        cat > $@ << 'EOF'
        name: SampleService
        version: 1.0.0
        description: A sample service schema
        endpoints:
          - name: getData
            path: /api/data
            method: GET
            response:
              type: object
              properties:
                data:
                  type: array
                  items:
                    type: string
        EOF
        """,
    )

def create_generation_example():
    """Create an example of code generation using the toolchain."""
    
    # Create schema
    create_sample_schema()
    
    # Generate TypeScript code using the toolchain
    weaver_generate(
        name = "generated_typescript",
        srcs = [":sample_schema"],
        format = "typescript",
        args = ["--verbose", "--output-dir", "generated"],
    )
    
    # Generate Go code using the toolchain
    weaver_generate(
        name = "generated_go",
        srcs = [":sample_schema"],
        format = "go",
        args = ["--verbose", "--output-dir", "generated"],
    )

def create_validation_example():
    """Create an example of schema validation using the toolchain."""
    
    # Create schema
    create_sample_schema()
    
    # Create a sample policy
    native.genrule(
        name = "sample_policy",
        outs = ["policy.yaml"],
        cmd = """
        cat > $@ << 'EOF'
        name: SamplePolicy
        version: 1.0.0
        rules:
          - name: requireDescription
            description: All services must have a description
            condition: description != null
        EOF
        """,
    )
    
    # Validate schema against policy
    weaver_validate(
        name = "validate_schema",
        schemas = [":sample_schema"],
        policies = [":sample_policy"],
        args = ["--strict"],
    )

def create_cross_platform_example():
    """Create an example demonstrating cross-platform toolchain usage."""
    
    # Create platform-specific toolchains
    create_weaver_toolchains()
    
    # Create a schema
    create_sample_schema()
    
    # Generate code for different platforms
    weaver_generate(
        name = "linux_generated",
        srcs = [":sample_schema"],
        format = "typescript",
        args = ["--platform", "linux-x86_64"],
    )
    
    weaver_generate(
        name = "darwin_generated",
        srcs = [":sample_schema"],
        format = "typescript",
        args = ["--platform", "darwin-x86_64"],
    )

def create_custom_toolchain_example():
    """Create an example of a custom toolchain configuration."""
    
    # Create a custom Weaver binary with specific configuration
    native.genrule(
        name = "custom_weaver",
        outs = ["weaver_custom"],
        cmd = """
        echo '#!/bin/bash' > $@
        echo 'echo "Custom Weaver binary with enhanced features"' >> $@
        echo 'echo "Version: 0.2.0"' >> $@
        echo 'echo "Features: validation, generation, linting"' >> $@
        echo 'echo "Processing: $@"' >> $@
        chmod +x $@
        """,
    )
    
    # Create custom toolchain
    weaver_toolchain(
        name = "custom_weaver_toolchain",
        weaver_binary = ":custom_weaver",
        version = "0.2.0",
        platform = "linux-x86_64",
    )
    
    # Create schema
    create_sample_schema()
    
    # Use custom toolchain for generation
    weaver_generate(
        name = "custom_generated",
        srcs = [":sample_schema"],
        format = "typescript",
        args = ["--custom-features"],
    )

def create_multi_version_example():
    """Create an example with multiple Weaver versions."""
    
    # Create Weaver binary for version 0.1.0
    native.genrule(
        name = "weaver_v1",
        outs = ["weaver_0.1.0"],
        cmd = """
        echo '#!/bin/bash' > $@
        echo 'echo "Weaver version 0.1.0"' >> $@
        chmod +x $@
        """,
    )
    
    # Create Weaver binary for version 0.2.0
    native.genrule(
        name = "weaver_v2",
        outs = ["weaver_0.2.0"],
        cmd = """
        echo '#!/bin/bash' > $@
        echo 'echo "Weaver version 0.2.0"' >> $@
        chmod +x $@
        """,
    )
    
    # Create toolchains for different versions
    weaver_toolchain(
        name = "weaver_toolchain_v1",
        weaver_binary = ":weaver_v1",
        version = "0.1.0",
        platform = "linux-x86_64",
    )
    
    weaver_toolchain(
        name = "weaver_toolchain_v2",
        weaver_binary = ":weaver_v2",
        version = "0.2.0",
        platform = "linux-x86_64",
    )
    
    # Create schema
    create_sample_schema()
    
    # Generate code with different versions
    weaver_generate(
        name = "generated_v1",
        srcs = [":sample_schema"],
        format = "typescript",
        args = ["--version", "0.1.0"],
    )
    
    weaver_generate(
        name = "generated_v2",
        srcs = [":sample_schema"],
        format = "typescript",
        args = ["--version", "0.2.0"],
    )

# Example usage functions
def setup_weaver_examples():
    """Set up all Weaver toolchain examples."""
    
    # Create basic toolchains
    create_weaver_toolchains()
    
    # Create sample schema
    create_sample_schema()
    
    # Create generation examples
    create_generation_example()
    
    # Create validation examples
    create_validation_example()
    
    # Create cross-platform examples
    create_cross_platform_example()
    
    # Create custom toolchain examples
    create_custom_toolchain_example()
    
    # Create multi-version examples
    create_multi_version_example() 