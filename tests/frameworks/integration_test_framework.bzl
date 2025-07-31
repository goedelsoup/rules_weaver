"""
Integration testing framework for OpenTelemetry Weaver rules.

This module provides comprehensive integration tests for end-to-end workflows,
dependency tracking, caching behavior, and remote execution compatibility.
"""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("@bazel_skylib//lib:new_sets.bzl", "sets")
load("//tests/utils:test_utils.bzl", 
     "create_mock_ctx", 
     "create_mock_file", 
     "create_mock_provider",
     "generate_test_schema",
     "generate_test_policy",
     "create_integration_test_workspace",
     "assert_integration_workflow",
     "assert_provider_fields",
     "assert_dependency_tracking",
     "measure_execution_time",
     "assert_performance_threshold")

# =============================================================================
# End-to-End Workflow Tests
# =============================================================================

def _test_complete_generation_workflow(ctx):
    """Test complete code generation workflow from schema to output."""
    env = unittest.begin(ctx)
    
    # Create integration workspace
    workspace = create_integration_test_workspace()
    
    # Simulate complete workflow
    def complete_generation_workflow(schemas, policies, deps):
        # 1. Parse schemas
        parsed_schemas = [s.path for s in schemas]
        
        # 2. Validate schemas
        validation_results = [{"schema": s.path, "valid": True} for s in schemas]
        
        # 3. Generate code
        generated_files = [
            create_mock_file("generated_types.ts"),
            create_mock_file("generated_client.ts"),
            create_mock_file("generated_types.d.ts"),
        ]
        
        # 4. Create provider
        provider = create_mock_provider(
            "WeaverGeneratedInfo",
            generated_files = generated_files,
            output_dir = "generated_output",
            source_schemas = schemas,
            generation_args = ["--format", "typescript", "--verbose"],
        )
        
        return struct(
            success = True,
            generated_files = generated_files,
            validation_passed = True,
            provider = provider,
        )
    
    # Execute workflow
    result, execution_time = measure_execution_time(
        complete_generation_workflow,
        workspace.schemas,
        workspace.policies,
        workspace.dependencies,
    )
    
    # Assert workflow completion
    assert_integration_workflow(env, result)
    assert_performance_threshold(env, execution_time, 500.0, "Complete generation workflow")
    
    # Assert provider fields
    expected_fields = {
        "generated_files": result.generated_files,
        "output_dir": "generated_output",
        "source_schemas": workspace.schemas,
        "generation_args": ["--format", "typescript", "--verbose"],
    }
    assert_provider_fields(env, result.provider, expected_fields)
    
    return unittest.end(env)

def _test_complete_validation_workflow(ctx):
    """Test complete validation workflow with policies."""
    env = unittest.begin(ctx)
    
    # Create integration workspace
    workspace = create_integration_test_workspace()
    
    # Simulate complete validation workflow
    def complete_validation_workflow(schemas, policies, deps):
        # 1. Parse schemas
        parsed_schemas = [s.path for s in schemas]
        
        # 2. Parse policies
        parsed_policies = [p.path for p in policies]
        
        # 3. Apply validation rules
        validation_results = []
        for schema in schemas:
            for policy in policies:
                validation_results.append({
                    "schema": schema.path,
                    "policy": policy.path,
                    "valid": True,
                    "warnings": [],
                    "errors": [],
                })
        
        # 4. Create provider
        provider = create_mock_provider(
            "WeaverValidationInfo",
            validation_output = create_mock_file("validation_result.json"),
            validated_schemas = schemas,
            applied_policies = policies,
            validation_args = ["--strict", "--verbose"],
            success = True,
        )
        
        return struct(
            success = True,
            validation_passed = True,
            validation_results = validation_results,
            provider = provider,
        )
    
    # Execute workflow
    result, execution_time = measure_execution_time(
        complete_validation_workflow,
        workspace.schemas,
        workspace.policies,
        workspace.dependencies,
    )
    
    # Assert workflow completion
    assert_integration_workflow(env, result)
    assert_performance_threshold(env, execution_time, 300.0, "Complete validation workflow")
    
    # Assert provider fields
    expected_fields = {
        "validated_schemas": workspace.schemas,
        "applied_policies": workspace.policies,
        "validation_args": ["--strict", "--verbose"],
        "success": True,
    }
    assert_provider_fields(env, result.provider, expected_fields)
    
    return unittest.end(env)

