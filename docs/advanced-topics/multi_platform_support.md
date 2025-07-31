# Multi-Platform Support

The OpenTelemetry Weaver rules provide comprehensive multi-platform support across Linux, macOS, and Windows with both x86_64 and ARM64 architectures.

## Supported Platforms

### Operating Systems
- **Linux**: x86_64, aarch64 (ARM64)
- **macOS**: x86_64, aarch64 (ARM64) 
- **Windows**: x86_64, aarch64 (ARM64)

### Architecture Support
- **x86_64**: Intel/AMD 64-bit processors
- **aarch64**: ARM 64-bit processors (Apple Silicon, ARM servers)

## Platform-Specific Features

### Linux Support
- **Path Handling**: Unix-style forward slashes (`/`)
- **Environment Variables**: Standard Unix environment setup
- **Shell**: Bash shell with Unix command compatibility
- **File Permissions**: Unix file permission model
- **Binary Extensions**: No executable extension required

### macOS Support
- **Path Handling**: Unix-style forward slashes (`/`)
- **Environment Variables**: macOS-specific environment setup
- **Shell**: Bash shell with macOS command compatibility
- **File Permissions**: Unix file permission model
- **Binary Extensions**: No executable extension required
- **Apple Silicon**: Native ARM64 support for M1/M2/M3 chips

