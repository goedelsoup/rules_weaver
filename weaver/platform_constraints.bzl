"""
Platform constraints for OpenTelemetry Weaver multi-platform support.

This module defines platform constraints and execution requirements
for ensuring Weaver operations work correctly across multiple platforms
including Linux, macOS, and Windows with x86_64 and ARM64 architectures.
"""

# Platform constraint definitions for multi-platform support
PLATFORM_CONSTRAINTS = {
    "linux-x86_64": "@platforms//os:linux",
    "linux-aarch64": "@platforms//os:linux",
    "darwin-x86_64": "@platforms//os:osx",
    "darwin-aarch64": "@platforms//os:osx",
    "windows-x86_64": "@platforms//os:windows",
    "windows-aarch64": "@platforms//os:windows",  # Added Windows ARM64 support
}

# CPU constraint definitions
CPU_CONSTRAINTS = {
    "x86_64": "@platforms//cpu:x86_64",
    "aarch64": "@platforms//cpu:arm64",
}

# OS constraint definitions
OS_CONSTRAINTS = {
    "linux": "@platforms//os:linux",
    "darwin": "@platforms//os:osx",
    "windows": "@platforms//os:windows",
}

# Platform-specific path separators
PATH_SEPARATORS = {
    "linux": "/",
    "darwin": "/",
    "windows": "\\",
}

# Platform-specific executable extensions
EXECUTABLE_EXTENSIONS = {
    "linux": "",
    "darwin": "",
    "windows": ".exe",
}

# Platform-specific environment variables
PLATFORM_ENV_VARS = {
    "linux": {
        "PATH": "/usr/local/bin:/usr/bin:/bin",
        "LANG": "C.UTF-8",
        "LC_ALL": "C.UTF-8",
        "SHELL": "/bin/bash",
    },
    "darwin": {
        "PATH": "/usr/local/bin:/usr/bin:/bin",
        "LANG": "C.UTF-8",
        "LC_ALL": "C.UTF-8",
        "SHELL": "/bin/bash",
    },
    "windows": {
        "PATH": "C:\\Windows\\System32;C:\\Windows;C:\\Windows\\System32\\Wbem",
        "LANG": "en_US.UTF-8",
        "LC_ALL": "en_US.UTF-8",
        "SHELL": "cmd.exe",
        "COMSPEC": "C:\\Windows\\System32\\cmd.exe",
    },
}

# Execution requirements for remote execution optimization
REMOTE_EXECUTION_REQUIREMENTS = {
    "no-sandbox": "1",           # Allow remote execution
    "no-cache": "0",             # Allow caching for performance
    "requires-network": "0",     # No network access required
    "cpu-cores": "4",            # Request 4 CPU cores for parallel processing
    "memory": "8g",              # Request 8GB memory for large schemas
    "timeout": "300s",           # 5 minute timeout
    "cache-remote": "1",         # Enable remote caching
    "cache-local": "1",          # Enable local caching
    "supports-multiplex-sandboxing": "1",  # Support multiplex sandboxing
}

# Platform-specific execution requirements
PLATFORM_EXECUTION_REQUIREMENTS = {
    "linux-x86_64": {
        "no-sandbox": "1",
        "no-cache": "0",
        "requires-network": "0",
        "cpu-cores": "4",
        "memory": "8g",
        "timeout": "300s",
        "cache-remote": "1",
        "cache-local": "1",
        "supports-multiplex-sandboxing": "1",
        "platform": "linux-x86_64",
    },
    "linux-aarch64": {
        "no-sandbox": "1",
        "no-cache": "0",
        "requires-network": "0",
        "cpu-cores": "4",
        "memory": "8g",
        "timeout": "300s",
        "cache-remote": "1",
        "cache-local": "1",
        "supports-multiplex-sandboxing": "1",
        "platform": "linux-aarch64",
    },
    "darwin-x86_64": {
        "no-sandbox": "1",
        "no-cache": "0",
        "requires-network": "0",
        "cpu-cores": "4",
        "memory": "8g",
        "timeout": "300s",
        "cache-remote": "1",
        "cache-local": "1",
        "supports-multiplex-sandboxing": "1",
        "platform": "darwin-x86_64",
    },
    "darwin-aarch64": {
        "no-sandbox": "1",
        "no-cache": "0",
        "requires-network": "0",
        "cpu-cores": "4",
        "memory": "8g",
        "timeout": "300s",
        "cache-remote": "1",
        "cache-local": "1",
        "supports-multiplex-sandboxing": "1",
        "platform": "darwin-aarch64",
    },
    "windows-x86_64": {
        "no-sandbox": "1",
        "no-cache": "0",
        "requires-network": "0",
        "cpu-cores": "4",
        "memory": "8g",
        "timeout": "300s",
        "cache-remote": "1",
        "cache-local": "1",
        "supports-multiplex-sandboxing": "1",
        "platform": "windows-x86_64",
        "windows-compatible": "1",  # Windows-specific flag
    },
    "windows-aarch64": {
        "no-sandbox": "1",
        "no-cache": "0",
        "requires-network": "0",
        "cpu-cores": "4",
        "memory": "8g",
        "timeout": "300s",
        "cache-remote": "1",
        "cache-local": "1",
        "supports-multiplex-sandboxing": "1",
        "platform": "windows-aarch64",
        "windows-compatible": "1",  # Windows-specific flag
    },
}

