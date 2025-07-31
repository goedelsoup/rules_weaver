"""
Dependency optimization utilities for OpenTelemetry Weaver rules.

This module provides utilities for transitive dependency tracking,
change detection optimization, and file group operations.
"""

load("@bazel_skylib//lib:paths.bzl", "paths")
load("//weaver:platform_constraints.bzl", "get_execution_requirements")

# Content hash cache for efficient change detection
_content_hash_cache = {}

def _compute_content_hash(file_artifact):
    """Compute a content hash for efficient change detection.
    
    Args:
        file_artifact: File artifact to hash
    
    Returns:
        Content hash string
    """
    # Use file path and modification time as a simple hash
    # In a real implementation, this would compute an actual content hash
    return str(hash(file_artifact.path + str(file_artifact.short_path)))

def _get_cached_content_hash(file_artifact):
    """Get cached content hash if available."""
    return _content_hash_cache.get(file_artifact.path)

def _cache_content_hash(file_artifact, content_hash):
    """Cache content hash for future use."""
    _content_hash_cache[file_artifact.path] = content_hash

def _extract_schema_dependencies(ctx, schema_file):
    """Extract dependencies from schema files.
    
    Args:
        ctx: The rule context
        schema_file: Schema file artifact
    
    Returns:
        List of dependency file paths
    """
    # This is a simplified implementation
    # In practice, this would parse the schema content and extract imports/references
    dependencies = []
    
    # For now, return empty list - this would be implemented with actual schema parsing
    return dependencies

def _build_transitive_dependency_graph(dependency_graph, transitive_deps):
    """Build complete transitive dependency graph.
    
    Args:
        dependency_graph: Direct dependency graph
        transitive_deps: List of transitive dependency providers
    
    Returns:
        Complete dependency graph with transitive dependencies
    """
    complete_graph = dependency_graph.copy()
    
    # Add transitive dependencies to the graph
    for dep_provider in transitive_deps:
        if hasattr(dep_provider, "dependency_graph"):
            complete_graph.update(dep_provider.dependency_graph)
    
    # Compute transitive closure for each node
    for node_path, node_data in complete_graph.items():
        transitive_deps = set()
        visited = set()
        
        def _compute_transitive_closure(current_path):
            if current_path in visited:
                return
            visited.add(current_path)
            
            if current_path in complete_graph:
                for dep in complete_graph[current_path].get("direct_dependencies", []):
                    transitive_deps.add(dep)
                    _compute_transitive_closure(dep)
        
        _compute_transitive_closure(node_path)
        node_data["transitive_dependencies"] = list(transitive_deps)
    
    return complete_graph

def _detect_circular_dependencies(dependency_graph):
    """Detect circular dependencies in the dependency graph.
    
    Args:
        dependency_graph: Complete dependency graph
    
    Returns:
        List of circular dependency cycles
    """
    circular_deps = []
    visited = set()
    recursion_stack = set()
    
    def _dfs_detect_cycles(node_path, path):
        if node_path in recursion_stack:
            # Found a cycle
            cycle_start = path.index(node_path)
            cycle = path[cycle_start:] + [node_path]
            circular_deps.append(cycle)
            return
        
        if node_path in visited:
            return
        
        visited.add(node_path)
        recursion_stack.add(node_path)
        
        if node_path in dependency_graph:
            for dep in dependency_graph[node_path].get("direct_dependencies", []):
                _dfs_detect_cycles(dep, path + [node_path])
        
        recursion_stack.remove(node_path)
    
    for node_path in dependency_graph:
        if node_path not in visited:
            _dfs_detect_cycles(node_path, [])
    
    return circular_deps

def _create_change_detection_data(schema_files):
    """Create optimized change detection data for schema files.
    
    Args:
        schema_files: List of schema file artifacts
    
    Returns:
        Change detection data structure
    """
    change_data = {
        "content_hashes": {},
        "file_metadata": {},
        "dependency_hashes": {},
    }
    
    for schema_file in schema_files:
        content_hash = _compute_content_hash(schema_file)
        change_data["content_hashes"][schema_file.path] = content_hash
        change_data["file_metadata"][schema_file.path] = {
            "path": schema_file.path,
            "short_path": schema_file.short_path,
            "extension": schema_file.extension,
        }
    
    return change_data

