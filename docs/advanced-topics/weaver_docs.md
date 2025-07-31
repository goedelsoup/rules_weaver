# weaver_docs

The `weaver_docs` rule generates documentation from OpenTelemetry Weaver schemas.

## Overview

The `weaver_docs` rule creates a hermetic action that generates documentation from schema files using the Weaver tool. The generated documentation is made available through the `WeaverDocsInfo` provider and supports multiple output formats including HTML, Markdown, and PDF.

## Basic Usage

```python
load("//weaver:defs.bzl", "weaver_docs")

weaver_docs(
    name = "my_documentation",
    schemas = ["schema.yaml"],
    format = "html",
)
```

## Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `name` | string | required | Target name |
| `schemas` | label_list | required | Schema files or schema targets to document |
| `format` | string | "html" | Documentation format (options: html, markdown, pdf) |
| `template` | label | None | Custom documentation template file (optional) |
| `output_dir` | string | "{name}_docs" | Output directory (optional) |
| `weaver` | label | None | Weaver binary (optional, defaults to toolchain) |
| `args` | string_list | [] | Additional Weaver documentation arguments |
| `env` | string_dict | {} | Environment variables for the documentation action |

## Parameters

### name (required)
The name of the target. This will be used to generate the output directory if not specified.

### schemas (required)
A list of schema files or schema targets to document. Can be:
- Direct file references: `["schema.yaml", "config.json"]`
- Schema targets: `[":my_schemas"]`
- Mixed: `["schema.yaml", ":other_schemas"]`

### format (optional)
The documentation format to generate. Supported formats:
- `"html"` - HTML documentation with navigation and styling
- `"markdown"` - Markdown documentation for version control
- `"pdf"` - PDF documentation for distribution

Default: `"html"`

### template (optional)
A custom documentation template file to use instead of the default templates. The template should be compatible with the Weaver documentation system.

### output_dir (optional)
The output directory for generated documentation. If not specified, defaults to `{name}_docs`.

### weaver (optional)
The Weaver binary to use for documentation generation. If not specified, uses the toolchain's Weaver binary.

### args (optional)
Additional arguments to pass to the Weaver documentation command. Common arguments:
- `--verbose` - Enable verbose output
- `--no-cache` - Disable caching
- `--parallel N` - Enable parallel processing with N workers
- `--enable-search` - Enable search functionality in HTML docs
- `--include-examples` - Include example code in documentation
- `--include-api-ref` - Include API reference in documentation

### env (optional)
Environment variables to set for the documentation generation action. Common variables:
- `WEAVER_DEBUG=1` - Enable debug mode
- `WEAVER_DOCS_THEME=dark` - Use dark theme for HTML docs
- `WEAVER_DOCS_NAVIGATION=1` - Enable navigation in HTML docs
- `WEAVER_CACHE_ENABLED=1` - Enable caching
- `WEAVER_MEMORY_LIMIT=4g` - Set memory limit

## Examples

### Basic Documentation Generation

```python
weaver_docs(
    name = "api_docs",
    schemas = ["api_schema.yaml"],
    format = "html",
)
```

### Multiple Schema Documentation

```python
weaver_docs(
    name = "complete_docs",
    schemas = [
        "user_schema.yaml",
        "product_schema.yaml",
        "order_schema.yaml",
    ],
    format = "html",
)
```

### Custom Template Documentation

```python
weaver_docs(
    name = "custom_docs",
    schemas = ["schema.yaml"],
    format = "html",
    template = "//weaver/templates:custom.html.template",
)
```

### Markdown Documentation

```python
weaver_docs(
    name = "markdown_docs",
    schemas = ["schema.yaml"],
    format = "markdown",
)
```

### PDF Documentation

```python
weaver_docs(
    name = "pdf_docs",
    schemas = ["schema.yaml"],
    format = "pdf",
)
```

### Custom Output Directory

```python
weaver_docs(
    name = "docs",
    schemas = ["schema.yaml"],
    format = "html",
    output_dir = "documentation",
)
```

### Documentation with Arguments

```python
weaver_docs(
    name = "verbose_docs",
    schemas = ["schema.yaml"],
    format = "html",
    args = ["--verbose", "--no-cache"],
    env = {"WEAVER_DEBUG": "1"},
)
```

