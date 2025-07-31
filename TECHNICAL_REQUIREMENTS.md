# Bazel OpenTelemetry Weaver Rules - Technical Requirements Document

## Overview

This document provides detailed technical specifications for implementing Bazel rules that integrate OpenTelemetry Weaver into Bazel workspaces. The implementation will provide hermetic, scalable telemetry schema management and code generation for enterprise Bazel environments.

## Architecture Overview

### Core Components

1. **Repository Rules**: Manage Weaver binary distribution and toolchain registration
2. **Core Rules**: Schema declaration, code generation, and validation
3. **Macros**: High-level convenience functions for common patterns
4. **Providers**: Data structures for rule communication
5. **Aspects**: Optional automatic target discovery

### File Structure
```
rules_weaver/
├── weaver/
│   ├── defs.bzl          # Main rule definitions and macros
│   ├── repositories.bzl  # Repository and toolchain rules
│   ├── workspace.bzl     # Workspace configuration
│   ├── providers.bzl     # Custom providers
│   ├── aspects.bzl       # Aspects for target discovery
│   └── internal/
│       ├── utils.bzl     # Internal utilities
│       ├── actions.bzl   # Action implementations
│       └── validation.bzl # Validation logic
├── examples/             # Usage examples
├── tests/               # Rule tests
└── docs/                # Documentation
```

## Technical Specifications

### 1. Repository Rules

#### `weaver_repository` Rule

**Purpose**: Download and register Weaver binaries for hermetic builds

**Implementation**:
```python
def _weaver_repository_impl(repository_ctx):
    # Download binary based on platform
    # Verify SHA256 integrity
    # Create BUILD file with binary target
    # Register toolchain
```

**Parameters**:
- `name`: Repository name (required)
- `version`: Weaver version (required)
- `sha256`: Binary integrity hash (optional, recommended)
- `urls`: Custom download URLs (optional)
- `platform_overrides`: Platform-specific settings (optional)

**Platform Support**:
- Linux: `x86_64`, `aarch64`
- macOS: `x86_64`, `aarch64`
- Windows: `x86_64`

#### `weaver_toolchain` Rule

**Purpose**: Register Weaver as a Bazel toolchain

**Implementation**:
```python
def _weaver_toolchain_impl(ctx):
    return [platform_common.ToolchainInfo(
        weaver_binary = ctx.file.weaver_binary,
        version = ctx.attr.version,
    )]
```

### 2. Core Rules

#### `weaver_schema` Rule

**Purpose**: Declare schema files as Bazel targets

**Provider**: `WeaverSchemaInfo`
```python
WeaverSchemaInfo = provider(
    fields = {
        "schema_files": "List of schema file artifacts",
        "schema_content": "Parsed schema content for validation",
        "dependencies": "Transitive schema dependencies",
    },
)
```

**Implementation**:
```python
def _weaver_schema_impl(ctx):
    # Validate schema files at analysis time
    # Parse schema content for dependency tracking
    # Return WeaverSchemaInfo provider
```

#### `weaver_generate` Rule

**Purpose**: Generate code from schemas using Weaver

**Provider**: `WeaverGeneratedInfo`
```python
WeaverGeneratedInfo = provider(
    fields = {
        "generated_files": "List of generated file artifacts",
        "output_dir": "Output directory path",
        "source_schemas": "Source schema targets",
    },
)
```

**Implementation**:
```python
def _weaver_generate_impl(ctx):
    # Create hermetic action with all inputs declared
    # Execute Weaver with proper arguments
    # Return generated files and metadata
```

**Action Design**:
```python
def _generate_action(ctx, schemas, args, output_dir):
    ctx.actions.run(
        inputs = schemas + [ctx.file.weaver_binary],
        outputs = generated_files,
        executable = ctx.file.weaver_binary,
        arguments = args,
        env = ctx.attr.env,
        use_default_shell_env = False,
        mnemonic = "WeaverGenerate",
        progress_message = "Generating code from schemas",
    )
```

#### `weaver_validate` Rule

**Purpose**: Validate schemas and policies

**Implementation**:
```python
def _weaver_validate_impl(ctx):
    # Create validation action
    # Handle validation failures based on configuration
    # Return test results or build failures
```

### 3. Macros

#### `weaver_library` Macro

**Purpose**: Convenience macro combining schema declaration and generation