def _group_related_schemas(schema_files):
    """Group related schemas for efficient batch operations.
    
    Args:
        schema_files: List of schema file artifacts
    
    Returns:
        Dictionary mapping group names to lists of related schema files
    """
    schema_groups = {}
    
    # Group by directory structure
    for schema_file in schema_files:
        dir_path = paths.dirname(schema_file.short_path)
        if dir_path not in schema_groups:
            schema_groups[dir_path] = []
        schema_groups[dir_path].append(schema_file)
    
    return schema_groups

def _extract_group_dependencies(ctx, group_files):
    """Extract dependencies for a group of schema files.
    
    Args:
        ctx: The rule context
        group_files: List of schema files in the group
    
    Returns:
        List of group dependencies
    """
    group_deps = []
    
    for schema_file in group_files:
        deps = _extract_schema_dependencies(ctx, schema_file)
        group_deps.extend(deps)
    
    return list(set(group_deps))  # Remove duplicates

def _compute_group_content_hash(group_files):
    """Compute content hash for a group of files.
    
    Args:
        group_files: List of file artifacts in the group
    
    Returns:
        Combined content hash for the group
    """
    # Combine individual file hashes
    combined_hash = ""
    for file_artifact in sorted(group_files, key=lambda f: f.path):
        combined_hash += _compute_content_hash(file_artifact)
    
    return str(hash(combined_hash))

def _create_group_change_detection_data(schema_groups):
    """Create change detection data for schema groups.
    
    Args:
        schema_groups: Dictionary of schema groups
    
    Returns:
        Group-level change detection data
    """
    group_change_data = {
        "group_hashes": {},
        "group_metadata": {},
        "file_to_group_mapping": {},
    }
    
    for group_name, group_files in schema_groups.items():
        group_hash = _compute_group_content_hash(group_files)
        group_change_data["group_hashes"][group_name] = group_hash
        group_change_data["group_metadata"][group_name] = {
            "file_count": len(group_files),
            "files": [f.path for f in group_files],
        }
        
        for file_artifact in group_files:
            group_change_data["file_to_group_mapping"][file_artifact.path] = group_name
    
    return group_change_data

def _create_optimized_change_detection_data(ctx, all_files, target_label):
    """Create optimized change detection data for a target.
    
    Args:
        ctx: The rule context
        all_files: List of all file artifacts
        target_label: Target label
    
    Returns:
        Optimized change detection data
    """
    change_data = {
        "content_hashes": {},
        "target_metadata": {
            "label": str(target_label),
            "file_count": len(all_files),
        },
        "dependency_hashes": {},
        "incremental_build_data": {},
    }
    
    # Compute content hashes for all files
    for file_artifact in all_files:
        content_hash = _compute_content_hash(file_artifact)
        change_data["content_hashes"][file_artifact.path] = content_hash
    
    # Create incremental build data
    change_data["incremental_build_data"] = {
        "last_build_hash": str(hash(str(change_data["content_hashes"]))),
        "build_timestamp": "timestamp_placeholder",  # Would be actual timestamp
        "changed_files": [],  # Would be populated during build
    }
    
    return change_data

# Public API for dependency utilities
dependency_utils = struct(
    compute_content_hash = _compute_content_hash,
    extract_schema_dependencies = _extract_schema_dependencies,
    build_transitive_dependency_graph = _build_transitive_dependency_graph,
    detect_circular_dependencies = _detect_circular_dependencies,
    create_change_detection_data = _create_change_detection_data,
    group_related_schemas = _group_related_schemas,
    extract_group_dependencies = _extract_group_dependencies,
    compute_group_content_hash = _compute_group_content_hash,
    create_group_change_detection_data = _create_group_change_detection_data,
    create_optimized_change_detection_data = _create_optimized_change_detection_data,
) 