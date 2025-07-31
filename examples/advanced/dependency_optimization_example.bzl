"""
Example demonstrating dependency optimization features.

This example shows how to use the dependency tracking aspects,
transitive dependency management, and change detection optimization.
"""

load("//weaver:defs.bzl", "weaver_schema", "weaver_generate")
load("//weaver:aspects.bzl", "weaver_schema_aspect", "weaver_file_group_aspect", "weaver_change_detection_aspect")

def weaver_schema_with_dependency_tracking(
        name,
        srcs,
        deps = [],
        **kwargs):
    """Create a weaver_schema target with automatic dependency tracking.
    
    This rule automatically applies the dependency tracking aspect to
    discover and track dependencies between schema files.
    
    Args:
        name: Target name
        srcs: Source schema files
        deps: Dependencies
        **kwargs: Additional arguments passed to weaver_schema
    """
    
    weaver_schema(
        name = name,
        srcs = srcs,
        deps = deps,
        **kwargs
    )

def weaver_file_group_with_optimization(
        name,
        srcs,
        **kwargs):
    """Create a file group with dependency optimization.
    
    This rule groups related schemas and enables efficient batch operations
    with optimized change detection.
    
    Args:
        name: Target name
        srcs: Source schema files
        **kwargs: Additional arguments
    """
    
    native.filegroup(
        name = name,
        srcs = srcs,
        **kwargs
    )

def weaver_schema_collection(
        name,
        schema_groups,
        deps = [],
        **kwargs):
    """Create a collection of schema groups with optimized dependency tracking.
    
    This rule creates multiple schema targets organized by groups,
    enabling efficient batch operations and group-level change detection.
    
    Args:
        name: Target name
        schema_groups: Dictionary mapping group names to lists of schema files
        deps: Dependencies
        **kwargs: Additional arguments
    """
    
    # Create individual schema targets for each group
    schema_targets = []
    for group_name, group_schemas in schema_groups.items():
        target_name = "{}_{}".format(name, group_name)
        weaver_schema_with_dependency_tracking(
            name = target_name,
            srcs = group_schemas,
            deps = deps,
            **kwargs
        )
        schema_targets.append(":{}".format(target_name))
    
    # Create a file group containing all schema targets
    native.filegroup(
        name = name,
        srcs = schema_targets,
        **kwargs
    )

def weaver_generate_with_dependency_optimization(
        name,
        schemas,
        deps = [],
        **kwargs):
    """Create a weaver_generate target with dependency optimization.
    
    This rule applies dependency tracking aspects to optimize
    incremental builds and change detection.
    
    Args:
        name: Target name
        schemas: Schema targets
        deps: Dependencies
        **kwargs: Additional arguments passed to weaver_generate
    """
    
    weaver_generate(
        name = name,
        schemas = schemas,
        deps = deps,
        **kwargs
    )

# Example usage functions
def create_optimized_schema_workflow():
    """Example workflow demonstrating dependency optimization features."""
    
    # 1. Create schema targets with automatic dependency tracking
    weaver_schema_with_dependency_tracking(
        name = "base_schemas",
        srcs = [
            "schemas/base/common.yaml",
            "schemas/base/types.yaml",
        ],
    )
    
    weaver_schema_with_dependency_tracking(
        name = "api_schemas",
        srcs = [
            "schemas/api/endpoints.yaml",
            "schemas/api/requests.yaml",
            "schemas/api/responses.yaml",
        ],
        deps = [":base_schemas"],
    )
    
    # 2. Create file groups for efficient batch operations
    weaver_file_group_with_optimization(
        name = "all_schemas",
        srcs = [
            ":base_schemas",
            ":api_schemas",
        ],
    )
    
    # 3. Create schema collections for complex scenarios
    weaver_schema_collection(
        name = "service_schemas",
        schema_groups = {
            "auth": [
                "schemas/auth/user.yaml",
                "schemas/auth/permissions.yaml",
            ],
            "data": [
                "schemas/data/models.yaml",
                "schemas/data/queries.yaml",
            ],
            "config": [
                "schemas/config/settings.yaml",
                "schemas/config/environment.yaml",
            ],
        },
        deps = [":base_schemas"],
    )
    
    # 4. Generate code with dependency optimization
    weaver_generate_with_dependency_optimization(
        name = "generated_code",
        schemas = [
            ":all_schemas",
            ":service_schemas",
        ],
    )

def create_large_scale_optimization_example():
    """Example demonstrating optimization for large-scale schema sets."""
    
    # Create multiple schema groups for different services
    services = ["user_service", "order_service", "payment_service", "inventory_service"]
    
    for service in services:
        weaver_schema_collection(
            name = "{}_schemas".format(service),
            schema_groups = {
                "models": glob(["schemas/{}/models/*.yaml".format(service)]),
                "api": glob(["schemas/{}/api/*.yaml".format(service)]),
                "events": glob(["schemas/{}/events/*.yaml".format(service)]),
            },
        )
    
    # Create a master file group for all services
    weaver_file_group_with_optimization(
        name = "all_service_schemas",
        srcs = [":{}_schemas".format(service) for service in services],
    )
    
    # Generate code for all services with dependency optimization
    weaver_generate_with_dependency_optimization(
        name = "all_generated_code",
        schemas = [":all_service_schemas"],
    ) 