def get_platform_constraint(platform):
    """Get the platform constraint for the specified platform."""
    return PLATFORM_CONSTRAINTS.get(platform)

def get_cpu_constraint(arch):
    """Get the CPU constraint for the specified architecture."""
    return CPU_CONSTRAINTS.get(arch)

def get_os_constraint(os_name):
    """Get the OS constraint for the specified operating system."""
    return OS_CONSTRAINTS.get(os_name)

def get_path_separator(platform):
    """Get the path separator for the specified platform."""
    os_name = platform.split("-")[0] if "-" in platform else platform
    return PATH_SEPARATORS.get(os_name, "/")

def get_executable_extension(platform):
    """Get the executable extension for the specified platform."""
    os_name = platform.split("-")[0] if "-" in platform else platform
    return EXECUTABLE_EXTENSIONS.get(os_name, "")

def get_platform_env_vars(platform):
    """Get platform-specific environment variables."""
    os_name = platform.split("-")[0] if "-" in platform else platform
    return PLATFORM_ENV_VARS.get(os_name, {})

def get_execution_requirements(platform = None):
    """Get execution requirements for remote execution optimization."""
    if platform and platform in PLATFORM_EXECUTION_REQUIREMENTS:
        return PLATFORM_EXECUTION_REQUIREMENTS[platform]
    return REMOTE_EXECUTION_REQUIREMENTS

def get_platform_specific_requirements(platform):
    """Get platform-specific execution requirements."""
    return PLATFORM_EXECUTION_REQUIREMENTS.get(platform, REMOTE_EXECUTION_REQUIREMENTS)

def is_remote_execution_supported(platform):
    """Check if remote execution is supported for the specified platform."""
    return platform in PLATFORM_CONSTRAINTS

def get_supported_platforms():
    """Get list of supported platforms for remote execution."""
    return list(PLATFORM_CONSTRAINTS.keys())

def get_supported_architectures():
    """Get list of supported CPU architectures."""
    return list(CPU_CONSTRAINTS.keys())

def get_supported_operating_systems():
    """Get list of supported operating systems."""
    return list(OS_CONSTRAINTS.keys())

def is_windows_platform(platform):
    """Check if the platform is Windows-based."""
    return platform.startswith("windows-")

def is_linux_platform(platform):
    """Check if the platform is Linux-based."""
    return platform.startswith("linux-")

def is_darwin_platform(platform):
    """Check if the platform is macOS-based."""
    return platform.startswith("darwin-")

def is_arm64_architecture(platform):
    """Check if the platform uses ARM64 architecture."""
    return platform.endswith("-aarch64")

def is_x86_64_architecture(platform):
    """Check if the platform uses x86_64 architecture."""
    return platform.endswith("-x86_64")

def get_platform_metadata(platform):
    """Get comprehensive metadata for the specified platform."""
    os_name = platform.split("-")[0] if "-" in platform else platform
    arch = platform.split("-")[1] if "-" in platform else None
    
    return {
        "platform": platform,
        "os_name": os_name,
        "architecture": arch,
        "os_constraint": get_platform_constraint(platform),
        "cpu_constraint": get_cpu_constraint(arch),
        "execution_requirements": get_execution_requirements(platform),
        "remote_execution_supported": is_remote_execution_supported(platform),
        "path_separator": get_path_separator(platform),
        "executable_extension": get_executable_extension(platform),
        "env_vars": get_platform_env_vars(platform),
        "is_windows": is_windows_platform(platform),
        "is_linux": is_linux_platform(platform),
        "is_darwin": is_darwin_platform(platform),
        "is_arm64": is_arm64_architecture(platform),
        "is_x86_64": is_x86_64_architecture(platform),
    }

def normalize_path(path, platform):
    """Normalize a path for the specified platform."""
    separator = get_path_separator(platform)
    if is_windows_platform(platform):
        # Convert forward slashes to backslashes on Windows
        return path.replace("/", "\\")
    else:
        # Convert backslashes to forward slashes on Unix-like systems
        return path.replace("\\", "/")

def get_platform_specific_binary_name(binary_name, platform):
    """Get platform-specific binary name with appropriate extension."""
    extension = get_executable_extension(platform)
    if extension and not binary_name.endswith(extension):
        return binary_name + extension
    return binary_name 