**Implementation**:
```python
def weaver_library(name, srcs, **kwargs):
    # Create weaver_schema target
    # Create weaver_generate target
    # Create optional validation target
    # Return generated target reference
```

#### `weaver_test` Macro

**Purpose**: Integration with Bazel testing for schema validation

**Implementation**:
```python
def weaver_test(name, schemas, **kwargs):
    # Create weaver_validate target
    # Wrap in test_suite if multiple validations
    # Return test target reference
```

### 4. Providers

#### `WeaverSchemaInfo`
```python
WeaverSchemaInfo = provider(
    doc = "Information about Weaver schema files",
    fields = {
        "schema_files": "List of schema file artifacts",
        "schema_content": "Parsed schema content for validation",
        "dependencies": "Transitive schema dependencies",
        "metadata": "Additional schema metadata",
    },
)
```

#### `WeaverGeneratedInfo`
```python
WeaverGeneratedInfo = provider(
    doc = "Information about Weaver-generated files",
    fields = {
        "generated_files": "List of generated file artifacts",
        "output_dir": "Output directory path",
        "source_schemas": "Source schema targets",
        "generation_args": "Arguments used for generation",
    },
)
```

#### `WeaverToolchainInfo`
```python
WeaverToolchainInfo = provider(
    doc = "Information about Weaver toolchain",
    fields = {
        "weaver_binary": "Weaver executable artifact",
        "version": "Weaver version",
        "platform": "Target platform",
    },
)
```

### 5. Configuration System

#### Workspace Configuration
```python
def weaver_workspace(
    default_args = {},
    default_environment = {},
    default_policies = [],
    validation_mode = "strict",
):
    # Set workspace-wide defaults
    # Configure validation behavior
    # Set up common environment variables
```

#### Target Configuration
```python
def weaver_generate(
    name,
    srcs,
    weaver_args = [],
    env = {},
    out_dir = None,
    format = "typescript",
    visibility = None,
):
    # Apply workspace defaults
    # Override with target-specific settings
    # Validate configuration
```

### 6. Action Implementation Details

#### Hermetic Action Requirements
- All inputs must be declared in `inputs` parameter
- All outputs must be declared in `outputs` parameter
- No hidden file system dependencies
- Environment variables must be explicitly declared
- Use `use_default_shell_env = False` for hermeticity

#### Remote Execution Compatibility
- Actions must work in sandboxed environments
- Input/output handling optimized for network transfer
- Platform constraints properly declared
- Progress reporting for long-running operations

#### Caching Strategy
- Action cache keys based on all inputs and arguments
- Efficient change detection for schema files
- Incremental validation and generation
- Proper dependency tracking for transitive changes

### 7. Error Handling and Reporting

#### Validation Errors
```python
def _handle_validation_error(ctx, error_output):
    if ctx.attr.fail_on_error:
        fail("Schema validation failed: " + error_output)
    else:
        # Create test failure result
        return _create_test_result(ctx, False, error_output)
```

#### Generation Errors
```python
def _handle_generation_error(ctx, error_output):
    fail("Code generation failed: " + error_output)
```

#### Analysis Time Errors
```python
def _validate_schema_at_analysis(ctx, schema_file):
    # Basic schema validation at analysis time
    # Fail fast for obvious errors
    # Defer complex validation to execution time
```

### 8. Performance Optimizations

#### Analysis Time Optimizations
- Minimal file I/O during analysis
- Efficient provider creation
- Lazy evaluation where possible
- Proper dependency graph construction

#### Execution Time Optimizations
- Parallel execution of independent operations
- Efficient input/output handling
- Proper action caching
- Incremental rebuild strategies

#### Memory Optimizations
- Streaming file processing for large schemas
- Efficient data structures for dependency tracking
- Minimal object creation during analysis

### 9. Testing Strategy

#### Unit Tests
- Provider creation and manipulation
- Action argument construction
- Configuration validation
- Error handling scenarios

#### Integration Tests
- End-to-end rule execution
- Dependency tracking verification
- Caching behavior validation
- Remote execution compatibility

#### Performance Tests
- Large schema set handling
- Incremental build performance
- Memory usage profiling
- Cache hit rate measurement

### 10. Platform Support

#### Binary Distribution
- Automatic platform detection
- Multiple download sources
- Integrity verification
- Fallback mechanisms

#### Cross-Platform Compatibility
- Path handling for different OS
- Environment variable differences
- Shell command variations
- File permission handling

### 11. Security Considerations

