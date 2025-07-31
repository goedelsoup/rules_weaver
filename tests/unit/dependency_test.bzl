"""
Unit tests for dependency optimization features.

This module tests the dependency tracking, change detection,
and file group optimization functionality.
"""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("@rules_weaver//weaver:aspects.bzl", "weaver_schema_aspect", "weaver_file_group_aspect", "weaver_change_detection_aspect")
load("@rules_weaver//weaver:internal/utils.bzl", "dependency_utils")

def _test_transitive_dependency_tracking(ctx):
    """Test transitive dependency tracking functionality."""
    env = unittest.begin(ctx)
    
    # Create mock dependency graph
    dependency_graph = {
        "schema1.yaml": {
            "file": None,  # Mock file artifact
            "direct_dependencies": ["schema2.yaml"],
            "transitive_dependencies": [],
            "content_hash": "hash1",
        },
        "schema2.yaml": {
            "file": None,
            "direct_dependencies": ["schema3.yaml"],
            "transitive_dependencies": [],
            "content_hash": "hash2",
        },
        "schema3.yaml": {
            "file": None,
            "direct_dependencies": [],
            "transitive_dependencies": [],
            "content_hash": "hash3",
        },
    }
    
    # Test transitive dependency graph building
    complete_graph = dependency_utils.build_transitive_dependency_graph(dependency_graph, [])
    
    # Verify transitive dependencies are computed correctly
    asserts.equals(env, ["schema2.yaml", "schema3.yaml"], complete_graph["schema1.yaml"]["transitive_dependencies"])
    asserts.equals(env, ["schema3.yaml"], complete_graph["schema2.yaml"]["transitive_dependencies"])
    asserts.equals(env, [], complete_graph["schema3.yaml"]["transitive_dependencies"])
    
    return unittest.end(env)

def _test_circular_dependency_detection(ctx):
    """Test circular dependency detection functionality."""
    env = unittest.begin(ctx)
    
    # Create mock dependency graph with circular dependency
    dependency_graph = {
        "schema1.yaml": {
            "file": None,
            "direct_dependencies": ["schema2.yaml"],
            "transitive_dependencies": [],
            "content_hash": "hash1",
        },
        "schema2.yaml": {
            "file": None,
            "direct_dependencies": ["schema3.yaml"],
            "transitive_dependencies": [],
            "content_hash": "hash2",
        },
        "schema3.yaml": {
            "file": None,
            "direct_dependencies": ["schema1.yaml"],  # Circular dependency
            "transitive_dependencies": [],
            "content_hash": "hash3",
        },
    }
    
    # Test circular dependency detection
    circular_deps = dependency_utils.detect_circular_dependencies(dependency_graph)
    
    # Verify circular dependency is detected
    asserts.true(env, len(circular_deps) > 0, "Circular dependency should be detected")
    
    # Verify the detected cycle contains the expected nodes
    if len(circular_deps) > 0:
        cycle = circular_deps[0]
        expected_nodes = {"schema1.yaml", "schema2.yaml", "schema3.yaml"}
        cycle_nodes = set(cycle)
        asserts.true(env, expected_nodes.issubset(cycle_nodes), "Cycle should contain expected nodes")
    
    return unittest.end(env)

def _test_change_detection_optimization(ctx):
    """Test change detection optimization functionality."""
    env = unittest.begin(ctx)
    
    # Create mock schema files
    mock_files = [
        struct(path = "schema1.yaml", short_path = "schema1.yaml", extension = "yaml"),
        struct(path = "schema2.yaml", short_path = "schema2.yaml", extension = "yaml"),
    ]
    
    # Test change detection data creation
    change_data = dependency_utils.create_change_detection_data(mock_files)
    
    # Verify change detection data structure
    asserts.true(env, "content_hashes" in change_data, "Change data should contain content hashes")
    asserts.true(env, "file_metadata" in change_data, "Change data should contain file metadata")
    asserts.true(env, "dependency_hashes" in change_data, "Change data should contain dependency hashes")
    
    # Verify content hashes are computed for all files
    for file_artifact in mock_files:
        asserts.true(env, file_artifact.path in change_data["content_hashes"], 
                    "Content hash should be computed for each file")
    
    return unittest.end(env)

