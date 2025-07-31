workspace(name = "rules_weaver")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# Load bazel_skylib for testing
http_archive(
    name = "bazel_skylib",
    sha256 = "66ffd9315665bfaafc96b52278f57c7e2dd09f5ede279ea6d39b2be471e7e3aa",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.4.2/bazel-skylib-1.4.2.tar.gz",
        "https://github.com/bazelbuild/bazel-skylib/releases/download/1.4.2/bazel-skylib-1.4.2.tar.gz",
    ],
)

# Load the rules_weaver repository
local_repository(
    name = "rules_weaver",
    path = ".",
)

# Load weaver repository rules
load("@rules_weaver//weaver:repositories.bzl", "weaver_dependencies", "weaver_repository", "weaver_register_toolchains")

# Set up Weaver dependencies
weaver_dependencies()

# Real Weaver repository for integration testing
# This downloads the actual Weaver binary from GitHub releases
weaver_repository(
    name = "real_weaver",
    version = "0.16.1",  # Latest stable version
    # Note: SHA256 will be computed automatically if not provided
)

# Register toolchains for real Weaver
weaver_register_toolchains()

# Additional Weaver repositories for different versions (optional)
# weaver_repository(
#     name = "weaver_latest",
#     version = "0.16.1",
# )

# weaver_repository(
#     name = "weaver_stable",
#     version = "0.15.0",
# ) 