"""
Aspect implementations for OpenTelemetry Weaver dependency tracking.

This module provides aspects for automatic dependency discovery,
transitive dependency tracking, and change detection optimization.
"""

load(":providers.bzl", "WeaverSchemaInfo", "WeaverDependencyInfo")
load(":internal/utils.bzl", "dependency_utils")
load("@bazel_skylib//lib:paths.bzl", "paths")

def _weaver_schema_aspect_impl(target, ctx):
    """Aspect implementation for automatic schema dependency tracking.
    
    This aspect automatically discovers and tracks dependencies between
    schema files, building a transitive dependency graph for efficient
    change detection and incremental builds.
    """
    
    # Collect schema files from the target
    schema_files = []
    if hasattr(target, "files"):
        schema_files = [f for f in target.files.to_list() if f.extension in ["yaml", "yml", "json"]]
    
    # Extract direct dependencies from schema content
    direct_deps = []
    dependency_graph = {}
    
    for schema_file in schema_files:
        # Extract dependencies using the utility function
        deps = dependency_utils.extract_schema_dependencies(ctx, schema_file)
        direct_deps.extend(deps)
        
        # Build dependency graph entry
        dependency_graph[schema_file.path] = {
            "file": schema_file,
            "direct_dependencies": deps,
            "transitive_dependencies": [],
            "content_hash": dependency_utils.compute_content_hash(schema_file),
        }
    
    # Collect transitive dependencies from dependencies
    transitive_deps = []
    for dep in ctx.rule.attr.deps:
        if hasattr(dep, "weaver_schema_info"):
            transitive_deps.append(dep.weaver_schema_info)
        if hasattr(dep, "weaver_dependency_info"):
            transitive_deps.append(dep.weaver_dependency_info)
    
    # Build complete transitive dependency graph
    complete_graph = dependency_utils.build_transitive_dependency_graph(
        dependency_graph,
        transitive_deps
    )
    
    # Detect circular dependencies
    circular_deps = dependency_utils.detect_circular_dependencies(complete_graph)
    
    # Create dependency info provider
    dependency_info = WeaverDependencyInfo(
        direct_dependencies = direct_deps,
        transitive_dependencies = transitive_deps,
        dependency_graph = complete_graph,
        circular_dependencies = circular_deps,
        content_hashes = {f.path: dependency_utils.compute_content_hash(f) for f in schema_files},
        change_detection_data = dependency_utils.create_change_detection_data(schema_files),
    )
    
    return [dependency_info]

# Aspect definition for automatic dependency tracking
weaver_schema_aspect = aspect(
    implementation = _weaver_schema_aspect_impl,
    attr_aspects = ["deps"],
    attrs = {
        "_dependency_utils": attr.label(
            default = "//weaver:internal/utils.bzl",
            allow_single_file = True,
        ),
    },
    doc = "Aspect for automatic schema dependency tracking and change detection optimization",
)

def _weaver_file_group_aspect_impl(target, ctx):
    """Aspect implementation for file group dependency tracking.
    
    This aspect tracks dependencies for file groups containing related schemas,
    enabling efficient batch operations and group-level change detection.
    """
    
    # Collect all schema files in the file group
    schema_files = []
    if hasattr(target, "files"):
        schema_files = [f for f in target.files.to_list() if f.extension in ["yaml", "yml", "json"]]
    
    # Group schemas by related collections
    schema_groups = dependency_utils.group_related_schemas(schema_files)
    
    # Build group-level dependency information
    group_deps = {}
    for group_name, group_files in schema_groups.items():
        group_deps[group_name] = {
            "files": group_files,
            "dependencies": dependency_utils.extract_group_dependencies(ctx, group_files),
            "content_hash": dependency_utils.compute_group_content_hash(group_files),
        }
    
    # Create file group dependency info
    file_group_info = WeaverDependencyInfo(
        direct_dependencies = [],
        transitive_dependencies = [],
        dependency_graph = group_deps,
        circular_dependencies = [],
        content_hashes = {f.path: dependency_utils.compute_content_hash(f) for f in schema_files},
        change_detection_data = dependency_utils.create_group_change_detection_data(schema_groups),
    )
    
    return [file_group_info]

# Aspect definition for file group dependency tracking
weaver_file_group_aspect = aspect(
    implementation = _weaver_file_group_aspect_impl,
    attr_aspects = ["srcs"],
    attrs = {
        "_dependency_utils": attr.label(
            default = "//weaver:internal/utils.bzl",
            allow_single_file = True,
        ),
    },
    doc = "Aspect for file group dependency tracking and batch operation optimization",
)

def _weaver_change_detection_aspect_impl(target, ctx):
    """Aspect implementation for optimized change detection.
    
    This aspect provides efficient change detection by tracking content hashes
    and dependency relationships for incremental build optimization.
    """
    
    # Collect all relevant files
    all_files = []
    if hasattr(target, "files"):
        all_files = target.files.to_list()
    
    # Create optimized change detection data
    change_data = dependency_utils.create_optimized_change_detection_data(
        ctx,
        all_files,
        target.label
    )
    
    # Create change detection info
    change_info = WeaverDependencyInfo(
        direct_dependencies = [],
        transitive_dependencies = [],
        dependency_graph = {},
        circular_dependencies = [],
        content_hashes = change_data["content_hashes"],
        change_detection_data = change_data,
    )
    
    return [change_info]

# Aspect definition for change detection optimization
weaver_change_detection_aspect = aspect(
    implementation = _weaver_change_detection_aspect_impl,
    attr_aspects = ["deps", "srcs"],
    attrs = {
        "_dependency_utils": attr.label(
            default = "//weaver:internal/utils.bzl",
            allow_single_file = True,
        ),
    },
    doc = "Aspect for optimized change detection and incremental build support",
) 