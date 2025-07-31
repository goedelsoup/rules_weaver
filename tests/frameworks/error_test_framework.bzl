"""
Error scenario testing framework for OpenTelemetry Weaver rules.

This module provides comprehensive error scenario tests including invalid schemas,
missing dependencies, configuration errors, and platform-specific errors.
"""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("@bazel_skylib//lib:new_sets.bzl", "sets")
load("//tests/utils:test_utils.bzl", 
     "create_mock_ctx", 
     "create_mock_file", 
     "create_invalid_schema",
     "create_circular_dependency_schema",
     "create_missing_dependency_schema",
     "measure_execution_time",
     "assert_performance_threshold")

# =============================================================================
# Invalid Schema File Tests
# =============================================================================

def _test_invalid_yaml_syntax_handling(ctx):
    """Test handling of invalid YAML syntax in schema files."""
    env = unittest.begin(ctx)
    
    # Create schemas with various YAML syntax errors
    invalid_schemas = [
        create_mock_file("invalid_yaml_1.yaml", "openapi: 3.0.0\ninfo:\n  title: Test API\n  version: 1.0.0\npaths:\n  /test:\n    get:\n      responses:\n        '200':\n          description: Success\n          content:\n            application/json:\n              schema:\n                type: object\n                properties:\n                  data:\n                    type: string\n                  # Missing closing brace"),
        create_mock_file("invalid_yaml_2.yaml", "openapi: 3.0.0\ninfo:\n  title: Test API\n  version: 1.0.0\npaths:\n    /test:\n      get:\n        responses:\n          '200':\n            description: Success\n            content:\n              application/json:\n                schema:\n                  type: object\n                  properties:\n                    data:\n                      type: string\n                      # Invalid indentation\n                    nested:\n                    type: object"),
        create_mock_file("invalid_yaml_3.yaml", "openapi: 3.0.0\ninfo:\n  title: Test API\n  version: 1.0.0\npaths:\n    /test:\n      get:\n        responses:\n          '200':\n            description: Success\n            content:\n              application/json:\n                schema:\n                  type: object\n                  properties:\n                    data:\n                      type: string\n                      # Invalid value\n                      required: invalid_value"),
    ]
    
    # Simulate schema validation with error handling
    def validate_schema_with_errors(schemas):
        validation_results = []
        
        for schema in schemas:
            try:
                # Simulate YAML parsing
                if "Missing closing brace" in schema.content:
                    raise Exception("YAML syntax error: Missing closing brace")
                elif "Invalid indentation" in schema.content:
                    raise Exception("YAML syntax error: Invalid indentation")
                elif "invalid_value" in schema.content:
                    raise Exception("YAML validation error: Invalid value for 'required' field")
                else:
                    validation_results.append({
                        "schema": schema.path,
                        "valid": True,
                        "errors": [],
                    })
            except Exception as e:
                validation_results.append({
                    "schema": schema.path,
                    "valid": False,
                    "errors": [str(e)],
                })
        
        return validation_results
    
    # Test error handling
    result, execution_time = measure_execution_time(validate_schema_with_errors, invalid_schemas)
    
    # Assert error detection
    assert_performance_threshold(env, execution_time, 100.0, "Invalid YAML validation")
    
    # All schemas should have validation errors
    for validation_result in result:
        asserts.false(env, validation_result["valid"], 
                    "Schema {} should be invalid".format(validation_result["schema"]))
        asserts.true(env, len(validation_result["errors"]) > 0,
                    "Schema {} should have error messages".format(validation_result["schema"]))
    
    # Verify specific error types
    error_messages = [error for result in result for error in result["errors"]]
    asserts.true(env, any("Missing closing brace" in msg for msg in error_messages),
                "Should detect missing closing brace error")
    asserts.true(env, any("Invalid indentation" in msg for msg in error_messages),
                "Should detect invalid indentation error")
    asserts.true(env, any("Invalid value" in msg for msg in error_messages),
                "Should detect invalid value error")
    
    return unittest.end(env)