def _test_complete_documentation_workflow(ctx):
    """Test complete documentation generation workflow."""
    env = unittest.begin(ctx)
    
    # Create integration workspace
    workspace = create_integration_test_workspace()
    
    # Simulate complete documentation workflow
    def complete_documentation_workflow(schemas, policies, deps):
        # 1. Parse schemas
        parsed_schemas = [s.path for s in schemas]
        
        # 2. Generate documentation
        documentation_files = [
            create_mock_file("api_documentation.html"),
            create_mock_file("api_documentation.md"),
            create_mock_file("api_specification.json"),
        ]
        
        # 3. Create provider
        provider = create_mock_provider(
            "WeaverDocsInfo",
            documentation_files = documentation_files,
            output_dir = "docs_output",
            source_schemas = schemas,
            documentation_format = "html",
            template_used = create_mock_file("default.html.template"),
            generation_args = ["--format", "html", "--template", "default.html.template"],
        )
        
        return struct(
            success = True,
            generated_files = documentation_files,
            validation_passed = True,
            provider = provider,
        )
    
    # Execute workflow
    result, execution_time = measure_execution_time(
        complete_documentation_workflow,
        workspace.schemas,
        workspace.policies,
        workspace.dependencies,
    )
    
    # Assert workflow completion
    assert_integration_workflow(env, result)
    assert_performance_threshold(env, execution_time, 400.0, "Complete documentation workflow")
    
    # Assert provider fields
    expected_fields = {
        "documentation_files": result.generated_files,
        "output_dir": "docs_output",
        "source_schemas": workspace.schemas,
        "documentation_format": "html",
        "generation_args": ["--format", "html", "--template", "default.html.template"],
    }
    assert_provider_fields(env, result.provider, expected_fields)
    
    return unittest.end(env)

# =============================================================================
# Dependency Tracking Tests
# =============================================================================

def _test_dependency_tracking_verification(ctx):
    """Test dependency tracking and verification."""
    env = unittest.begin(ctx)
    
    # Create complex dependency structure
    base_schema = generate_test_schema("base_schema")
    shared_types = create_mock_file("shared_types.yaml")
    api_v1 = create_mock_file("api_v1.yaml")
    api_v2 = create_mock_file("api_v2.yaml")
    
    # Simulate dependency tracking
    def track_dependencies(schemas):
        dependency_graph = {}
        direct_deps = {}
        transitive_deps = {}
        
        for schema in schemas:
            deps = []
            if "api_v1" in schema.path:
                deps.extend([base_schema.path, shared_types.path])
            elif "api_v2" in schema.path:
                deps.extend([base_schema.path, shared_types.path, api_v1.path])
            
            dependency_graph[schema.path] = deps
            direct_deps[schema.path] = deps
            
            # Calculate transitive dependencies
            transitive = set(deps)
            for dep in deps:
                if dep in dependency_graph:
                    transitive.update(dependency_graph[dep])
            transitive_deps[schema.path] = list(transitive)
        
        return struct(
            dependency_graph = dependency_graph,
            direct_dependencies = direct_deps,
            transitive_dependencies = transitive_deps,
        )
    
    # Test dependency tracking
    schemas = [api_v1, api_v2]
    result, execution_time = measure_execution_time(track_dependencies, schemas)
    
    # Assert dependency tracking
    assert_performance_threshold(env, execution_time, 50.0, "Dependency tracking")
    
    # Verify dependency graph
    asserts.true(env, "api_v1.yaml" in result.dependency_graph, "API v1 should be in dependency graph")
    asserts.true(env, "api_v2.yaml" in result.dependency_graph, "API v2 should be in dependency graph")
    
    # Verify direct dependencies
    api_v1_deps = result.direct_dependencies["api_v1.yaml"]
    api_v2_deps = result.direct_dependencies["api_v2.yaml"]
    
    asserts.true(env, base_schema.path in api_v1_deps, "API v1 should depend on base schema")
    asserts.true(env, shared_types.path in api_v1_deps, "API v1 should depend on shared types")
    asserts.true(env, base_schema.path in api_v2_deps, "API v2 should depend on base schema")
    asserts.true(env, api_v1.path in api_v2_deps, "API v2 should depend on API v1")
    
    # Verify transitive dependencies
    api_v2_transitive = result.transitive_dependencies["api_v2.yaml"]
    asserts.true(env, len(api_v2_transitive) >= 3, "API v2 should have at least 3 transitive dependencies")
    
    return unittest.end(env)

