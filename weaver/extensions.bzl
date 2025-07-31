"""
Weaver repository extension for Bzlmod.

This module provides the Weaver repository extension for downloading
and managing Weaver binaries in Bzlmod-enabled workspaces.
"""

load(":repositories.bzl", "weaver_repository")

def _weaver_repository_extension_impl(module_ctx):
    """Implementation of the Weaver repository extension."""
    
    for mod in module_ctx.modules:
        for download in mod.tags.download:
            # Create the repository for each download request
            weaver_repository(
                name = download.name,
                version = download.version,
                sha256 = getattr(download, "sha256", None),
                urls = getattr(download, "urls", None),
            )

_weaver_repository_extension = module_extension(
    implementation = _weaver_repository_extension_impl,
    tag_classes = {
        "download": tag_class(
            attrs = {
                "name": attr.string(mandatory = True),
                "version": attr.string(mandatory = True),
                "sha256": attr.string(),
                "urls": attr.string_list(),
                "platforms": attr.string_list(),
            },
        ),
    },
) 