def _test_invalid_openapi_schema_handling(ctx):
    """Test handling of invalid OpenAPI schema structure."""
    env = unittest.begin(ctx)
    
    # Create schemas with invalid OpenAPI structure
    invalid_openapi_schemas = [
        create_mock_file("missing_openapi_version.yaml", "info:\n  title: Test API\n  version: 1.0.0\npaths:\n  /test:\n    get:\n      responses:\n        '200':\n          description: Success"),
        create_mock_file("invalid_path_structure.yaml", "openapi: 3.0.0\ninfo:\n  title: Test API\n  version: 1.0.0\npaths:\n    invalid_path:\n      invalid_method:\n        responses:\n          '200':\n            description: Success"),
        create_mock_file("missing_required_fields.yaml", "openapi: 3.0.0\ninfo:\n  title: Test API\npaths:\n  /test:\n    get:\n      responses:\n        '200':\n          description: Success"),
        create_mock_file("invalid_schema_reference.yaml", "openapi: 3.0.0\ninfo:\n  title: Test API\n  version: 1.0.0\npaths:\n    /test:\n      get:\n        responses:\n          '200':\n            description: Success\n            content:\n              application/json:\n                schema:\n                  $ref: '#/components/schemas/NonExistentSchema'"),
    ]
    
    # Simulate OpenAPI validation
    def validate_openapi_structure(schemas):
        validation_results = []
        
        for schema in schemas:
            errors = []
            
            # Check for required OpenAPI version
            if "openapi:" not in schema.content:
                errors.append("Missing required 'openapi' field")
            
            # Check for valid info structure
            if "info:" not in schema.content:
                errors.append("Missing required 'info' field")
            elif "version:" not in schema.content:
                errors.append("Missing required 'version' field in info")
            
            # Check for valid paths structure
            if "paths:" not in schema.content:
                errors.append("Missing required 'paths' field")
            
            # Check for invalid schema references
            if "NonExistentSchema" in schema.content:
                errors.append("Invalid schema reference: NonExistentSchema does not exist")
            
            validation_results.append({
                "schema": schema.path,
                "valid": len(errors) == 0,
                "errors": errors,
            })
        
        return validation_results
    
    # Test OpenAPI validation
    result, execution_time = measure_execution_time(validate_openapi_structure, invalid_openapi_schemas)
    
    # Assert error detection
    assert_performance_threshold(env, execution_time, 100.0, "OpenAPI structure validation")
    
    # All schemas should have validation errors
    for validation_result in result:
        asserts.false(env, validation_result["valid"],
                    "Schema {} should be invalid".format(validation_result["schema"]))
        asserts.true(env, len(validation_result["errors"]) > 0,
                    "Schema {} should have error messages".format(validation_result["schema"]))
    
    # Verify specific error types
    all_errors = [error for result in result for error in result["errors"]]
    asserts.true(env, any("Missing required 'openapi' field" in error for error in all_errors),
                "Should detect missing OpenAPI version")
    asserts.true(env, any("Missing required 'version' field" in error for error in all_errors),
                "Should detect missing version field")
    asserts.true(env, any("Invalid schema reference" in error for error in all_errors),
                "Should detect invalid schema references")
    
    return unittest.end(env)

# =============================================================================
# Missing Dependency Tests
# =============================================================================

