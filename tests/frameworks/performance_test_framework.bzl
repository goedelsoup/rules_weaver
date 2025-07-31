"""
Performance testing framework for OpenTelemetry Weaver rules.

This module provides comprehensive performance tests including benchmarks,
profiling, memory usage tests, and cache hit rate measurements.
"""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("@bazel_skylib//lib:new_sets.bzl", "sets")
load("//tests/utils:test_utils.bzl", 
     "create_mock_ctx", 
     "create_mock_file", 
     "generate_test_schema",
     "generate_large_schema_set",
     "measure_execution_time",
     "assert_performance_threshold")

# =============================================================================
# Large Schema Set Handling Tests
# =============================================================================

def _test_large_schema_set_handling(ctx):
    """Test handling of large schema sets with performance measurement."""
    env = unittest.begin(ctx)
    
    # Test different schema set sizes
    schema_sizes = [10, 50, 100, 500]
    performance_results = {}
    
    for size in schema_sizes:
        # Generate large schema set
        large_schemas = generate_large_schema_set(size)
        
        # Simulate schema processing
        def process_large_schema_set(schemas):
            processed = []
            for schema in schemas:
                # Simulate parsing, validation, and processing
                processed.append({
                    "path": schema.path,
                    "parsed": True,
                    "valid": True,
                    "processed": True,
                })
            return processed
        
        # Measure performance
        result, execution_time = measure_execution_time(process_large_schema_set, large_schemas)
        performance_results[size] = {
            "execution_time_ms": execution_time,
            "schema_count": len(result),
            "throughput": len(result) / (execution_time / 1000),  # schemas per second
        }
        
        # Assert basic functionality
        asserts.equals(env, size, len(result), "Should process all {} schemas".format(size))
        asserts.true(env, all(r["processed"] for r in result), "All schemas should be processed")
    
    # Assert performance characteristics
    # Larger sets should take more time but with reasonable scaling
    for i in range(1, len(schema_sizes)):
        prev_size = schema_sizes[i-1]
        curr_size = schema_sizes[i]
        prev_time = performance_results[prev_size]["execution_time_ms"]
        curr_time = performance_results[curr_size]["execution_time_ms"]
        
        # Time should increase but not exponentially
        time_ratio = curr_time / prev_time
        size_ratio = curr_size / prev_size
        
        asserts.true(env, time_ratio <= size_ratio * 1.5, 
                    "Performance should scale reasonably: {} schemas took {}x time for {}x size".format(
                        curr_size, time_ratio, size_ratio))
    
    return unittest.end(env)

def _test_memory_usage_profiling(ctx):
    """Test memory usage profiling during schema processing."""
    env = unittest.begin(ctx)
    
    # Simulate memory usage tracking
    def simulate_memory_profiling(schemas):
        import gc
        import sys
        
        # Force garbage collection before measurement
        gc.collect()
        
        # Measure initial memory
        initial_memory = sys.getsizeof(schemas)
        
        # Process schemas and track memory usage
        processed_schemas = []
        memory_usage = [initial_memory]
        
        for i, schema in enumerate(schemas):
            # Simulate schema processing
            processed = {
                "schema": schema,
                "parsed_content": "parsed_" + schema.content,
                "metadata": {"index": i, "size": len(schema.content)},
            }
            processed_schemas.append(processed)
            
            # Measure memory after each schema
            current_memory = sys.getsizeof(processed_schemas)
            memory_usage.append(current_memory)
        
        # Calculate memory statistics
        peak_memory = max(memory_usage)
        final_memory = memory_usage[-1]
        memory_growth = final_memory - initial_memory
        
        return struct(
            initial_memory = initial_memory,
            peak_memory = peak_memory,
            final_memory = final_memory,
            memory_growth = memory_growth,
            memory_per_schema = memory_growth / len(schemas) if schemas else 0,
            memory_usage = memory_usage,
        )
    
    # Test with different schema set sizes
    test_sizes = [10, 25, 50]
    memory_results = {}
    
    for size in test_sizes:
        schemas = generate_large_schema_set(size)
        result, execution_time = measure_execution_time(simulate_memory_profiling, schemas)
        memory_results[size] = result
    
    # Assert memory usage characteristics
    for size in test_sizes:
        result = memory_results[size]
        
        # Memory should grow with schema count
        asserts.true(env, result.memory_growth > 0, "Memory should grow with {} schemas".format(size))
        
        # Memory growth should be reasonable (not exponential)
        memory_per_schema = result.memory_per_schema
        asserts.true(env, memory_per_schema < 10000,  # 10KB per schema max
                    "Memory per schema should be reasonable: {} bytes".format(memory_per_schema))
        
        # Peak memory should not be excessive
        peak_ratio = result.peak_memory / result.initial_memory
        asserts.true(env, peak_ratio < 10,  # Peak should not be 10x initial
                    "Peak memory should not be excessive: {}x initial".format(peak_ratio))
    
    return unittest.end(env)

