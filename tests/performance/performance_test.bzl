"""
Performance tests for OpenTelemetry Weaver rules.

This module contains performance benchmarks and tests to validate
the performance optimizations implemented in the Weaver rules.
"""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("@bazel_skylib//lib:new_sets.bzl", "sets")
load("//weaver:defs.bzl", "weaver_schema", "weaver_generate", "weaver_validate")
load("//weaver:providers.bzl", "WeaverSchemaInfo", "WeaverGeneratedInfo", "WeaverValidationInfo")
load("//weaver/internal:performance.bzl", "performance_utils", "PerformanceMetrics")

def _test_analysis_time_performance(ctx):
    """Test that analysis time remains under 100ms for typical BUILD files."""
    env = unittest.begin(ctx)
    
    # Create a mock context for testing analysis time
    mock_ctx = struct(
        attr = struct(
            srcs = ["schema.yaml"],
            deps = [],
            enable_performance_monitoring = True,
        ),
        label = struct(name = "test_target"),
        actions = struct(
            declare_file = lambda path: struct(path = path),
            run = lambda **kwargs: None,
            write = lambda **kwargs: None,
        ),
    )
    
    # Measure analysis time
    import time
    start_time = time.time()
    
    # Simulate analysis operations
    schema_files = performance_utils.collect_files_optimized(mock_ctx, "srcs")
    parsed_contents = performance_utils.stream_process_schemas(
        mock_ctx, 
        schema_files, 
        lambda ctx, file: struct(path = file.path + "_parsed")
    )
    
    analysis_time_ms = (time.time() - start_time) * 1000
    
    # Assert analysis time is under 100ms
    asserts.true(env, analysis_time_ms < 100, 
                "Analysis time {}ms exceeds 100ms limit".format(analysis_time_ms))
    
    return unittest.end(env)

def _test_action_execution_optimization(ctx):
    """Test that action execution is optimized with proper cache keys."""
    env = unittest.begin(ctx)
    
    # Test cache key generation
    mock_schemas = [struct(short_path = "test.yaml", path = "/path/to/test.yaml")]
    mock_args = ["--format", "typescript"]
    mock_env = {"DEBUG": "1"}
    
    cache_key = performance_utils.generate_optimized_cache_key(mock_schemas, mock_args, mock_env)
    
    # Assert cache key is generated and contains expected components
    asserts.true(env, cache_key is not None, "Cache key should not be None")
    asserts.true(env, "test.yaml" in cache_key, "Cache key should contain schema path")
    asserts.true(env, "typescript" in cache_key, "Cache key should contain arguments")
    
    return unittest.end(env)

def _test_memory_optimization(ctx):
    """Test memory optimization with streaming file processing."""
    env = unittest.begin(ctx)
    
    # Test streaming file processing
    mock_ctx = struct(
        actions = struct(
            declare_file = lambda path: struct(path = path),
            run = lambda **kwargs: None,
        ),
    )
    
    # Create mock schema files
    mock_schemas = [struct(path = "schema_{}.yaml".format(i)) for i in range(20)]
    
    # Test streaming processing
    results = performance_utils.stream_process_schemas(
        mock_ctx,
        mock_schemas,
        lambda ctx, file: struct(processed = True, file = file.path)
    )
    
    # Assert all files were processed
    asserts.true(env, len(results) == 20, "All 20 files should be processed")
    asserts.true(env, all(r.processed for r in results), "All files should be marked as processed")
    
    return unittest.end(env)

def _test_cache_efficiency(ctx):
    """Test cache efficiency with repeated operations."""
    env = unittest.begin(ctx)
    
    # Test schema caching
    mock_schema = struct(path = "test.yaml", short_path = "test.yaml")
    test_content = {"schema": "test"}
    
    # Cache schema content
    performance_utils.cache_schema(mock_schema, test_content)
    
    # Retrieve cached content
    cached_content = performance_utils.get_cached_schema(mock_schema)
    
    # Assert cache hit
    asserts.true(env, cached_content == test_content, "Cached content should match original")
    
    # Test cache miss with different schema
    different_schema = struct(path = "different.yaml", short_path = "different.yaml")
    cached_content = performance_utils.get_cached_schema(different_schema)
    
    # Assert cache miss
    asserts.true(env, cached_content is None, "Different schema should result in cache miss")
    
    return unittest.end(env)

def _test_large_schema_set_performance(ctx):
    """Test performance with large schema sets."""
    env = unittest.begin(ctx)
    
    # Simulate large schema set processing
    large_schema_count = 100
    
    # Test optimized file collection
    mock_ctx = struct(
        attr = struct(
            srcs = [struct(files = struct(to_list = lambda: [struct(path = "schema_{}.yaml".format(i)) for i in range(large_schema_count)])]
        ),
    )
    
    import time
    start_time = time.time()
    
    schema_files = performance_utils.collect_files_optimized(mock_ctx, "srcs")
    
    collection_time_ms = (time.time() - start_time) * 1000
    
    # Assert efficient collection
    asserts.true(env, len(schema_files) == large_schema_count, 
                "All {} schemas should be collected".format(large_schema_count))
    asserts.true(env, collection_time_ms < 50, 
                "Collection time {}ms should be under 50ms".format(collection_time_ms))
    
    return unittest.end(env)

def _test_performance_metrics(ctx):
    """Test performance metrics creation and monitoring."""
    env = unittest.begin(ctx)
    
    # Test metrics creation
    metrics = performance_utils.create_performance_metrics(
        analysis_time_ms = 50,
        action_time_ms = 2000,
        cache_hit_rate = 95,
        memory_usage_mb = 25,
        file_count = 10,
        schema_count = 10,
    )
    
    # Assert metrics fields
    asserts.true(env, metrics.analysis_time_ms == 50, "Analysis time should be 50ms")
    asserts.true(env, metrics.action_time_ms == 2000, "Action time should be 2000ms")
    asserts.true(env, metrics.cache_hit_rate == 95, "Cache hit rate should be 95%")
    asserts.true(env, metrics.memory_usage_mb == 25, "Memory usage should be 25MB")
    asserts.true(env, metrics.file_count == 10, "File count should be 10")
    asserts.true(env, metrics.schema_count == 10, "Schema count should be 10")
    
    return unittest.end(env)

def _test_optimized_provider_creation(ctx):
    """Test optimized provider creation with memory efficiency."""
    env = unittest.begin(ctx)
    
    # Test provider creation with None values
    test_provider = performance_utils.create_optimized_provider(
        struct,  # Mock provider class
        field1 = "value1",
        field2 = None,
        field3 = "value3",
    )
    
    # Assert None values are filtered out
    asserts.true(env, hasattr(test_provider, "field1"), "field1 should be present")
    asserts.true(env, not hasattr(test_provider, "field2"), "field2 should be filtered out")
    asserts.true(env, hasattr(test_provider, "field3"), "field3 should be present")
    
    return unittest.end(env)

# Performance test suite
weaver_performance_test_suite = unittest.suite(
    "weaver_performance_tests",
    _test_analysis_time_performance,
    _test_action_execution_optimization,
    _test_memory_optimization,
    _test_cache_efficiency,
    _test_large_schema_set_performance,
    _test_performance_metrics,
    _test_optimized_provider_creation,
) 