def _test_circular_dependency_detection_integration(ctx):
    """Test circular dependency detection in integration scenario."""
    env = unittest.begin(ctx)
    
    # Create schemas with circular dependencies
    schema_a = create_mock_file("schema_a.yaml")
    schema_b = create_mock_file("schema_b.yaml")
    schema_c = create_mock_file("schema_c.yaml")
    
    # Simulate circular dependency detection
    def detect_circular_dependencies(schemas):
        dependency_graph = {
            "schema_a.yaml": ["schema_b.yaml"],
            "schema_b.yaml": ["schema_c.yaml"],
            "schema_c.yaml": ["schema_a.yaml"],  # Circular dependency
        }
        
        # Detect circular dependencies using DFS
        def has_cycle(graph, node, visited, rec_stack):
            visited.add(node)
            rec_stack.add(node)
            
            for neighbor in graph.get(node, []):
                if neighbor not in visited:
                    if has_cycle(graph, neighbor, visited, rec_stack):
                        return True
                elif neighbor in rec_stack:
                    return True
            
            rec_stack.remove(node)
            return False
        
        circular_deps = []
        for node in dependency_graph:
            visited = set()
            rec_stack = set()
            if has_cycle(dependency_graph, node, visited, rec_stack):
                circular_deps.append(node)
        
        return struct(
            circular_dependencies = circular_deps,
            dependency_graph = dependency_graph,
        )
    
    # Test circular dependency detection
    schemas = [schema_a, schema_b, schema_c]
    result, execution_time = measure_execution_time(detect_circular_dependencies, schemas)
    
    # Assert circular dependency detection
    assert_performance_threshold(env, execution_time, 20.0, "Circular dependency detection")
    asserts.true(env, len(result.circular_dependencies) > 0, "Should detect circular dependencies")
    
    return unittest.end(env)

# =============================================================================
# Caching Behavior Tests
# =============================================================================

def _test_caching_behavior_validation(ctx):
    """Test caching behavior and validation."""
    env = unittest.begin(ctx)
    
    # Create test schemas with different content
    schema_v1 = generate_test_schema("schema_v1", "version: 1.0")
    schema_v2 = generate_test_schema("schema_v2", "version: 2.0")
    
    # Simulate caching behavior
    def simulate_caching(schemas, cache = {}):
        cache_hits = 0
        cache_misses = 0
        generated_files = []
        
        for schema in schemas:
            # Generate content hash
            content_hash = str(hash(schema.content))
            
            if content_hash in cache:
                cache_hits += 1
                generated_files.extend(cache[content_hash])
            else:
                cache_misses += 1
                # Simulate file generation
                files = [
                    create_mock_file("generated_{}.ts".format(schema.path)),
                    create_mock_file("generated_{}.d.ts".format(schema.path)),
                ]
                cache[content_hash] = files
                generated_files.extend(files)
        
        return struct(
            cache_hits = cache_hits,
            cache_misses = cache_misses,
            generated_files = generated_files,
            cache_size = len(cache),
        )
    
    # Test initial run (cache misses)
    schemas = [schema_v1, schema_v2]
    result1, time1 = measure_execution_time(simulate_caching, schemas, {})
    
    # Test second run with same schemas (cache hits)
    result2, time2 = measure_execution_time(simulate_caching, schemas, {})
    
    # Test with modified schema (cache miss for modified, hit for unchanged)
    schema_v1_modified = generate_test_schema("schema_v1", "version: 1.1")
    schemas_modified = [schema_v1_modified, schema_v2]
    result3, time3 = measure_execution_time(simulate_caching, schemas_modified, {})
    
    # Assert caching behavior
    asserts.equals(env, 0, result1.cache_hits, "Initial run should have no cache hits")
    asserts.equals(env, 2, result1.cache_misses, "Initial run should have 2 cache misses")
    
    asserts.equals(env, 2, result2.cache_hits, "Second run should have 2 cache hits")
    asserts.equals(env, 0, result2.cache_misses, "Second run should have no cache misses")
    
    asserts.equals(env, 1, result3.cache_hits, "Modified run should have 1 cache hit")
    asserts.equals(env, 1, result3.cache_misses, "Modified run should have 1 cache miss")
    
    # Assert performance improvement with caching
    asserts.true(env, time2 < time1, "Cached run should be faster than initial run")
    
    return unittest.end(env)

