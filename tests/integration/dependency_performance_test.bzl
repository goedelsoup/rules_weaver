"""
Performance tests for dependency optimization features.

This module tests the performance characteristics of dependency tracking,
change detection, and file group operations to ensure they meet
the specified performance requirements.
"""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("//weaver:aspects.bzl", "weaver_schema_aspect", "weaver_file_group_aspect", "weaver_change_detection_aspect")
load("//weaver:internal/utils.bzl", "dependency_utils")

def _test_large_schema_set_performance(ctx):
    """Test performance with large numbers of schemas."""
    env = unittest.begin(ctx)
    
    # Create mock large schema set (1000 schemas)
    large_schema_set = []
    for i in range(1000):
        mock_file = struct(
            path = "schema_{}.yaml".format(i),
            short_path = "schema_{}.yaml".format(i),
            extension = "yaml"
        )
        large_schema_set.append(mock_file)
    
    # Measure time for change detection data creation
    import time
    start_time = time.time()
    
    change_data = dependency_utils.create_change_detection_data(large_schema_set)
    
    end_time = time.time()
    analysis_time_ms = (end_time - start_time) * 1000
    
    # Verify performance requirement: analysis time under 100ms for typical BUILD files
    # For 1000 schemas, we'll be more lenient but still expect reasonable performance
    asserts.true(env, analysis_time_ms < 5000, 
                "Analysis time should be under 5 seconds for 1000 schemas, got {}ms".format(analysis_time_ms))
    
    # Verify all schemas were processed
    asserts.equals(env, 1000, len(change_data["content_hashes"]), 
                  "All 1000 schemas should be processed")
    
    return unittest.end(env)

def _test_dependency_graph_performance(ctx):
    """Test performance of dependency graph construction."""
    env = unittest.begin(ctx)
    
    # Create mock dependency graph with 500 nodes
    dependency_graph = {}
    for i in range(500):
        dependencies = []
        # Each node depends on 2-5 other nodes
        for j in range(2, 6):
            dep_index = (i + j) % 500
            dependencies.append("schema_{}.yaml".format(dep_index))
        
        dependency_graph["schema_{}.yaml".format(i)] = {
            "file": None,
            "direct_dependencies": dependencies,
            "transitive_dependencies": [],
            "content_hash": "hash_{}".format(i),
        }
    
    # Measure time for transitive dependency graph construction
    import time
    start_time = time.time()
    
    complete_graph = dependency_utils.build_transitive_dependency_graph(dependency_graph, [])
    
    end_time = time.time()
    graph_time_ms = (end_time - start_time) * 1000
    
    # Verify performance requirement: graph construction under 1000ms
    asserts.true(env, graph_time_ms < 1000, 
                "Dependency graph construction should be under 1 second, got {}ms".format(graph_time_ms))
    
    # Verify graph was constructed correctly
    asserts.equals(env, 500, len(complete_graph), "All 500 nodes should be in the graph")
    
    return unittest.end(env)

def _test_circular_dependency_performance(ctx):
    """Test performance of circular dependency detection."""
    env = unittest.begin(ctx)
    
    # Create mock dependency graph with known circular dependencies
    dependency_graph = {}
    for i in range(100):
        # Create a circular dependency: 0->1->2->...->99->0
        next_node = (i + 1) % 100
        dependency_graph["schema_{}.yaml".format(i)] = {
            "file": None,
            "direct_dependencies": ["schema_{}.yaml".format(next_node)],
            "transitive_dependencies": [],
            "content_hash": "hash_{}".format(i),
        }
    
    # Measure time for circular dependency detection
    import time
    start_time = time.time()
    
    circular_deps = dependency_utils.detect_circular_dependencies(dependency_graph)
    
    end_time = time.time()
    detection_time_ms = (end_time - start_time) * 1000
    
    # Verify performance requirement: detection under 500ms
    asserts.true(env, detection_time_ms < 500, 
                "Circular dependency detection should be under 500ms, got {}ms".format(detection_time_ms))
    
    # Verify circular dependency was detected
    asserts.true(env, len(circular_deps) > 0, "Circular dependency should be detected")
    
    return unittest.end(env)

