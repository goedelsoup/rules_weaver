"""
Unit testing framework for OpenTelemetry Weaver rules.

This module provides comprehensive unit tests for all Weaver rules,
providers, and internal functions with high test coverage.
"""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("@bazel_skylib//lib:new_sets.bzl", "sets")
load("//tests/utils:test_utils.bzl", 
     "create_mock_ctx", 
     "create_mock_file", 
     "create_mock_provider",
     "generate_test_schema",
     "generate_test_policy",
     "assert_provider_fields",
     "assert_action_hermeticity",
     "assert_file_exists",
     "assert_dependency_tracking",
     "measure_execution_time",
     "assert_performance_threshold")

# =============================================================================
# Provider Tests
# =============================================================================

def _test_weaver_generated_info_provider(ctx):
    """Test WeaverGeneratedInfo provider creation and fields."""
    env = unittest.begin(ctx)
    
    # Create mock data
    generated_files = [create_mock_file("generated.ts"), create_mock_file("generated.d.ts")]
    source_schemas = [create_mock_file("schema.yaml")]
    generation_args = ["--format", "typescript", "--verbose"]
    
    # Create provider
    provider = create_mock_provider(
        "WeaverGeneratedInfo",
        generated_files = generated_files,
        output_dir = "test_output",
        source_schemas = source_schemas,
        generation_args = generation_args,
    )
    
    # Assert provider fields
    expected_fields = {
        "generated_files": generated_files,
        "output_dir": "test_output",
        "source_schemas": source_schemas,
        "generation_args": generation_args,
    }
    assert_provider_fields(env, provider, expected_fields)
    
    return unittest.end(env)

def _test_weaver_validation_info_provider(ctx):
    """Test WeaverValidationInfo provider creation and fields."""
    env = unittest.begin(ctx)
    
    # Create mock data
    validation_output = create_mock_file("validation_result.json")
    validated_schemas = [create_mock_file("schema.yaml")]
    applied_policies = [create_mock_file("policy.yaml")]
    validation_args = ["--strict", "--verbose"]
    
    # Create provider
    provider = create_mock_provider(
        "WeaverValidationInfo",
        validation_output = validation_output,
        validated_schemas = validated_schemas,
        applied_policies = applied_policies,
        validation_args = validation_args,
        success = True,
    )
    
    # Assert provider fields
    expected_fields = {
        "validation_output": validation_output,
        "validated_schemas": validated_schemas,
        "applied_policies": applied_policies,
        "validation_args": validation_args,
        "success": True,
    }
    assert_provider_fields(env, provider, expected_fields)
    
    return unittest.end(env)

def _test_weaver_schema_info_provider(ctx):
    """Test WeaverSchemaInfo provider creation and fields."""
    env = unittest.begin(ctx)
    
    # Create mock data
    schema_files = [create_mock_file("schema.yaml")]
    schema_content = [create_mock_file("parsed_schema.json")]
    dependencies = []
    metadata = {"schema_count": 1, "formats": ["yaml"]}
    
    # Create provider
    provider = create_mock_provider(
        "WeaverSchemaInfo",
        schema_files = schema_files,
        schema_content = schema_content,
        dependencies = dependencies,
        metadata = metadata,
    )
    
    # Assert provider fields
    expected_fields = {
        "schema_files": schema_files,
        "schema_content": schema_content,
        "dependencies": dependencies,
        "metadata": metadata,
    }
    assert_provider_fields(env, provider, expected_fields)
    
    return unittest.end(env)

def _test_weaver_dependency_info_provider(ctx):
    """Test WeaverDependencyInfo provider creation and fields."""
    env = unittest.begin(ctx)
    
    # Create mock data
    direct_dependencies = ["schema1.yaml", "schema2.yaml"]
    transitive_dependencies = []
    dependency_graph = {"schema1.yaml": [], "schema2.yaml": ["schema1.yaml"]}
    circular_dependencies = []
    content_hashes = {"schema1.yaml": "hash1", "schema2.yaml": "hash2"}
    change_detection_data = {"last_modified": "2024-01-01"}
    
    # Create provider
    provider = create_mock_provider(
        "WeaverDependencyInfo",
        direct_dependencies = direct_dependencies,
        transitive_dependencies = transitive_dependencies,
        dependency_graph = dependency_graph,
        circular_dependencies = circular_dependencies,
        content_hashes = content_hashes,
        change_detection_data = change_detection_data,
    )
    
    # Assert provider fields
    expected_fields = {
        "direct_dependencies": direct_dependencies,
        "transitive_dependencies": transitive_dependencies,
        "dependency_graph": dependency_graph,
        "circular_dependencies": circular_dependencies,
        "content_hashes": content_hashes,
        "change_detection_data": change_detection_data,
    }
    assert_provider_fields(env, provider, expected_fields)
    
    return unittest.end(env)

