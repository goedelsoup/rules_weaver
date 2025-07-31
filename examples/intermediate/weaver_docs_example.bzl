"""
Example usage of weaver_docs rule.

This example demonstrates how to use the weaver_docs rule to generate
documentation from OpenTelemetry Weaver schemas.
"""

load("//weaver:defs.bzl", "weaver_docs", "weaver_schema", "weaver_generate", "weaver_validate")

def weaver_docs_example():
    """Example of weaver_docs rule usage."""
    
    # 1. Basic documentation generation
    weaver_docs(
        name = "basic_docs",
        schemas = ["schema.yaml"],
        format = "html",
    )
    
    # 2. Documentation with custom template
    weaver_docs(
        name = "custom_template_docs",
        schemas = ["schema.yaml"],
        format = "html",
        template = "//weaver/templates:default.html.template",
    )
    
    # 3. Markdown documentation
    weaver_docs(
        name = "markdown_docs",
        schemas = ["schema.yaml"],
        format = "markdown",
    )
    
    # 4. PDF documentation
    weaver_docs(
        name = "pdf_docs",
        schemas = ["schema.yaml"],
        format = "pdf",
    )
    
    # 5. Documentation with custom output directory
    weaver_docs(
        name = "custom_output_docs",
        schemas = ["schema.yaml"],
        format = "html",
        output_dir = "custom_docs",
    )
    
    # 6. Documentation with additional arguments
    weaver_docs(
        name = "verbose_docs",
        schemas = ["schema.yaml"],
        format = "html",
        args = ["--verbose", "--no-cache"],
        env = {"WEAVER_DEBUG": "1"},
    )
    
    # 7. Documentation for multiple schemas
    weaver_docs(
        name = "multiple_schemas_docs",
        schemas = ["schema1.yaml", "schema2.yaml", "schema3.json"],
        format = "html",
    )
    
    # 8. Documentation with schema dependencies
    weaver_schema(
        name = "my_schemas",
        srcs = ["schema.yaml"],
    )
    
    weaver_docs(
        name = "schema_deps_docs",
        schemas = [":my_schemas"],
        format = "html",
    )

def weaver_docs_advanced_example():
    """Advanced example of weaver_docs rule usage."""
    
    # 1. Documentation with performance monitoring
    weaver_docs(
        name = "performance_docs",
        schemas = ["large_schema.yaml"],
        format = "html",
        args = ["--parallel", "4"],
        env = {
            "WEAVER_CACHE_ENABLED": "1",
            "WEAVER_MEMORY_LIMIT": "4g",
        },
    )
    
    # 2. Documentation with custom theme
    weaver_docs(
        name = "dark_theme_docs",
        schemas = ["schema.yaml"],
        format = "html",
        env = {"WEAVER_DOCS_THEME": "dark"},
    )
    
    # 3. Documentation with navigation
    weaver_docs(
        name = "nav_docs",
        schemas = ["schema.yaml"],
        format = "html",
        env = {"WEAVER_DOCS_NAVIGATION": "1"},
    )
    
    # 4. Documentation with search functionality
    weaver_docs(
        name = "search_docs",
        schemas = ["schema.yaml"],
        format = "html",
        args = ["--enable-search"],
    )
    
    # 5. Documentation with custom CSS
    weaver_docs(
        name = "custom_css_docs",
        schemas = ["schema.yaml"],
        format = "html",
        args = ["--css-file", "custom.css"],
    )
    
    # 6. Documentation with examples
    weaver_docs(
        name = "examples_docs",
        schemas = ["schema.yaml"],
        format = "html",
        args = ["--include-examples"],
    )
    
    # 7. Documentation with API reference
    weaver_docs(
        name = "api_docs",
        schemas = ["schema.yaml"],
        format = "html",
        args = ["--include-api-ref"],
    )
    
    # 8. Documentation with validation results
    weaver_docs(
        name = "validation_docs",
        schemas = ["schema.yaml"],
        format = "html",
        args = ["--include-validation"],
    )

def weaver_docs_workflow_example():
    """Example of weaver_docs in a complete workflow."""
    
    # 1. Define schemas
    weaver_schema(
        name = "api_schemas",
        srcs = [
            "user_schema.yaml",
            "product_schema.yaml",
            "order_schema.yaml",
        ],
    )
    
    # 2. Generate code from schemas
    weaver_generate(
        name = "api_generated",
        srcs = [":api_schemas"],
        format = "typescript",
    )
    
    # 3. Validate schemas
    weaver_validate(
        name = "api_validation",
        schemas = [":api_schemas"],
        policies = ["api_policy.yaml"],
    )
    
    # 4. Generate documentation
    weaver_docs(
        name = "api_documentation",
        schemas = [":api_schemas"],
        format = "html",
        args = ["--verbose"],
    )
    
    # 5. Generate multiple documentation formats
    weaver_docs(
        name = "api_docs_html",
        schemas = [":api_schemas"],
        format = "html",
    )
    
    weaver_docs(
        name = "api_docs_markdown",
        schemas = [":api_schemas"],
        format = "markdown",
    )
    
    weaver_docs(
        name = "api_docs_pdf",
        schemas = [":api_schemas"],
        format = "pdf",
    ) 