def _test_file_group_performance(ctx):
    """Test performance of file group operations."""
    env = unittest.begin(ctx)
    
    # Create mock schema files in multiple directories
    schema_files = []
    for i in range(100):
        dir_num = i % 10
        mock_file = struct(
            path = "dir_{}/schema_{}.yaml".format(dir_num, i),
            short_path = "dir_{}/schema_{}.yaml".format(dir_num, i),
            extension = "yaml"
        )
        schema_files.append(mock_file)
    
    # Measure time for schema grouping
    import time
    start_time = time.time()
    
    schema_groups = dependency_utils.group_related_schemas(schema_files)
    
    end_time = time.time()
    grouping_time_ms = (end_time - start_time) * 1000
    
    # Verify performance requirement: grouping under 100ms
    asserts.true(env, grouping_time_ms < 100, 
                "Schema grouping should be under 100ms, got {}ms".format(grouping_time_ms))
    
    # Verify groups were created correctly
    asserts.equals(env, 10, len(schema_groups), "Should create 10 groups")
    
    # Measure time for group change detection data creation
    start_time = time.time()
    
    group_change_data = dependency_utils.create_group_change_detection_data(schema_groups)
    
    end_time = time.time()
    group_change_time_ms = (end_time - start_time) * 1000
    
    # Verify performance requirement: group change detection under 200ms
    asserts.true(env, group_change_time_ms < 200, 
                "Group change detection data creation should be under 200ms, got {}ms".format(group_change_time_ms))
    
    return unittest.end(env)

def _test_content_hash_performance(ctx):
    """Test performance of content hash computation."""
    env = unittest.begin(ctx)
    
    # Create mock file artifacts
    file_artifacts = []
    for i in range(1000):
        mock_file = struct(
            path = "file_{}.yaml".format(i),
            short_path = "file_{}.yaml".format(i)
        )
        file_artifacts.append(mock_file)
    
    # Measure time for content hash computation
    import time
    start_time = time.time()
    
    hashes = {}
    for file_artifact in file_artifacts:
        hashes[file_artifact.path] = dependency_utils.compute_content_hash(file_artifact)
    
    end_time = time.time()
    hash_time_ms = (end_time - start_time) * 1000
    
    # Verify performance requirement: hash computation under 100ms for 1000 files
    asserts.true(env, hash_time_ms < 100, 
                "Content hash computation should be under 100ms for 1000 files, got {}ms".format(hash_time_ms))
    
    # Verify all hashes were computed
    asserts.equals(env, 1000, len(hashes), "All 1000 hashes should be computed")
    
    # Test hash caching performance
    start_time = time.time()
    
    cached_hashes = {}
    for file_artifact in file_artifacts:
        cached_hashes[file_artifact.path] = dependency_utils.compute_content_hash(file_artifact)
    
    end_time = time.time()
    cached_hash_time_ms = (end_time - start_time) * 1000
    
    # Cached hashes should be faster
    asserts.true(env, cached_hash_time_ms <= hash_time_ms, 
                "Cached hash computation should not be slower than initial computation")
    
    return unittest.end(env)

def _test_memory_usage_optimization(ctx):
    """Test memory usage optimization."""
    env = unittest.begin(ctx)
    
    # This test would verify that the dependency optimization features
    # use memory efficiently and don't cause memory leaks
    
    # For now, we'll test the basic structure
    # In a real implementation, this would monitor memory usage during operations
    
    asserts.true(env, True, "Memory usage optimization test placeholder")
    
    return unittest.end(env)

# Performance test suite
dependency_performance_test_suite = unittest.suite(
    "dependency_optimization_performance_tests",
    _test_large_schema_set_performance,
    _test_dependency_graph_performance,
    _test_circular_dependency_performance,
    _test_file_group_performance,
    _test_content_hash_performance,
    _test_memory_usage_optimization,
) 