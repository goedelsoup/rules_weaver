# Contributing Guide

Thank you for your interest in contributing to the Bazel OpenTelemetry Weaver rules! This guide will help you get started with contributing to the project.

## Table of Contents

- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Code Style](#code-style)
- [Testing](#testing)
- [Submitting Changes](#submitting-changes)
- [Issue Reporting](#issue-reporting)
- [Documentation](#documentation)
- [Release Process](#release-process)

## Getting Started

### Prerequisites

Before contributing, ensure you have:

- **Bazel 5.0+** installed
- **Python 3.7+** for some development tools
- **Git** for version control
- **GitHub account** for submitting pull requests

### Fork and Clone

1. **Fork the repository** on GitHub
2. **Clone your fork**:
   ```bash
   git clone https://github.com/your-username/rules_weaver.git
   cd rules_weaver
   ```
3. **Add upstream remote**:
   ```bash
   git remote add upstream https://github.com/open-telemetry/weaver.git
   ```

### Development Branch

Create a feature branch for your changes:

```bash
git checkout -b feature/your-feature-name
```

## Development Setup

### Local Development Environment

1. **Set up the development environment**:
   ```bash
   # Install development dependencies
   pip install -r requirements-dev.txt
   
   # Set up pre-commit hooks
   pre-commit install
   ```

2. **Verify the setup**:
   ```bash
   # Run tests
   bazel test //...
   
   # Run linting
   bazel run //:lint
   
   # Run formatting
   bazel run //:format
   ```

### Project Structure

```
rules_weaver/
├── weaver/                    # Main rule implementations
│   ├── defs.bzl              # Rule definitions
│   ├── repositories.bzl      # Repository rules
│   ├── toolchains.bzl        # Toolchain rules
│   ├── providers.bzl         # Provider definitions
│   └── internal/             # Internal implementation
├── tests/                    # Test files
│   ├── *_test.bzl           # Unit tests
│   └── schemas/              # Test schemas
├── examples/                 # Usage examples
├── docs/                     # Documentation
└── WORKSPACE                 # Workspace configuration
```

### Development Workflow

1. **Make your changes** in the appropriate files
2. **Add tests** for new functionality
3. **Update documentation** if needed
4. **Run tests** to ensure everything works
5. **Commit your changes** with a descriptive message

## Code Style

### Bazel Starlark Style

Follow the [Bazel Starlark Style Guide](https://bazel.build/rules/style):

```python
# Good: Clear function names and documentation
def _weaver_generate_impl(ctx):
    """Implementation of the weaver_generate rule."""
    
    # Validate inputs
    if not ctx.attr.srcs:
        fail("srcs attribute is required")
    
    # Process schemas
    schemas = []
    for src in ctx.attr.srcs:
        if hasattr(src, "files"):
            schemas.extend(src.files.to_list())
        else:
            schemas.append(src)
    
    # Return providers
    return [
        WeaverGeneratedInfo(
            generated_files = generated_files,
            output_dir = output_dir,
            source_schemas = schemas,
            generation_args = args,
        ),
        DefaultInfo(files = depset(generated_files)),
    ]

# Good: Clear rule definition
weaver_generate = rule(
    implementation = _weaver_generate_impl,
    attrs = {
        "srcs": attr.label_list(
            mandatory = True,
            allow_files = True,
            doc = "Schema source files or schema targets",
        ),
        "format": attr.string(
            default = "typescript",
            doc = "Output format (default: typescript)",
        ),
    },
    toolchains = ["@rules_weaver//weaver:toolchain_type"],
    doc = """
Generates code from schemas using OpenTelemetry Weaver.

Example:
    weaver_generate(
        name = "my_generated_code",
        srcs = ["schema.yaml"],
        format = "typescript",
    )
""",
)
```

### Python Style (for tools and tests)

Follow [PEP 8](https://www.python.org/dev/peps/pep-0008/) for Python code:

```python
# Good: Clear imports and function definitions
import json
from typing import List, Dict, Any

def validate_schema(schema_content: str) -> Dict[str, Any]:
    """Validate schema content and return validation results.
    
    Args:
        schema_content: The schema content to validate
        
    Returns:
        Dictionary containing validation results
        
    Raises:
        ValueError: If schema is invalid
    """
    try:
        schema_data = json.loads(schema_content)
        return {"valid": True, "data": schema_data}
    except json.JSONDecodeError as e:
        raise ValueError(f"Invalid JSON schema: {e}")
```

### Documentation Style

Follow these documentation guidelines:

1. **Use clear, concise language**
2. **Include examples** for all features
3. **Document all parameters** and return values
4. **Use consistent formatting**

```markdown
# Rule Name

Brief description of what the rule does.

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `name` | string | ✅ | - | Target name |
| `srcs` | list | ✅ | - | Source files |

## Example

```python
rule_name(
    name = "my_target",
    srcs = ["file.yaml"],
)
```

## See Also

- [Related Rule](related_rule.md)
- [Examples](examples/)
```

## Testing

### Writing Tests

Create tests for all new functionality:

```python
# tests/my_rule_test.bzl
load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("//weaver:defs.bzl", "my_rule")

def _my_rule_test_impl(ctx):
    env = unittest.begin(ctx)
    
    # Test your rule
    target = ctx.attr.target
    asserts.equals(env, "expected_value", target.some_field)
    
    return unittest.end(env)

my_rule_test = unittest.make(_my_rule_test_impl, attrs = {
    "target": attr.label(),
})

def my_rule_test_suite(name):
    unittest.suite(
        name,
        my_rule_test,
        target = "//path/to:test_target",
    )
```

### Running Tests

```bash
# Run all tests
bazel test //...

# Run specific test
bazel test //tests:my_rule_test

# Run tests with verbose output
bazel test //tests:my_rule_test --test_output=all
```

### Test Coverage

Ensure your tests cover:

- **Happy path** scenarios
- **Error conditions**
- **Edge cases**
- **Different input types**

### Integration Tests

Create integration tests for complex workflows:

```python
# tests/integration_test.bzl
def _integration_test_impl(ctx):
    # Test complete workflow
    # Generate code from schemas
    # Validate generated code
    # Check integration with other rules
    pass

integration_test = rule(
    implementation = _integration_test_impl,
    test = True,
)
```

## Submitting Changes

### Commit Messages

Follow the [Conventional Commits](https://www.conventionalcommits.org/) format:

```
feat: add support for custom output formats

- Add format parameter to weaver_generate rule
- Support for go, python, java, rust formats
- Update documentation with format examples

Closes #123
```

Commit types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Test changes
- `chore`: Maintenance tasks

### Pull Request Process

1. **Create a pull request** from your feature branch
2. **Fill out the PR template** completely
3. **Ensure all tests pass**
4. **Update documentation** if needed
5. **Request review** from maintainers

### PR Template

```markdown
## Description

Brief description of the changes.

## Type of Change

- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Testing

- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Checklist

- [ ] Code follows the style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] Tests added/updated
- [ ] All tests pass

## Related Issues

Closes #123
```

## Issue Reporting

### Bug Reports

When reporting bugs, include:

1. **Environment details**:
   - Bazel version: `bazel --version`
   - Platform: `uname -s -m`
   - Weaver version

2. **Reproduction steps**:
   - Minimal WORKSPACE configuration
   - Minimal BUILD file
   - Schema files (if applicable)

3. **Expected vs actual behavior**:
   - What you expected to happen
   - What actually happened

4. **Error messages**:
   - Complete error output
   - Stack traces if available

### Feature Requests

When requesting features, include:

1. **Use case description**:
   - What problem you're trying to solve
   - Current workarounds

2. **Proposed solution**:
   - How you'd like the feature to work
   - Example usage

3. **Impact assessment**:
   - Who would benefit
   - Priority level

## Documentation

### Documentation Standards

1. **Keep documentation up to date** with code changes
2. **Include examples** for all features
3. **Use clear, concise language**
4. **Follow the established format**

### Documentation Structure

```
docs/
├── README.md              # Main documentation index
├── installation.md        # Installation guide
├── quick_start.md         # Quick start guide
├── api_reference.md       # Complete API documentation
├── examples/              # Usage examples
│   ├── basic_usage.md     # Basic examples
│   ├── advanced_usage.md  # Advanced examples
│   └── integrations.md    # Integration examples
├── migration_guide.md     # Migration guide
├── troubleshooting.md     # Troubleshooting guide
├── faq.md                # Frequently asked questions
└── contributing.md       # This file
```

### Writing Documentation

1. **Start with the user's goal**
2. **Provide step-by-step instructions**
3. **Include complete examples**
4. **Anticipate common questions**

## Release Process

### Versioning

Follow [Semantic Versioning](https://semver.org/):

- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

### Release Checklist

Before releasing:

- [ ] All tests pass
- [ ] Documentation is up to date
- [ ] CHANGELOG is updated
- [ ] Version is updated in all relevant files
- [ ] Release notes are prepared

### Creating a Release

1. **Update version** in relevant files
2. **Update CHANGELOG** with new features/fixes
3. **Create release branch**:
   ```bash
   git checkout -b release/v1.2.0
   ```
4. **Tag the release**:
   ```bash
   git tag -a v1.2.0 -m "Release v1.2.0"
   git push origin v1.2.0
   ```
5. **Create GitHub release** with release notes

## Community Guidelines

### Code of Conduct

We follow the [OpenTelemetry Code of Conduct](https://github.com/open-telemetry/community/blob/main/code-of-conduct.md).

### Communication

- **Be respectful** and inclusive
- **Ask questions** when unsure
- **Help others** when you can
- **Provide constructive feedback**

### Getting Help

- **GitHub Issues**: For bugs and feature requests
- **GitHub Discussions**: For questions and general discussion
- **Documentation**: For usage questions
- **Slack**: For real-time discussion (if available)

## Recognition

Contributors are recognized in:

- **GitHub contributors** page
- **CHANGELOG** for significant contributions
- **Release notes** for major features
- **Documentation** for examples and guides

## Questions?

If you have questions about contributing:

1. Check the [FAQ](faq.md)
2. Search existing [GitHub Issues](https://github.com/open-telemetry/weaver/issues)
3. Start a [GitHub Discussion](https://github.com/open-telemetry/weaver/discussions)
4. Contact the maintainers

Thank you for contributing to the Bazel OpenTelemetry Weaver rules! 🎉 