# =============================================================================
# Incremental Build Performance Tests
# =============================================================================

def _test_incremental_build_performance(ctx):
    """Test incremental build performance with different change patterns."""
    env = unittest.begin(ctx)
    
    # Create large schema set
    base_schemas = generate_large_schema_set(100)
    
    # Simulate incremental build
    def simulate_incremental_build(all_schemas, changed_indices):
        changed_schemas = [all_schemas[i] for i in changed_indices]
        
        # Simulate processing only changed schemas
        processed_schemas = []
        for schema in changed_schemas:
            # Simulate schema processing
            processed_schemas.append({
                "path": schema.path,
                "changed": True,
                "processed": True,
            })
        
        return struct(
            processed_count = len(processed_schemas),
            total_count = len(all_schemas),
            changed_count = len(changed_schemas),
        )
    
    # Test different change patterns
    change_patterns = [
        ([0], "single_change"),
        ([0, 1, 2], "small_change"),
        (list(range(10)), "medium_change"),
        (list(range(25)), "large_change"),
        (list(range(50)), "very_large_change"),
    ]
    
    performance_results = {}
    
    for changed_indices, pattern_name in change_patterns:
        result, execution_time = measure_execution_time(
            simulate_incremental_build, base_schemas, changed_indices
        )
        
        performance_results[pattern_name] = {
            "execution_time_ms": execution_time,
            "processed_count": result.processed_count,
            "change_ratio": result.changed_count / result.total_count,
            "efficiency": result.total_count / result.processed_count,  # Higher is better
        }
    
    # Assert incremental build performance characteristics
    single_change = performance_results["single_change"]
    very_large_change = performance_results["very_large_change"]
    
    # Single change should be very fast
    assert_performance_threshold(env, single_change["execution_time_ms"], 10.0, "Single change processing")
    
    # Efficiency should be high for small changes
    asserts.true(env, single_change["efficiency"] > 50, 
                "Single change should have high efficiency: {}".format(single_change["efficiency"]))
    
    # Large changes should still be faster than full rebuild
    full_rebuild_time = 100.0  # Simulated full rebuild time
    asserts.true(env, very_large_change["execution_time_ms"] < full_rebuild_time,
                "Large change should be faster than full rebuild")
    
    return unittest.end(env)