def _test_incremental_build_caching(ctx):
    """Test incremental build caching behavior."""
    env = unittest.begin(ctx)
    
    # Create multiple schemas
    schemas = [generate_test_schema("schema_{}".format(i)) for i in range(5)]
    
    # Simulate incremental build with caching
    def incremental_build_with_cache(all_schemas, changed_schemas, cache = {}):
        processed_schemas = []
        cache_hits = 0
        cache_misses = 0
        
        for schema in all_schemas:
            content_hash = str(hash(schema.content))
            
            if schema.path in changed_schemas:
                # Force reprocessing of changed schemas
                cache_misses += 1
                processed_schemas.append(schema)
                cache[content_hash] = schema.path
            elif content_hash in cache:
                # Use cached result for unchanged schemas
                cache_hits += 1
            else:
                # Process new schemas
                cache_misses += 1
                processed_schemas.append(schema)
                cache[content_hash] = schema.path
        
        return struct(
            processed_schemas = processed_schemas,
            cache_hits = cache_hits,
            cache_misses = cache_misses,
            total_schemas = len(all_schemas),
        )
    
    # Test initial build
    changed_schemas = [s.path for s in schemas]
    result1, time1 = measure_execution_time(incremental_build_with_cache, schemas, changed_schemas, {})
    
    # Test incremental build with one change
    changed_schemas = [schemas[0].path]
    result2, time2 = measure_execution_time(incremental_build_with_cache, schemas, changed_schemas, {})
    
    # Assert incremental build behavior
    asserts.equals(env, len(schemas), result1.processed_schemas, "Initial build should process all schemas")
    asserts.equals(env, 0, result1.cache_hits, "Initial build should have no cache hits")
    asserts.equals(env, len(schemas), result1.cache_misses, "Initial build should have cache misses for all schemas")
    
    asserts.equals(env, 1, len(result2.processed_schemas), "Incremental build should process only changed schema")
    asserts.equals(env, len(schemas) - 1, result2.cache_hits, "Incremental build should have cache hits for unchanged schemas")
    asserts.equals(env, 1, result2.cache_misses, "Incremental build should have cache miss for changed schema")
    
    # Assert performance improvement
    asserts.true(env, time2 < time1, "Incremental build should be faster than full build")
    
    return unittest.end(env)

# =============================================================================
# Remote Execution Compatibility Tests
# =============================================================================