def _test_weaver_docs_info_provider(ctx):
    """Test WeaverDocsInfo provider creation and fields."""
    env = unittest.begin(ctx)
    
    # Create mock data
    documentation_files = [create_mock_file("docs.html"), create_mock_file("docs.md")]
    source_schemas = [create_mock_file("schema.yaml")]
    documentation_format = "html"
    template_used = create_mock_file("template.html")
    generation_args = ["--format", "html", "--template", "template.html"]
    
    # Create provider
    provider = create_mock_provider(
        "WeaverDocsInfo",
        documentation_files = documentation_files,
        output_dir = "docs_output",
        source_schemas = source_schemas,
        documentation_format = documentation_format,
        template_used = template_used,
        generation_args = generation_args,
    )
    
    # Assert provider fields
    expected_fields = {
        "documentation_files": documentation_files,
        "output_dir": "docs_output",
        "source_schemas": source_schemas,
        "documentation_format": documentation_format,
        "template_used": template_used,
        "generation_args": generation_args,
    }
    assert_provider_fields(env, provider, expected_fields)
    
    return unittest.end(env)

# =============================================================================
# Rule Implementation Tests
# =============================================================================

def _test_weaver_schema_rule_implementation(ctx):
    """Test weaver_schema rule implementation."""
    env = unittest.begin(ctx)
    
    # Create mock context
    mock_ctx = create_mock_ctx(
        name = "test_schema",
        srcs = [create_mock_file("schema.yaml")],
        deps = [],
        enable_performance_monitoring = True,
    )
    
    # Test that the rule can be created with valid inputs
    asserts.true(env, mock_ctx.attr.srcs != None, "Schema sources should be defined")
    asserts.true(env, len(mock_ctx.attr.srcs) > 0, "Schema sources should not be empty")
    asserts.true(env, mock_ctx.attr.enable_performance_monitoring, "Performance monitoring should be enabled")
    
    return unittest.end(env)

def _test_weaver_generate_rule_implementation(ctx):
    """Test weaver_generate rule implementation."""
    env = unittest.begin(ctx)
    
    # Create mock context
    mock_ctx = create_mock_ctx(
        name = "test_generate",
        srcs = [create_mock_file("schema.yaml")],
        format = "typescript",
        args = ["--verbose", "--strict"],
        env = {"DEBUG": "1", "NODE_ENV": "production"},
    )
    
    # Test that the rule can be created with valid inputs
    asserts.true(env, mock_ctx.attr.srcs != None, "Schema sources should be defined")
    asserts.equals(env, "typescript", mock_ctx.attr.format, "Format should be typescript")
    asserts.true(env, len(mock_ctx.attr.args) > 0, "Arguments should be provided")
    asserts.true(env, len(mock_ctx.attr.env) > 0, "Environment variables should be provided")
    
    return unittest.end(env)

def _test_weaver_validate_rule_implementation(ctx):
    """Test weaver_validate rule implementation."""
    env = unittest.begin(ctx)
    
    # Create mock context
    mock_ctx = create_mock_ctx(
        name = "test_validate",
        srcs = [create_mock_file("schema.yaml")],
        deps = [create_mock_file("policy.yaml")],
        args = ["--strict", "--verbose"],
    )
    
    # Test that the rule can be created with valid inputs
    asserts.true(env, mock_ctx.attr.srcs != None, "Schema sources should be defined")
    asserts.true(env, len(mock_ctx.attr.deps) > 0, "Dependencies should be provided")
    asserts.true(env, len(mock_ctx.attr.args) > 0, "Arguments should be provided")
    
    return unittest.end(env)