### Windows Support
- **Path Handling**: Windows-style backslashes (`\`)
- **Environment Variables**: Windows-specific environment setup
- **Shell**: Command Prompt and PowerShell support
- **File Permissions**: Windows file permission model
- **Binary Extensions**: `.exe` extension for executables
- **ARM64 Support**: Native Windows ARM64 support

## Platform Detection

The rules automatically detect the current platform and architecture:

```python
# Platform detection functions
is_windows_platform(platform)    # Returns True for Windows platforms
is_linux_platform(platform)      # Returns True for Linux platforms  
is_darwin_platform(platform)     # Returns True for macOS platforms
is_arm64_architecture(platform)  # Returns True for ARM64 platforms
is_x86_64_architecture(platform) # Returns True for x86_64 platforms
```

## Platform-Specific Configuration

### Environment Variables
Each platform has specific environment variables configured:

```python
# Linux/macOS
{
    "PATH": "/usr/local/bin:/usr/bin:/bin",
    "LANG": "C.UTF-8",
    "LC_ALL": "C.UTF-8",
    "SHELL": "/bin/bash",
}

# Windows
{
    "PATH": "C:\\Windows\\System32;C:\\Windows;C:\\Windows\\System32\\Wbem",
    "LANG": "en_US.UTF-8", 
    "LC_ALL": "en_US.UTF-8",
    "SHELL": "cmd.exe",
    "COMSPEC": "C:\\Windows\\System32\\cmd.exe",
}
```

### Execution Requirements
Platform-specific execution requirements for remote execution:

```python
# Common requirements for all platforms
{
    "no-sandbox": "1",
    "supports-workers": "1", 
    "cpu-cores": "4",
    "memory": "8g",
    "cache-remote": "1",
    "cache-local": "1",
}

# Windows-specific additions
{
    "windows-compatible": "1",
}
```

## Path Handling

### Path Normalization
Paths are automatically normalized for each platform:

```python
# Unix-like systems (Linux/macOS)
normalize_path("path/to/file", "linux-x86_64")  # Returns "path/to/file"

# Windows systems
normalize_path("path/to/file", "windows-x86_64") # Returns "path\\to\\file"
```

### Binary Name Generation
Executable names are automatically adjusted for each platform:

```python
# Unix-like systems
get_platform_specific_binary_name("weaver", "linux-x86_64")  # Returns "weaver"

# Windows systems  
get_platform_specific_binary_name("weaver", "windows-x86_64") # Returns "weaver.exe"
```

## Cross-Platform Compatibility

### File Operations
All file operations are designed to work consistently across platforms:

- **Schema Loading**: Platform-agnostic schema file loading
- **Code Generation**: Consistent output regardless of platform
- **Validation**: Platform-independent validation logic
- **Documentation**: Cross-platform documentation generation

### Remote Execution
Full remote execution support across all platforms:

- **Linux**: Native remote execution support
- **macOS**: Remote execution with macOS-specific optimizations
- **Windows**: Remote execution with Windows compatibility layer

## Platform-Specific Optimizations

### Performance Optimizations
Each platform has specific performance optimizations:

- **Linux**: Optimized for Linux kernel and filesystem
- **macOS**: Optimized for macOS filesystem and security model
- **Windows**: Optimized for Windows filesystem and security model

### Memory Management
Platform-specific memory allocation and management:

- **Linux/macOS**: Unix-style memory management
- **Windows**: Windows-specific memory management

### Caching Strategies
Platform-optimized caching:

- **Linux**: Filesystem-based caching
- **macOS**: macOS-specific caching optimizations
- **Windows**: Windows filesystem caching

## Testing Multi-Platform Support

### Platform-Specific Tests
Comprehensive test suites for each platform:

```python
# Run platform-specific tests
bazel test //tests:multi_platform_test
bazel test //tests:platform_integration_test
```

### Cross-Platform Tests
Tests that verify functionality across all platforms:

```python
# Test all platforms
bazel test //tests:cross_platform_compatibility_test
```

### Platform Constraints Tests
Tests for platform constraint functionality:

```python
# Test platform constraints
bazel test //tests:platform_constraints_test
```

## Platform-Specific Considerations

### Linux Considerations
- **Filesystem**: Ext4, XFS, Btrfs support
- **Permissions**: Unix file permissions
- **Shell**: Bash, Zsh compatibility
- **Package Management**: apt, yum, pacman support

### macOS Considerations
- **Filesystem**: APFS, HFS+ support
- **Security**: Gatekeeper, SIP compatibility
- **Shell**: Bash, Zsh compatibility
- **Package Management**: Homebrew, MacPorts support

### Windows Considerations
- **Filesystem**: NTFS, ReFS support
- **Security**: Windows Defender, UAC compatibility
- **Shell**: Command Prompt, PowerShell compatibility
- **Package Management**: Chocolatey, Scoop support

## Troubleshooting

### Common Platform Issues

#### Linux Issues
- **Permission Denied**: Check file permissions and ownership
- **Missing Dependencies**: Install required system packages
- **Path Issues**: Verify PATH environment variable

#### macOS Issues
- **Gatekeeper Blocking**: Allow execution in Security & Privacy
- **Missing Xcode Tools**: Install Xcode Command Line Tools
- **Permission Issues**: Check file permissions and SIP status

#### Windows Issues
- **UAC Prompts**: Run as administrator or adjust UAC settings
- **Path Length**: Use short paths or enable long path support
- **Antivirus Interference**: Add exceptions for Bazel directories

### Platform-Specific Debugging

#### Debug Environment Variables
```python
# Print platform-specific environment variables
print(get_platform_env_vars("linux-x86_64"))
print(get_platform_env_vars("windows-x86_64"))
```

#### Debug Platform Detection
```python
# Print platform metadata
print(get_platform_metadata("darwin-aarch64"))
```

#### Debug Path Handling
```python
# Test path normalization
print(normalize_path("path/to/file", "windows-x86_64"))
```

## Best Practices

### Platform-Agnostic Code
- Use platform detection functions instead of hardcoded platform checks
- Normalize all paths using `normalize_path()`
- Use platform-specific binary names with `get_platform_specific_binary_name()`

### Testing
- Test on all supported platforms regularly
- Use platform-specific test suites
- Verify cross-platform compatibility

### Documentation
- Document platform-specific requirements
- Include platform-specific examples
- Maintain platform compatibility matrix

## Migration Guide

### From Single-Platform to Multi-Platform
1. Update platform detection logic
2. Normalize all path handling
3. Add platform-specific environment variables
4. Update execution requirements
5. Add platform-specific tests

### Platform-Specific Migrations
- **Linux to Windows**: Update path separators and binary extensions
- **x86_64 to ARM64**: Verify binary compatibility and performance
- **macOS to Linux**: Update environment variables and shell commands

## Performance Considerations

### Platform-Specific Performance
- **Linux**: Optimized for server environments
- **macOS**: Optimized for development environments
- **Windows**: Optimized for Windows development workflows

### Architecture-Specific Performance
- **x86_64**: Optimized for Intel/AMD processors
- **ARM64**: Optimized for ARM processors with native instructions

### Cross-Platform Performance
- Consistent performance across all platforms
- Platform-specific optimizations where beneficial
- Balanced approach for maximum compatibility 