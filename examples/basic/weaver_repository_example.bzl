"""
Example WORKSPACE configuration for weaver_repository.

This file demonstrates how to set up Weaver in a Bazel workspace.
"""

load("@rules_weaver//weaver:repositories.bzl", "weaver_repository", "weaver_dependencies", "weaver_register_toolchains")

# Set up Weaver dependencies
weaver_dependencies()

# Download Weaver binary
weaver_repository(
    name = "weaver",
    version = "0.1.0",
    # sha256 = "abc123def4567890abcdef1234567890abcdef1234567890abcdef1234567890",  # Optional: provide SHA256 for integrity verification
    # urls = ["https://custom-url.com/weaver.tar.gz"],  # Optional: custom download URLs
    # platform_overrides = {  # Optional: platform-specific overrides
    #     "linux-x86_64": {
    #         "urls": ["https://custom-linux-url.com/weaver.tar.gz"],
    #         "sha256": "def456...",
    #     },
    #     "darwin-aarch64": {
    #         "sha256": "ghi789...",
    #     },
    # },
)

# Register Weaver toolchains
weaver_register_toolchains()

# Example usage in BUILD files:
# load("@rules_weaver//weaver:defs.bzl", "weaver_generate")
# 
# weaver_generate(
#     name = "generate_typescript",
#     srcs = ["schema.yaml"],
#     format = "typescript",
#     out_dir = "generated",
# ) 