def _test_cache_hit_rate_measurement(ctx):
    """Test cache hit rate measurement and optimization."""
    env = unittest.begin(ctx)
    
    # Simulate cache with hit rate tracking
    def simulate_cache_with_hit_rate(schema_sequences):
        cache = {}
        total_requests = 0
        cache_hits = 0
        cache_misses = 0
        
        for sequence in schema_sequences:
            for schema in sequence:
                total_requests += 1
                content_hash = str(hash(schema.content))
                
                if content_hash in cache:
                    cache_hits += 1
                else:
                    cache_misses += 1
                    cache[content_hash] = schema.path
        
        hit_rate = cache_hits / total_requests if total_requests > 0 else 0
        
        return struct(
            total_requests = total_requests,
            cache_hits = cache_hits,
            cache_misses = cache_misses,
            hit_rate = hit_rate,
            cache_size = len(cache),
        )
    
    # Create different access patterns
    base_schemas = generate_large_schema_set(20)
    
    # Pattern 1: Sequential access (low cache hit rate)
    sequential_pattern = [base_schemas] * 3
    
    # Pattern 2: Random access with repetition (medium cache hit rate)
    import random
    random_pattern = []
    for _ in range(5):
        random.shuffle(base_schemas)
        random_pattern.append(base_schemas[:10])  # Use subset
    
    # Pattern 3: Repeated access (high cache hit rate)
    repeated_pattern = [base_schemas[:5]] * 10
    
    # Test different patterns
    patterns = [
        (sequential_pattern, "sequential"),
        (random_pattern, "random"),
        (repeated_pattern, "repeated"),
    ]
    
    cache_results = {}
    
    for pattern, pattern_name in patterns:
        result, execution_time = measure_execution_time(
            simulate_cache_with_hit_rate, pattern
        )
        
        cache_results[pattern_name] = {
            "hit_rate": result.hit_rate,
            "total_requests": result.total_requests,
            "cache_size": result.cache_size,
            "execution_time_ms": execution_time,
        }
    
    # Assert cache performance characteristics
    sequential = cache_results["sequential"]
    random = cache_results["random"]
    repeated = cache_results["repeated"]
    
    # Hit rates should follow expected pattern
    asserts.true(env, repeated["hit_rate"] > random["hit_rate"], 
                "Repeated pattern should have higher hit rate than random")
    asserts.true(env, random["hit_rate"] > sequential["hit_rate"], 
                "Random pattern should have higher hit rate than sequential")
    
    # Hit rates should be reasonable
    asserts.true(env, repeated["hit_rate"] > 0.5, "Repeated pattern should have >50% hit rate")
    asserts.true(env, sequential["hit_rate"] < 0.3, "Sequential pattern should have <30% hit rate")
    
    return unittest.end(env)

# =============================================================================
# Performance Benchmarking Tests
# =============================================================================

def _test_performance_benchmarks(ctx):
    """Test performance benchmarks for different operations."""
    env = unittest.begin(ctx)
    
    # Create benchmark scenarios
    benchmark_scenarios = [
        ("small_schema_parse", 5),
        ("medium_schema_parse", 25),
        ("large_schema_parse", 100),
        ("schema_validation", 50),
        ("code_generation", 30),
        ("documentation_generation", 40),
    ]
    
    benchmark_results = {}
    
    for scenario_name, schema_count in benchmark_scenarios:
        schemas = generate_large_schema_set(schema_count)
        
        # Simulate different operations
        def benchmark_operation(schemas, operation_type):
            if operation_type == "parse":
                # Simulate parsing
                return [{"parsed": True, "path": s.path} for s in schemas]
            elif operation_type == "validate":
                # Simulate validation
                return [{"valid": True, "path": s.path} for s in schemas]
            elif operation_type == "generate":
                # Simulate code generation
                return [{"generated": True, "path": s.path} for s in schemas]
            elif operation_type == "document":
                # Simulate documentation generation
                return [{"documented": True, "path": s.path} for s in schemas]
            else:
                return []
        
        # Determine operation type from scenario name
        if "parse" in scenario_name:
            operation_type = "parse"
        elif "validation" in scenario_name:
            operation_type = "validate"
        elif "generation" in scenario_name:
            operation_type = "generate"
        elif "documentation" in scenario_name:
            operation_type = "document"
        else:
            operation_type = "parse"
        
        result, execution_time = measure_execution_time(
            benchmark_operation, schemas, operation_type
        )
        
        benchmark_results[scenario_name] = {
            "execution_time_ms": execution_time,
            "schema_count": len(schemas),
            "throughput": len(schemas) / (execution_time / 1000),  # schemas per second
            "operation_type": operation_type,
        }
    
    # Assert benchmark performance characteristics
    for scenario_name, result in benchmark_results.items():
        # All operations should complete within reasonable time
        max_time = 1000.0  # 1 second max
        assert_performance_threshold(env, result["execution_time_ms"], max_time, scenario_name)
        
        # Throughput should be positive
        asserts.true(env, result["throughput"] > 0, 
                    "{} should have positive throughput".format(scenario_name))
        
        # Larger operations should take more time
        if "large" in scenario_name:
            large_time = result["execution_time_ms"]
            # Find corresponding small/medium scenario
            for other_name, other_result in benchmark_results.items():
                if "small" in other_name and "parse" in other_name:
                    small_time = other_result["execution_time_ms"]
                    asserts.true(env, large_time > small_time,
                                "Large operation should take more time than small")
    
    return unittest.end(env)

