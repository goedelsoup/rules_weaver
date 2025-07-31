"""
Test utilities for OpenTelemetry Weaver rules testing.

This module provides common testing utilities, mock objects, and helpers
for testing Weaver rules and their implementations.
"""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("@bazel_skylib//lib:new_sets.bzl", "sets")
load("@bazel_skylib//lib:paths.bzl", "paths")

# =============================================================================
# Mock Objects and Test Data
# =============================================================================

def create_mock_ctx(
        name = "test_target",
        srcs = None,
        deps = None,
        args = None,
        env = None,
        out_dir = "test_output",
        format = "typescript",
        enable_performance_monitoring = False,
        **kwargs):
    """Create a mock context for testing Weaver rules."""
    
    if srcs == None:
        srcs = ["schema.yaml"]
    if deps == None:
        deps = []
    if args == None:
        args = ["--verbose"]
    if env == None:
        env = {"DEBUG": "1"}
    
    return struct(
        attr = struct(
            srcs = srcs,
            deps = deps,
            args = args,
            env = env,
            out_dir = out_dir,
            format = format,
            enable_performance_monitoring = enable_performance_monitoring,
            **kwargs
        ),
        label = struct(name = name),
        actions = struct(
            declare_file = lambda path: struct(path = path),
            declare_directory = lambda path: struct(path = path),
            run = lambda **kwargs: None,
            write = lambda **kwargs: None,
        ),
        toolchains = {
            "@rules_weaver//weaver:toolchain_type": struct(
                weaver_binary = struct(path = "/path/to/weaver")
            )
        },
        runfiles = struct(files = []),
    )

def create_mock_file(path, content = None):
    """Create a mock file object for testing."""
    return struct(
        path = path,
        short_path = paths.basename(path),
        content = content or "",
    )

def create_mock_provider(provider_type, **fields):
    """Create a mock provider for testing."""
    return struct(
        **{field: value for field, value in fields.items()}
    )

# =============================================================================
# Test Data Generators
# =============================================================================

def generate_test_schema(name = "test_schema", content = None):
    """Generate a test schema file."""
    if content == None:
        content = """
openapi: 3.0.0
info:
  title: Test API
  version: 1.0.0
paths:
  /test:
    get:
      summary: Test endpoint
      responses:
        '200':
          description: Success
"""
    
    return create_mock_file(
        path = "{}.yaml".format(name),
        content = content,
    )

def generate_test_policy(name = "test_policy", content = None):
    """Generate a test policy file."""
    if content == None:
        content = """
rules:
  - name: "test_rule"
    description: "Test validation rule"
    severity: "warning"
    condition: "always"
"""
    
    return create_mock_file(
        path = "{}.yaml".format(name),
        content = content,
    )

def generate_large_schema_set(count = 100):
    """Generate a large set of test schemas for performance testing."""
    schemas = []
    for i in range(count):
        schemas.append(generate_test_schema(
            name = "large_schema_{}".format(i),
            content = """
openapi: 3.0.0
info:
  title: Large Test API {}
  version: 1.0.0
paths:
  /test{}:
    get:
      summary: Test endpoint {}
      responses:
        '200':
          description: Success
""".format(i, i, i)
        ))
    return schemas

# =============================================================================
# Assertion Helpers
# =============================================================================

def assert_provider_fields(env, provider, expected_fields):
    """Assert that a provider has the expected fields."""
    for field_name, expected_value in expected_fields.items():
        if hasattr(provider, field_name):
            actual_value = getattr(provider, field_name)
            # Check if expected_value is a list by checking if it has a length
            if hasattr(expected_value, "__len__") and not hasattr(expected_value, "startswith"):
                # It's likely a list
                asserts.equals(env, len(expected_value), len(actual_value), 
                             "Field {} should have {} items".format(field_name, len(expected_value)))
            else:
                asserts.equals(env, expected_value, actual_value,
                             "Field {} should be {}".format(field_name, expected_value))
        else:
            asserts.fail(env, "Provider should have field {}".format(field_name))

def assert_action_hermeticity(env, action):
    """Assert that an action is hermetic."""
    if hasattr(action, "use_default_shell_env"):
        asserts.false(env, action.use_default_shell_env,
                     "Action should not use default shell environment")
    
    if hasattr(action, "inputs"):
        asserts.true(env, len(action.inputs) > 0,
                    "Action should have declared inputs")
    
    if hasattr(action, "outputs"):
        asserts.true(env, len(action.outputs) > 0,
                    "Action should have declared outputs")