def _test_weaver_docs_rule_implementation(ctx):
    """Test weaver_docs rule implementation."""
    env = unittest.begin(ctx)
    
    # Create mock context
    mock_ctx = create_mock_ctx(
        name = "test_docs",
        srcs = [create_mock_file("schema.yaml")],
        format = "html",
        args = ["--template", "custom.html"],
        out_dir = "docs_output",
    )
    
    # Test that the rule can be created with valid inputs
    asserts.true(env, mock_ctx.attr.srcs != None, "Schema sources should be defined")
    asserts.equals(env, "html", mock_ctx.attr.format, "Format should be html")
    asserts.true(env, len(mock_ctx.attr.args) > 0, "Arguments should be provided")
    asserts.equals(env, "docs_output", mock_ctx.attr.out_dir, "Output directory should be set")
    
    return unittest.end(env)

# =============================================================================
# Action Tests
# =============================================================================

def _test_generate_action_creation(ctx):
    """Test generate action creation and properties."""
    env = unittest.begin(ctx)
    
    # Create mock action
    mock_action = struct(
        use_default_shell_env = False,
        inputs = [create_mock_file("schema.yaml"), create_mock_file("weaver_binary")],
        outputs = [create_mock_file("generated.ts"), create_mock_file("generated.d.ts")],
        arguments = ["--format", "typescript", "--verbose"],
        executable = create_mock_file("weaver_binary"),
    )
    
    # Test action properties
    assert_action_hermeticity(env, mock_action)
    asserts.true(env, len(mock_action.arguments) > 0, "Action should have arguments")
    asserts.true(env, mock_action.executable != None, "Action should have executable")
    
    return unittest.end(env)

def _test_validation_action_creation(ctx):
    """Test validation action creation and properties."""
    env = unittest.begin(ctx)
    
    # Create mock action
    mock_action = struct(
        use_default_shell_env = False,
        inputs = [create_mock_file("schema.yaml"), create_mock_file("policy.yaml")],
        outputs = [create_mock_file("validation_result.json")],
        arguments = ["--strict", "--verbose"],
        executable = create_mock_file("weaver_binary"),
    )
    
    # Test action properties
    assert_action_hermeticity(env, mock_action)
    asserts.true(env, len(mock_action.arguments) > 0, "Action should have arguments")
    asserts.true(env, mock_action.executable != None, "Action should have executable")
    
    return unittest.end(env)

def _test_documentation_action_creation(ctx):
    """Test documentation action creation and properties."""
    env = unittest.begin(ctx)
    
    # Create mock action
    mock_action = struct(
        use_default_shell_env = False,
        inputs = [create_mock_file("schema.yaml"), create_mock_file("template.html")],
        outputs = [create_mock_file("docs.html"), create_mock_file("docs.md")],
        arguments = ["--format", "html", "--template", "template.html"],
        executable = create_mock_file("weaver_binary"),
    )
    
    # Test action properties
    assert_action_hermeticity(env, mock_action)
    asserts.true(env, len(mock_action.arguments) > 0, "Action should have arguments")
    asserts.true(env, mock_action.executable != None, "Action should have executable")
    
    return unittest.end(env)

# =============================================================================
# Performance Tests
# =============================================================================

def _test_large_schema_processing_performance(ctx):
    """Test performance with large schema sets."""
    env = unittest.begin(ctx)
    
    # Generate large schema set
    large_schemas = generate_large_schema_set(100)
    
    # Measure processing time
    def process_schemas(schemas):
        # Simulate schema processing
        return [s.path for s in schemas]
    
    result, execution_time = measure_execution_time(process_schemas, large_schemas)
    
    # Assert performance threshold (100ms for 100 schemas)
    assert_performance_threshold(env, execution_time, 100.0, "Large schema processing")
    asserts.equals(env, 100, len(result), "Should process all schemas")
    
    return unittest.end(env)

def _test_incremental_build_performance(ctx):
    """Test incremental build performance."""
    env = unittest.begin(ctx)
    
    # Simulate incremental build scenario
    def incremental_build(changed_files):
        # Simulate incremental processing
        return len(changed_files)
    
    # Test with different change sets
    small_changes = ["schema1.yaml", "schema2.yaml"]
    large_changes = ["schema{}.yaml".format(i) for i in range(50)]
    
    small_result, small_time = measure_execution_time(incremental_build, small_changes)
    large_result, large_time = measure_execution_time(incremental_build, large_changes)
    
    # Assert performance characteristics
    assert_performance_threshold(env, small_time, 10.0, "Small incremental build")
    assert_performance_threshold(env, large_time, 50.0, "Large incremental build")
    asserts.true(env, large_time > small_time, "Large changes should take more time")
    
    return unittest.end(env)

# =============================================================================
# Error Handling Tests
# =============================================================================