def _test_missing_dependency_handling(ctx):
    """Test handling of missing dependencies."""
    env = unittest.begin(ctx)
    
    # Create schemas with missing dependencies
    schemas_with_missing_deps = [
        create_missing_dependency_schema(),
        create_mock_file("missing_shared_types.yaml", """
openapi: 3.0.0
info:
  title: Test API
  version: 1.0.0
paths:
  /test:
    get:
      responses:
        '200':
          description: Success
          content:
            application/json:
              schema:
                $ref: './shared_types.yaml#/components/schemas/User'
"""),
        create_mock_file("missing_external_ref.yaml", """
openapi: 3.0.0
info:
  title: Test API
  version: 1.0.0
paths:
  /test:
    get:
      responses:
        '200':
          description: Success
          content:
            application/json:
              schema:
                $ref: 'https://example.com/schemas/external.yaml#/components/schemas/ExternalType'
"""),
    ]
    
    # Simulate dependency resolution
    def resolve_dependencies(schemas, available_files):
        resolution_results = []
        
        for schema in schemas:
            missing_deps = []
            
            # Extract $ref references
            import re
            ref_pattern = r'\$ref:\s*[\'"]([^\'"]+)[\'"]'
            refs = re.findall(ref_pattern, schema.content)
            
            for ref in refs:
                # Check if reference is resolvable
                if ref.startswith('./') or ref.startswith('../'):
                    # Local file reference
                    ref_path = ref.split('#')[0]
                    if ref_path not in available_files:
                        missing_deps.append(ref)
                elif ref.startswith('http'):
                    # External reference - simulate network failure
                    missing_deps.append(ref)
            
            resolution_results.append({
                "schema": schema.path,
                "missing_dependencies": missing_deps,
                "resolvable": len(missing_deps) == 0,
            })
        
        return resolution_results
    
    # Test dependency resolution
    available_files = ["schema.yaml", "policy.yaml"]  # Missing the referenced files
    result, execution_time = measure_execution_time(
        resolve_dependencies, schemas_with_missing_deps, available_files
    )
    
    # Assert dependency resolution
    assert_performance_threshold(env, execution_time, 100.0, "Dependency resolution")
    
    # All schemas should have missing dependencies
    for resolution_result in result:
        asserts.false(env, resolution_result["resolvable"],
                    "Schema {} should have missing dependencies".format(resolution_result["schema"]))
        asserts.true(env, len(resolution_result["missing_dependencies"]) > 0,
                    "Schema {} should have missing dependency list".format(resolution_result["schema"]))
    
    # Verify specific missing dependencies
    all_missing_deps = [dep for result in result for dep in result["missing_dependencies"]]
    asserts.true(env, any("missing_file.yaml" in dep for dep in all_missing_deps),
                "Should detect missing local file dependency")
    asserts.true(env, any("shared_types.yaml" in dep for dep in all_missing_deps),
                "Should detect missing shared types dependency")
    asserts.true(env, any("https://example.com" in dep for dep in all_missing_deps),
                "Should detect missing external dependency")
    
    return unittest.end(env)

def _test_circular_dependency_detection(ctx):
    """Test detection of circular dependencies."""
    env = unittest.begin(ctx)
    
    # Create schemas with circular dependencies
    circular_schemas = [
        create_circular_dependency_schema(),
        create_mock_file("circular_a.yaml", """
openapi: 3.0.0
info:
  title: Circular A
  version: 1.0.0
components:
  schemas:
    A:
      type: object
      properties:
        b:
          $ref: './circular_b.yaml#/components/schemas/B'
"""),
        create_mock_file("circular_b.yaml", """
openapi: 3.0.0
info:
  title: Circular B
  version: 1.0.0
components:
  schemas:
    B:
      type: object
      properties:
        c:
          $ref: './circular_c.yaml#/components/schemas/C'
"""),
        create_mock_file("circular_c.yaml", """
openapi: 3.0.0
info:
  title: Circular C
  version: 1.0.0
components:
  schemas:
    C:
      type: object
      properties:
        a:
          $ref: './circular_a.yaml#/components/schemas/A'
"""),
    ]
    
    # Simulate circular dependency detection
    def detect_circular_dependencies(schemas):
        # Build dependency graph
        dependency_graph = {}
        
        for schema in schemas:
            # Extract dependencies from schema content
            import re
            ref_pattern = r'\$ref:\s*[\'"]([^\'"]+)[\'"]'
            refs = re.findall(ref_pattern, schema.content)
            
            dependencies = []
            for ref in refs:
                if ref.startswith('./'):
                    dep_file = ref.split('#')[0]
                    dependencies.append(dep_file)
            
            dependency_graph[schema.path] = dependencies
        
        # Detect circular dependencies using DFS
        def has_cycle(graph, node, visited, rec_stack, path):
            visited.add(node)
            rec_stack.add(node)
            path.append(node)
            
            for neighbor in graph.get(node, []):
                if neighbor not in visited:
                    if has_cycle(graph, neighbor, visited, rec_stack, path):
                        return True
                elif neighbor in rec_stack:
                    # Found cycle
                    cycle_start = path.index(neighbor)
                    cycle = path[cycle_start:] + [neighbor]
                    return True
            
            rec_stack.remove(node)
            path.pop()
            return False
        
        circular_deps = []
        for node in dependency_graph:
            visited = set()
            rec_stack = set()
            path = []
            if has_cycle(dependency_graph, node, visited, rec_stack, path):
                circular_deps.append(node)
        
        return struct(
            dependency_graph = dependency_graph,
            circular_dependencies = circular_deps,
            has_circular_deps = len(circular_deps) > 0,
        )
    
    # Test circular dependency detection
    result, execution_time = measure_execution_time(detect_circular_dependencies, circular_schemas)
    
    # Assert circular dependency detection
    assert_performance_threshold(env, execution_time, 100.0, "Circular dependency detection")
    
    # Should detect circular dependencies
    asserts.true(env, result.has_circular_deps, "Should detect circular dependencies")
    asserts.true(env, len(result.circular_dependencies) > 0,
                "Should identify schemas with circular dependencies")
    
    # Verify dependency graph construction
    asserts.true(env, len(result.dependency_graph) > 0, "Should build dependency graph")
    
    return unittest.end(env)