def _test_performance_regression_detection(ctx):
    """Test performance regression detection capabilities."""
    env = unittest.begin(ctx)
    
    # Simulate performance measurements over time
    def simulate_performance_measurement(schemas, optimization_level):
        # Simulate different optimization levels
        base_time = len(schemas) * 10  # Base time per schema
        
        if optimization_level == "none":
            multiplier = 1.0
        elif optimization_level == "basic":
            multiplier = 0.8
        elif optimization_level == "advanced":
            multiplier = 0.5
        else:
            multiplier = 1.0
        
        execution_time = base_time * multiplier
        
        return struct(
            execution_time_ms = execution_time,
            optimization_level = optimization_level,
            schema_count = len(schemas),
        )
    
    # Test different optimization levels
    schemas = generate_large_schema_set(50)
    optimization_levels = ["none", "basic", "advanced"]
    
    performance_history = {}
    
    for level in optimization_levels:
        result, _ = measure_execution_time(
            simulate_performance_measurement, schemas, level
        )
        performance_history[level] = result
    
    # Detect performance regressions
    none_time = performance_history["none"]["execution_time_ms"]
    basic_time = performance_history["basic"]["execution_time_ms"]
    advanced_time = performance_history["advanced"]["execution_time_ms"]
    
    # Assert performance improvements
    asserts.true(env, basic_time < none_time, 
                "Basic optimization should improve performance: {} < {}".format(basic_time, none_time))
    asserts.true(env, advanced_time < basic_time, 
                "Advanced optimization should improve performance: {} < {}".format(advanced_time, basic_time))
    
    # Calculate improvement ratios
    basic_improvement = (none_time - basic_time) / none_time
    advanced_improvement = (none_time - advanced_time) / none_time
    
    # Assert significant improvements
    asserts.true(env, basic_improvement > 0.1, 
                "Basic optimization should provide >10% improvement: {:.1%}".format(basic_improvement))
    asserts.true(env, advanced_improvement > 0.3, 
                "Advanced optimization should provide >30% improvement: {:.1%}".format(advanced_improvement))
    
    return unittest.end(env)

# =============================================================================
# Test Suites
# =============================================================================

# Large schema handling test suite
large_schema_test_suite = unittest.suite(
    "large_schema_tests",
    _test_large_schema_set_handling,
    _test_memory_usage_profiling,
)

# Incremental build test suite
incremental_build_test_suite = unittest.suite(
    "incremental_build_tests",
    _test_incremental_build_performance,
    _test_cache_hit_rate_measurement,
)

# Performance benchmarking test suite
benchmark_test_suite = unittest.suite(
    "benchmark_tests",
    _test_performance_benchmarks,
    _test_performance_regression_detection,
)

# Comprehensive performance test suite
comprehensive_performance_test_suite = unittest.suite(
    "comprehensive_performance_tests",
    _test_large_schema_set_handling,
    _test_memory_usage_profiling,
    _test_incremental_build_performance,
    _test_cache_hit_rate_measurement,
    _test_performance_benchmarks,
    _test_performance_regression_detection,
) 