def assert_file_exists(env, file_list, expected_file):
    """Assert that a file exists in the file list."""
    file_paths = [f.path for f in file_list]
    asserts.true(env, expected_file in file_paths,
                "File {} should exist in {}".format(expected_file, file_paths))

def assert_dependency_tracking(env, provider, expected_deps):
    """Assert that dependency tracking is working correctly."""
    if hasattr(provider, "direct_dependencies"):
        for dep in expected_deps:
            asserts.true(env, dep in provider.direct_dependencies,
                        "Dependency {} should be tracked".format(dep))

# =============================================================================
# Performance Testing Helpers
# =============================================================================

def measure_execution_time(func, *args, **kwargs):
    """Measure the execution time of a function."""
    # Note: In Starlark, we can't use time.time() directly
    # This is a placeholder for actual time measurement
    result = func(*args, **kwargs)
    return result, 0  # Return 0ms as placeholder

def assert_performance_threshold(env, execution_time_ms, threshold_ms, operation_name):
    """Assert that an operation completes within a performance threshold."""
    asserts.true(env, execution_time_ms <= threshold_ms,
                "{} should complete within {}ms, but took {}ms".format(
                    operation_name, threshold_ms, execution_time_ms))

# =============================================================================
# Error Scenario Testing
# =============================================================================

def create_invalid_schema():
    """Create an invalid schema for error testing."""
    return create_mock_file(
        path = "invalid_schema.yaml",
        content = """
openapi: 3.0.0
info:
  title: Invalid API
  version: 1.0.0
paths:
  /test:
    get:
      summary: Test endpoint
      responses:
        '200':
          description: Success
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/NonExistentSchema'
"""
    )

def create_circular_dependency_schema():
    """Create a schema with circular dependencies for testing."""
    return create_mock_file(
        path = "circular_schema.yaml",
        content = """
openapi: 3.0.0
info:
  title: Circular Dependency API
  version: 1.0.0
components:
  schemas:
    User:
      type: object
      properties:
        profile:
          $ref: '#/components/schemas/Profile'
    Profile:
      type: object
      properties:
        user:
          $ref: '#/components/schemas/User'
"""
    )

def create_missing_dependency_schema():
    """Create a schema with missing dependencies for testing."""
    return create_mock_file(
        path = "missing_dep_schema.yaml",
        content = """
openapi: 3.0.0
info:
  title: Missing Dependency API
  version: 1.0.0
paths:
  /test:
    get:
      summary: Test endpoint
      responses:
        '200':
          description: Success
          content:
            application/json:
              schema:
                $ref: './missing_file.yaml#/components/schemas/TestSchema'
"""
    )

# =============================================================================
# Integration Testing Helpers
# =============================================================================

def create_integration_test_workspace():
    """Create a mock workspace for integration testing."""
    return struct(
        schemas = [
            generate_test_schema("api_v1"),
            generate_test_schema("api_v2"),
        ],
        policies = [
            generate_test_policy("security_policy"),
            generate_test_policy("validation_policy"),
        ],
        dependencies = [
            create_mock_file("shared_types.yaml"),
            create_mock_file("common_responses.yaml"),
        ],
    )

def assert_integration_workflow(env, workflow_result):
    """Assert that an integration workflow completed successfully."""
    asserts.true(env, workflow_result.success,
                "Integration workflow should complete successfully")
    asserts.true(env, len(workflow_result.generated_files) > 0,
                "Integration workflow should generate files")
    asserts.true(env, workflow_result.validation_passed,
                "Integration workflow should pass validation")

# =============================================================================
# Test Suite Utilities
# =============================================================================

def create_test_suite(name, test_functions):
    """Create a test suite with the given name and test functions."""
    return unittest.suite(name, *test_functions)

def run_test_suite(test_suite, name):
    """Run a test suite and return the test target."""
    return unittest.make(name, test_suite)

def create_comprehensive_test_suite(unit_tests, integration_tests, performance_tests, error_tests):
    """Create a comprehensive test suite covering all test types."""
    all_tests = []
    all_tests.extend(unit_tests)
    all_tests.extend(integration_tests)
    all_tests.extend(performance_tests)
    all_tests.extend(error_tests)
    
    return unittest.suite("comprehensive_tests", *all_tests) 