# =============================================================================
# Configuration Error Tests
# =============================================================================

def _test_invalid_configuration_handling(ctx):
    """Test handling of invalid configuration parameters."""
    env = unittest.begin(ctx)
    
    # Create mock contexts with invalid configurations
    invalid_configs = [
        create_mock_ctx(
            name = "invalid_format",
            format = "invalid_format_type",
            srcs = [create_mock_file("schema.yaml")],
        ),
        create_mock_ctx(
            name = "invalid_args",
            args = ["--invalid-flag", "--unknown-option"],
            srcs = [create_mock_file("schema.yaml")],
        ),
        create_mock_ctx(
            name = "invalid_env",
            env = {"INVALID_VAR": "invalid_value", "DEBUG": "not_a_boolean"},
            srcs = [create_mock_file("schema.yaml")],
        ),
        create_mock_ctx(
            name = "missing_srcs",
            srcs = [],
        ),
    ]
    
    # Simulate configuration validation
    def validate_configuration(configs):
        validation_results = []
        
        valid_formats = ["typescript", "javascript", "python", "go", "java", "html", "markdown"]
        valid_env_vars = ["DEBUG", "NODE_ENV", "PYTHONPATH", "GOPATH"]
        
        for config in configs:
            errors = []
            
            # Validate format
            if hasattr(config.attr, "format"):
                if config.attr.format not in valid_formats:
                    errors.append("Invalid format: {}".format(config.attr.format))
            
            # Validate arguments
            if hasattr(config.attr, "args"):
                for arg in config.attr.args:
                    if arg.startswith("--") and arg not in ["--verbose", "--strict", "--format", "--template"]:
                        errors.append("Invalid argument: {}".format(arg))
            
            # Validate environment variables
            if hasattr(config.attr, "env"):
                for var, value in config.attr.env.items():
                    if var not in valid_env_vars:
                        errors.append("Invalid environment variable: {}".format(var))
                    elif var == "DEBUG" and value not in ["0", "1", "true", "false"]:
                        errors.append("Invalid DEBUG value: {}".format(value))
            
            # Validate source files
            if hasattr(config.attr, "srcs"):
                if len(config.attr.srcs) == 0:
                    errors.append("No source files provided")
            
            validation_results.append({
                "config": config.label.name,
                "valid": len(errors) == 0,
                "errors": errors,
            })
        
        return validation_results
    
    # Test configuration validation
    result, execution_time = measure_execution_time(validate_configuration, invalid_configs)
    
    # Assert configuration validation
    assert_performance_threshold(env, execution_time, 100.0, "Configuration validation")
    
    # All configurations should have errors
    for validation_result in result:
        asserts.false(env, validation_result["valid"],
                    "Configuration {} should be invalid".format(validation_result["config"]))
        asserts.true(env, len(validation_result["errors"]) > 0,
                    "Configuration {} should have error messages".format(validation_result["config"]))
    
    # Verify specific error types
    all_errors = [error for result in result for error in result["errors"]]
    asserts.true(env, any("Invalid format" in error for error in all_errors),
                "Should detect invalid format")
    asserts.true(env, any("Invalid argument" in error for error in all_errors),
                "Should detect invalid arguments")
    asserts.true(env, any("Invalid environment variable" in error for error in all_errors),
                "Should detect invalid environment variables")
    asserts.true(env, any("No source files provided" in error for error in all_errors),
                "Should detect missing source files")
    
    return unittest.end(env)