#### Binary Integrity
- SHA256 verification for all downloads
- Multiple download sources
- Tamper detection
- Secure download protocols

#### Sandbox Compatibility
- No network access during execution
- Proper file system isolation
- Environment variable sanitization
- Process isolation

### 12. Monitoring and Observability

#### Build Metrics
- Action execution time tracking
- Cache hit rate monitoring
- Memory usage profiling
- Error rate tracking

#### Debugging Support
- Detailed error messages
- Action argument logging
- Input/output file listing
- Environment variable inspection

## Implementation Phases

### Phase 1: Core Infrastructure (Weeks 1-4)

#### Week 1: Repository Rules
- Implement `weaver_repository` rule
- Implement `weaver_toolchain` rule
- Add platform detection and binary download
- Create basic tests

#### Week 2: Schema Rule
- Implement `weaver_schema` rule
- Create `WeaverSchemaInfo` provider
- Add basic schema validation
- Implement dependency tracking

#### Week 3: Generation Rule
- Implement `weaver_generate` rule
- Create `WeaverGeneratedInfo` provider
- Add hermetic action implementation
- Support TypeScript output

#### Week 4: Basic Integration
- Create `weaver_library` macro
- Add workspace configuration
- Implement basic error handling
- Create integration tests

### Phase 2: Validation and Testing (Weeks 5-6)

#### Week 5: Validation Rule
- Implement `weaver_validate` rule
- Add policy enforcement
- Create test integration
- Implement failure modes

#### Week 6: Testing Framework
- Add comprehensive unit tests
- Create integration test suite
- Implement performance benchmarks
- Add error scenario testing

### Phase 3: Advanced Features (Weeks 7-9)

#### Week 7: Configuration System
- Implement workspace defaults
- Add target-level overrides
- Create configuration validation
- Add environment management

#### Week 8: Dependency Optimization
- Implement transitive dependency tracking
- Add change detection optimization
- Create file group support
- Optimize incremental builds

#### Week 9: Documentation Generation
- Add `weaver_docs` rule
- Implement documentation templates
- Create output organization
- Add documentation testing

### Phase 4: Enterprise Features (Weeks 10-12)

#### Week 10: Remote Execution
- Test remote execution compatibility
- Optimize for network transfer
- Add platform constraint handling
- Implement progress reporting

#### Week 11: Performance Optimization
- Profile and optimize analysis time
- Improve action caching
- Optimize memory usage
- Add performance monitoring

#### Week 12: Multi-Platform Support
- Test cross-platform compatibility
- Add Windows support
- Implement ARM64 support
- Create platform-specific tests

### Phase 5: Documentation and Release (Weeks 13-14)

#### Week 13: Documentation
- Create comprehensive API documentation
- Add usage examples
- Create migration guides
- Write troubleshooting guides

#### Week 14: Release Preparation
- Final testing and validation
- Performance benchmarking
- Security review
- Release packaging

## Success Metrics

### Technical Metrics
- Analysis time: <100ms for typical BUILD files
- Action execution time: <5s for unchanged schemas
- Cache hit rate: >90% for repeated builds
- Memory usage: <50MB for large schema sets

### Quality Metrics
- Test coverage: >90%
- Documentation coverage: 100%
- Error message clarity: User feedback score >4/5
- Integration ease: Migration time <1 hour per project

### Performance Metrics
- Remote execution compatibility: 100%
- Incremental build performance: <1s for unchanged schemas
- Large workspace support: 1000+ schema files
- Multi-platform compatibility: Linux, macOS, Windows

## Risk Mitigation

### Technical Risks
- **Bazel version compatibility**: Support multiple LTS versions
- **Remote execution complexity**: Comprehensive testing strategy
- **Performance impact**: Continuous profiling and optimization

### Implementation Risks
- **Scope creep**: Strict phase-based development
- **Quality issues**: Comprehensive testing and review process
- **Integration complexity**: Follow established Bazel patterns

### Operational Risks
- **Binary availability**: Multiple download sources and caching
- **Network dependencies**: Offline build support
- **Version management**: Explicit version pinning and migration tools

## Future Extensibility

### Language Support
- Rust code generation
- Go code generation
- Python code generation
- Custom language plugins

### Advanced Features
- Schema registry integration
- Automatic BUILD file generation
- IDE integration support
- Advanced policy enforcement

### Enterprise Features
- Schema governance workflows
- Audit logging and compliance
- Multi-workspace coordination
- Advanced caching strategies 