### Schema Target Documentation

```python
weaver_schema(
    name = "my_schemas",
    srcs = ["schema.yaml"],
)

weaver_docs(
    name = "schema_docs",
    schemas = [":my_schemas"],
    format = "html",
)
```

## Output Structure

The generated documentation follows a structured output format:

### HTML Documentation
```
{output_dir}/
├── {schema_name}/
│   ├── index.html
│   ├── assets/
│   │   ├── style.css
│   │   └── script.js
│   └── ...
└── ...
```

### Markdown Documentation
```
{output_dir}/
├── {schema_name}/
│   └── {schema_name}.md
└── ...
```

### PDF Documentation
```
{output_dir}/
├── {schema_name}/
│   └── {schema_name}.pdf
└── ...
```

## Templates

The `weaver_docs` rule includes default templates for HTML and Markdown documentation:

### Default HTML Template
Located at `//weaver/templates:default.html.template`, this template provides:
- Modern, responsive design
- Navigation and table of contents
- Schema information display
- Code highlighting
- Search functionality (when enabled)

### Default Markdown Template
Located at `//weaver/templates:default.md.template`, this template provides:
- Clean, readable Markdown output
- Schema information table
- Code blocks with syntax highlighting
- Dependency listing
- Example sections

### Custom Templates
You can create custom templates by:
1. Creating a template file with the appropriate format
2. Referencing it in the `template` attribute
3. Ensuring compatibility with Weaver's template system

## Integration with Other Rules

The `weaver_docs` rule integrates well with other Weaver rules:

### Complete Workflow Example

```python
# 1. Define schemas
weaver_schema(
    name = "api_schemas",
    srcs = ["api_schema.yaml"],
)

# 2. Generate code
weaver_generate(
    name = "api_generated",
    srcs = [":api_schemas"],
    format = "typescript",
)

# 3. Validate schemas
weaver_validate(
    name = "api_validation",
    schemas = [":api_schemas"],
)

# 4. Generate documentation
weaver_docs(
    name = "api_documentation",
    schemas = [":api_schemas"],
    format = "html",
)
```

## Performance Considerations

The `weaver_docs` rule includes several performance optimizations:

### Caching
- Documentation generation results are cached based on input schemas and arguments
- Cache keys are optimized for better hit rates
- Cache can be disabled with `--no-cache` argument

### Parallel Processing
- Documentation generation supports parallel processing
- Use `--parallel N` argument to specify number of workers
- Default is single-threaded for consistency

### Memory Management
- Memory limits can be configured via environment variables
- Default memory limit is 2GB
- Large schemas may require increased memory limits

### Remote Execution
- Fully compatible with Bazel remote execution
- Optimized for distributed builds
- Minimal network transfer requirements

## Troubleshooting

### Common Issues

1. **Template not found**: Ensure the template file exists and is properly referenced
2. **Format not supported**: Check that the format is one of: html, markdown, pdf
3. **Memory issues**: Increase `WEAVER_MEMORY_LIMIT` for large schemas
4. **Performance issues**: Enable parallel processing with `--parallel N`

### Debug Mode

Enable debug mode to get more detailed information:

```python
weaver_docs(
    name = "debug_docs",
    schemas = ["schema.yaml"],
    format = "html",
    args = ["--verbose"],
    env = {"WEAVER_DEBUG": "1"},
)
```

### Validation

The `weaver_docs` rule validates inputs before processing:
- Schema files must exist and be readable
- Template files must be valid
- Format must be supported
- Arguments must be valid

## Provider Information

The `weaver_docs` rule provides the `WeaverDocsInfo` provider with the following fields:

- `documentation_files`: List of generated documentation file artifacts
- `output_dir`: Output directory path
- `source_schemas`: Source schema targets
- `documentation_format`: Format of generated documentation
- `template_used`: Template file used for generation (if any)
- `generation_args`: Arguments used for documentation generation

## See Also

- [weaver_schema](weaver_schema.md) - Schema declaration rule
- [weaver_generate](weaver_generate.md) - Code generation rule
- [weaver_validate](weaver_validate.md) - Schema validation rule
- [weaver_library](weaver_library.md) - Convenience macro for complete workflows 