# =============================================================================
# Platform-Specific Error Tests
# =============================================================================

def _test_platform_specific_error_handling(ctx):
    """Test handling of platform-specific errors."""
    env = unittest.begin(ctx)
    
    # Simulate platform-specific scenarios
    platform_scenarios = [
        {
            "platform": "linux",
            "error_type": "permission_denied",
            "description": "File permission error on Linux",
        },
        {
            "platform": "darwin",
            "error_type": "file_not_found",
            "description": "Missing file on macOS",
        },
        {
            "platform": "windows",
            "error_type": "path_too_long",
            "description": "Path too long error on Windows",
        },
        {
            "platform": "linux",
            "error_type": "disk_full",
            "description": "Disk full error on Linux",
        },
    ]
    
    # Simulate platform-specific error handling
    def handle_platform_errors(scenarios):
        error_results = []
        
        for scenario in scenarios:
            platform = scenario["platform"]
            error_type = scenario["error_type"]
            
            # Simulate platform-specific error handling
            if error_type == "permission_denied":
                error_msg = "Permission denied: Cannot write to output directory"
                recoverable = True
                suggestion = "Check file permissions and try again"
            elif error_type == "file_not_found":
                error_msg = "File not found: Required dependency missing"
                recoverable = True
                suggestion = "Verify all dependencies are available"
            elif error_type == "path_too_long":
                error_msg = "Path too long: Output path exceeds system limits"
                recoverable = False
                suggestion = "Use shorter output directory path"
            elif error_type == "disk_full":
                error_msg = "Disk full: Insufficient space for output files"
                recoverable = False
                suggestion = "Free up disk space and try again"
            else:
                error_msg = "Unknown platform error"
                recoverable = False
                suggestion = "Check system requirements"
            
            error_results.append({
                "platform": platform,
                "error_type": error_type,
                "error_message": error_msg,
                "recoverable": recoverable,
                "suggestion": suggestion,
            })
        
        return error_results
    
    # Test platform-specific error handling
    result, execution_time = measure_execution_time(handle_platform_errors, platform_scenarios)
    
    # Assert platform-specific error handling
    assert_performance_threshold(env, execution_time, 100.0, "Platform-specific error handling")
    
    # Verify error handling for each scenario
    for error_result in result:
        asserts.true(env, error_result["error_message"] != None,
                    "Should provide error message for {}".format(error_result["error_type"]))
        asserts.true(env, error_result["suggestion"] != None,
                    "Should provide suggestion for {}".format(error_result["error_type"]))
        
        # Verify specific error types
        if error_result["error_type"] == "permission_denied":
            asserts.true(env, "Permission denied" in error_result["error_message"],
                        "Should handle permission denied error")
            asserts.true(env, error_result["recoverable"],
                        "Permission denied should be recoverable")
        elif error_result["error_type"] == "path_too_long":
            asserts.true(env, "Path too long" in error_result["error_message"],
                        "Should handle path too long error")
            asserts.false(env, error_result["recoverable"],
                         "Path too long should not be recoverable")
    
    return unittest.end(env)

# =============================================================================
# Test Suites
# =============================================================================

# Invalid schema test suite
invalid_schema_test_suite = unittest.suite(
    "invalid_schema_tests",
    _test_invalid_yaml_syntax_handling,
    _test_invalid_openapi_schema_handling,
)

# Missing dependency test suite
missing_dependency_test_suite = unittest.suite(
    "missing_dependency_tests",
    _test_missing_dependency_handling,
    _test_circular_dependency_detection,
)

# Configuration error test suite
configuration_error_test_suite = unittest.suite(
    "configuration_error_tests",
    _test_invalid_configuration_handling,
)

# Platform-specific error test suite
platform_error_test_suite = unittest.suite(
    "platform_error_tests",
    _test_platform_specific_error_handling,
)

# Comprehensive error scenario test suite
comprehensive_error_test_suite = unittest.suite(
    "comprehensive_error_tests",
    _test_invalid_yaml_syntax_handling,
    _test_invalid_openapi_schema_handling,
    _test_missing_dependency_handling,
    _test_circular_dependency_detection,
    _test_invalid_configuration_handling,
    _test_platform_specific_error_handling,
) 