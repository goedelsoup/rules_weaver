"""
Providers for OpenTelemetry Weaver rules.

This module defines the providers used by Weaver rules to communicate
information between rules and to external consumers.
"""

WeaverSchemaInfo = provider(
    doc = "Information about Weaver schema files",
    fields = {
        "schema_files": "List of schema file artifacts",
        "schema_content": "Parsed schema content for validation",
        "dependencies": "Transitive schema dependencies",
        "metadata": "Additional schema metadata",
    },
)

WeaverGeneratedInfo = provider(
    doc = "Information about Weaver-generated files",
    fields = {
        "generated_files": "List of generated file artifacts",
        "output_dir": "Output directory path",
        "source_registries": "Source semantic convention registries",
        "generation_args": "Arguments used for generation",
    },
)

WeaverValidationInfo = provider(
    doc = "Information about Weaver validation results",
    fields = {
        "validation_output": "Validation result file artifact",
        "validated_registries": "List of validated registry files",
        "applied_policies": "List of applied policy files",
        "validation_args": "Arguments used for validation",
        "success": "Whether validation was successful",
    },
)

WeaverDocsInfo = provider(
    doc = "Information about Weaver-generated documentation",
    fields = {
        "documentation_files": "List of generated documentation file artifacts",
        "output_dir": "Output directory path",
        "source_schemas": "Source schema files",
        "documentation_format": "Format of generated documentation",
        "documentation_args": "Arguments used for documentation generation",
    },
)

WeaverLibraryInfo = provider(
    doc = "Information about Weaver-generated libraries",
    fields = {
        "library_files": "List of generated library file artifacts",
        "output_dir": "Output directory path",
        "source_schemas": "Source schema files",
        "library_format": "Format of generated library",
        "library_args": "Arguments used for library generation",
    },
)

WeaverToolchainInfo = provider(
    doc = "Information about Weaver toolchain",
    fields = {
        "weaver_binary": "Weaver executable artifact",
        "version": "Weaver version",
        "platform": "Target platform",
    },
) 