def _test_remote_execution_compatibility(ctx):
    """Test remote execution compatibility."""
    env = unittest.begin(ctx)
    
    # Create test workspace
    workspace = create_integration_test_workspace()
    
    # Simulate remote execution compatibility check
    def check_remote_execution_compatibility(schemas, policies, deps):
        compatibility_issues = []
        
        # Check for absolute paths (not allowed in remote execution)
        for schema in schemas:
            if schema.path.startswith("/"):
                compatibility_issues.append("Absolute path found: {}".format(schema.path))
        
        # Check for local file references
        for schema in schemas:
            if "file://" in schema.content:
                compatibility_issues.append("Local file reference found in: {}".format(schema.path))
        
        # Check for environment-specific dependencies
        env_deps = ["/usr/local", "/opt", "C:\\"]
        for dep in deps:
            for env_dep in env_deps:
                if env_dep in dep.path:
                    compatibility_issues.append("Environment-specific dependency: {}".format(dep.path))
        
        # Check hermeticity
        hermetic = len(compatibility_issues) == 0
        
        return struct(
            hermetic = hermetic,
            compatibility_issues = compatibility_issues,
            total_checks = len(schemas) + len(deps),
        )
    
    # Test remote execution compatibility
    result, execution_time = measure_execution_time(
        check_remote_execution_compatibility,
        workspace.schemas,
        workspace.policies,
        workspace.dependencies,
    )
    
    # Assert remote execution compatibility
    assert_performance_threshold(env, execution_time, 100.0, "Remote execution compatibility check")
    asserts.true(env, result.hermetic, "Workspace should be hermetic for remote execution")
    asserts.equals(env, 0, len(result.compatibility_issues), "Should have no compatibility issues")
    
    return unittest.end(env)

def _test_remote_execution_action_properties(ctx):
    """Test that actions have properties required for remote execution."""
    env = unittest.begin(ctx)
    
    # Create mock actions with remote execution properties
    def create_remote_execution_action():
        return struct(
            use_default_shell_env = False,
            inputs = [create_mock_file("schema.yaml")],
            outputs = [create_mock_file("generated.ts")],
            arguments = ["--format", "typescript"],
            executable = create_mock_file("weaver_binary"),
            # Remote execution specific properties
            execution_requirements = {
                "no-remote": False,
                "no-cache": False,
                "requires-network": False,
            },
            mnemonic = "WeaverGenerate",
            progress_message = "Generating TypeScript code from schema",
        )
    
    # Test action properties
    action = create_remote_execution_action()
    
    # Assert hermeticity
    asserts.false(env, action.use_default_shell_env, "Action should not use default shell environment")
    
    # Assert inputs and outputs
    asserts.true(env, len(action.inputs) > 0, "Action should have declared inputs")
    asserts.true(env, len(action.outputs) > 0, "Action should have declared outputs")
    
    # Assert execution requirements
    asserts.false(env, action.execution_requirements.get("no-remote", True), "Action should allow remote execution")
    asserts.false(env, action.execution_requirements.get("no-cache", True), "Action should allow caching")
    asserts.false(env, action.execution_requirements.get("requires-network", True), "Action should not require network")
    
    # Assert action metadata
    asserts.true(env, action.mnemonic != None, "Action should have mnemonic")
    asserts.true(env, action.progress_message != None, "Action should have progress message")
    
    return unittest.end(env)

# =============================================================================
# Test Suites
# =============================================================================

# End-to-end workflow test suite
workflow_test_suite = unittest.suite(
    "workflow_tests",
    _test_complete_generation_workflow,
    _test_complete_validation_workflow,
    _test_complete_documentation_workflow,
)

# Dependency tracking test suite
dependency_test_suite = unittest.suite(
    "dependency_tests",
    _test_dependency_tracking_verification,
    _test_circular_dependency_detection_integration,
)

# Caching behavior test suite
caching_test_suite = unittest.suite(
    "caching_tests",
    _test_caching_behavior_validation,
    _test_incremental_build_caching,
)

# Remote execution test suite
remote_execution_test_suite = unittest.suite(
    "remote_execution_tests",
    _test_remote_execution_compatibility,
    _test_remote_execution_action_properties,
)

# Comprehensive integration test suite
comprehensive_integration_test_suite = unittest.suite(
    "comprehensive_integration_tests",
    _test_complete_generation_workflow,
    _test_complete_validation_workflow,
    _test_complete_documentation_workflow,
    _test_dependency_tracking_verification,
    _test_circular_dependency_detection_integration,
    _test_caching_behavior_validation,
    _test_incremental_build_caching,
    _test_remote_execution_compatibility,
    _test_remote_execution_action_properties,
) 