def _test_file_group_operations(ctx):
    """Test file group operations functionality."""
    env = unittest.begin(ctx)
    
    # Create mock schema files in different directories
    mock_files = [
        struct(path = "dir1/schema1.yaml", short_path = "dir1/schema1.yaml", extension = "yaml"),
        struct(path = "dir1/schema2.yaml", short_path = "dir1/schema2.yaml", extension = "yaml"),
        struct(path = "dir2/schema3.yaml", short_path = "dir2/schema3.yaml", extension = "yaml"),
    ]
    
    # Test schema grouping
    schema_groups = dependency_utils.group_related_schemas(mock_files)
    
    # Verify groups are created correctly
    asserts.true(env, "dir1" in schema_groups, "Group should be created for dir1")
    asserts.true(env, "dir2" in schema_groups, "Group should be created for dir2")
    asserts.equals(env, 2, len(schema_groups["dir1"]), "dir1 should contain 2 files")
    asserts.equals(env, 1, len(schema_groups["dir2"]), "dir2 should contain 1 file")
    
    # Test group content hash computation
    group_hash = dependency_utils.compute_group_content_hash(schema_groups["dir1"])
    asserts.true(env, group_hash == None, "Group content hash should be computed")
    
    # Test group change detection data creation
    group_change_data = dependency_utils.create_group_change_detection_data(schema_groups)
    
    # Verify group change detection data structure
    asserts.true(env, "group_hashes" in group_change_data, "Group change data should contain group hashes")
    asserts.true(env, "group_metadata" in group_change_data, "Group change data should contain group metadata")
    asserts.true(env, "file_to_group_mapping" in group_change_data, "Group change data should contain file mappings")
    
    return unittest.end(env)

def _test_content_hash_caching(ctx):
    """Test content hash caching functionality."""
    env = unittest.begin(ctx)
    
    # Create mock file artifacts
    mock_file1 = struct(path = "schema1.yaml", short_path = "schema1.yaml")
    mock_file2 = struct(path = "schema2.yaml", short_path = "schema2.yaml")
    
    # Test content hash computation
    hash1 = dependency_utils.compute_content_hash(mock_file1)
    hash2 = dependency_utils.compute_content_hash(mock_file2)
    
    # Verify hashes are computed
    asserts.true(env, hash1 != None, "Content hash should be computed for file1")
    asserts.true(env, hash2 != None, "Content hash should be computed for file2")
    asserts.true(env, hash1 != hash2, "Different files should have different hashes")
    
    # Test hash consistency
    hash1_again = dependency_utils.compute_content_hash(mock_file1)
    asserts.equals(env, hash1, hash1_again, "Content hash should be consistent for same file")
    
    return unittest.end(env)

def _test_optimized_change_detection_data(ctx):
    """Test optimized change detection data creation."""
    env = unittest.begin(ctx)
    
    # Create mock files and target label
    mock_files = [
        struct(path = "schema1.yaml", short_path = "schema1.yaml", extension = "yaml"),
        struct(path = "schema2.yaml", short_path = "schema2.yaml", extension = "yaml"),
    ]
    mock_label = struct(name = "test_target")
    
    # Test optimized change detection data creation
    change_data = dependency_utils.create_optimized_change_detection_data(
        struct(),  # Mock ctx
        mock_files,
        mock_label
    )
    
    # Verify optimized change detection data structure
    asserts.true(env, "content_hashes" in change_data, "Optimized change data should contain content hashes")
    asserts.true(env, "target_metadata" in change_data, "Optimized change data should contain target metadata")
    asserts.true(env, "dependency_hashes" in change_data, "Optimized change data should contain dependency hashes")
    asserts.true(env, "incremental_build_data" in change_data, "Optimized change data should contain incremental build data")
    
    # Verify target metadata
    target_metadata = change_data["target_metadata"]
    asserts.equals(env, "test_target", target_metadata["label"], "Target label should be recorded")
    asserts.equals(env, 2, target_metadata["file_count"], "File count should be recorded")
    
    return unittest.end(env)

# Test suite
dependency_test_suite = unittest.suite(
    "dependency_optimization_tests",
    _test_transitive_dependency_tracking,
    _test_circular_dependency_detection,
    _test_change_detection_optimization,
    _test_file_group_operations,
    _test_content_hash_caching,
    _test_optimized_change_detection_data,
) 