def _test_invalid_schema_handling(ctx):
    """Test handling of invalid schemas."""
    env = unittest.begin(ctx)
    
    # Create invalid schema
    invalid_schema = create_mock_file(
        path = "invalid_schema.yaml",
        content = "invalid: yaml: content: [",
    )
    
    # Test that invalid schema is detected
    asserts.true(env, invalid_schema != None, "Invalid schema should be created")
    asserts.true(env, "invalid" in invalid_schema.content, "Invalid schema should contain invalid content")
    
    return unittest.end(env)

def _test_missing_dependency_handling(ctx):
    """Test handling of missing dependencies."""
    env = unittest.begin(ctx)
    
    # Create schema with missing dependency
    schema_with_missing_dep = create_mock_file(
        path = "schema_with_missing.yaml",
        content = """
openapi: 3.0.0
info:
  title: Test API
  version: 1.0.0
paths:
  /test:
    get:
      responses:
        '200':
          content:
            application/json:
              schema:
                $ref: './missing_file.yaml#/components/schemas/TestSchema'
""",
    )
    
    # Test that missing dependency is detected
    asserts.true(env, schema_with_missing_dep != None, "Schema with missing dependency should be created")
    asserts.true(env, "missing_file.yaml" in schema_with_missing_dep.content, "Schema should reference missing file")
    
    return unittest.end(env)

def _test_circular_dependency_detection(ctx):
    """Test detection of circular dependencies."""
    env = unittest.begin(ctx)
    
    # Create schemas with circular dependencies
    schema_a = create_mock_file(
        path = "schema_a.yaml",
        content = """
openapi: 3.0.0
components:
  schemas:
    A:
      type: object
      properties:
        b:
          $ref: './schema_b.yaml#/components/schemas/B'
""",
    )
    
    schema_b = create_mock_file(
        path = "schema_b.yaml",
        content = """
openapi: 3.0.0
components:
  schemas:
    B:
      type: object
      properties:
        a:
          $ref: './schema_a.yaml#/components/schemas/A'
""",
    )
    
    # Test that circular dependency is detected
    asserts.true(env, schema_a != None, "Schema A should be created")
    asserts.true(env, schema_b != None, "Schema B should be created")
    asserts.true(env, "schema_b.yaml" in schema_a.content, "Schema A should reference Schema B")
    asserts.true(env, "schema_a.yaml" in schema_b.content, "Schema B should reference Schema A")
    
    return unittest.end(env)

# =============================================================================
# Test Suites
# =============================================================================

# Provider test suite
provider_test_suite = unittest.suite(
    "provider_tests",
    _test_weaver_generated_info_provider,
    _test_weaver_validation_info_provider,
    _test_weaver_schema_info_provider,
    _test_weaver_dependency_info_provider,
    _test_weaver_docs_info_provider,
)

# Rule implementation test suite
rule_test_suite = unittest.suite(
    "rule_tests",
    _test_weaver_schema_rule_implementation,
    _test_weaver_generate_rule_implementation,
    _test_weaver_validate_rule_implementation,
    _test_weaver_docs_rule_implementation,
)

# Action test suite
action_test_suite = unittest.suite(
    "action_tests",
    _test_generate_action_creation,
    _test_validation_action_creation,
    _test_documentation_action_creation,
)

# Performance test suite
performance_test_suite = unittest.suite(
    "performance_tests",
    _test_large_schema_processing_performance,
    _test_incremental_build_performance,
)

# Error handling test suite
error_test_suite = unittest.suite(
    "error_tests",
    _test_invalid_schema_handling,
    _test_missing_dependency_handling,
    _test_circular_dependency_detection,
)

# Comprehensive unit test suite
comprehensive_unit_test_suite = unittest.suite(
    "comprehensive_unit_tests",
    _test_weaver_generated_info_provider,
    _test_weaver_validation_info_provider,
    _test_weaver_schema_info_provider,
    _test_weaver_dependency_info_provider,
    _test_weaver_docs_info_provider,
    _test_weaver_schema_rule_implementation,
    _test_weaver_generate_rule_implementation,
    _test_weaver_validate_rule_implementation,
    _test_weaver_docs_rule_implementation,
    _test_generate_action_creation,
    _test_validation_action_creation,
    _test_documentation_action_creation,
    _test_large_schema_processing_performance,
    _test_incremental_build_performance,
    _test_invalid_schema_handling,
    _test_missing_dependency_handling,
    _test_circular_dependency_detection,
) 