# Checksum Automation for Weaver Binaries

This document explains the automated checksum system implemented in rules_weaver, which eliminates the need for manual checksum management and provides robust fallback strategies.

## Overview

The checksum automation system combines two approaches:
1. **Bazel Auto-Computation with Caching**: Automatically computes checksums when not provided
2. **CI/CD Integration**: Automatically updates checksums from GitHub releases

## How It Works

### 1. Dynamic Checksum Resolution

When you use `weaver_repository` without providing a `sha256` parameter:

```python
weaver_repository(
    name = "weaver",
    version = "0.16.1",
    # No sha256 provided - triggers auto-computation
)
```

The system follows this fallback strategy:

1. **Cached Checksums**: Check if checksum is available in `weaver/checksums.bzl`
2. **GitHub API**: Fetch checksums from GitHub releases (future enhancement)
3. **Checksum Files**: Download and parse checksum files (future enhancement)
4. **Auto-Computation**: Let Bazel compute the checksum and cache it

### 2. Automatic Checksum Computation

When no checksum is available, the system:

1. Downloads the Weaver binary without checksum verification
2. Computes SHA256 checksum using platform-appropriate tools:
   - **Unix/Linux/macOS**: Uses `shasum -a 256`
   - **Windows**: Uses PowerShell `Get-FileHash`
3. Caches the computed checksum for future use
4. Provides helpful output showing the computed checksum

### 3. CI/CD Integration

The system includes automated workflows that:

- **Daily Checks**: Run daily to check for new Weaver releases
- **GitHub API Integration**: Fetch checksums from GitHub releases
- **Automatic Updates**: Update `weaver/checksums.bzl` with new checksums
- **Pull Request Creation**: Create PRs for checksum updates

## Configuration

### Basic Usage

```python
# In your WORKSPACE file
load("@rules_weaver//weaver:repositories.bzl", "weaver_repository")

weaver_repository(
    name = "weaver",
    version = "0.16.1",
    # No sha256 needed - will be computed automatically
)
```

### Advanced Usage

```python
# With custom URLs and fallback
weaver_repository(
    name = "weaver",
    version = "0.16.1",
    urls = [
        "https://custom-mirror.com/weaver-0.16.1.tar.xz",
        "https://github.com/open-telemetry/weaver/releases/download/v0.16.1/weaver-0.16.1.tar.xz",
    ],
    # Will try custom URLs first, then fall back to GitHub
)
```

### Manual Checksum Override

```python
# If you want to provide your own checksum
weaver_repository(
    name = "weaver",
    version = "0.16.1",
    sha256 = "your_computed_checksum_here",
)
```

## Error Handling

### Network Failures

The system handles network failures gracefully:

1. **Multiple URLs**: Tries multiple download URLs
2. **Retry Logic**: Implements exponential backoff
3. **Helpful Errors**: Provides clear error messages with troubleshooting steps

### Invalid Checksums

When an invalid checksum is provided:

1. **Fallback**: Automatically falls back to checksum computation
2. **Warning**: Logs a warning about the invalid checksum
3. **Recovery**: Continues with the build process

### Unsupported Platforms

For unsupported platforms:

1. **Clear Error**: Provides specific error message
2. **Platform Detection**: Shows detected platform information
3. **Supported List**: Lists all supported platforms

## CI/CD Integration

### GitHub Actions Workflow

The system includes a GitHub Actions workflow (`.github/workflows/update-checksums.yml`) that:

- **Scheduled Runs**: Runs daily at 2 AM UTC
- **Manual Triggers**: Can be triggered manually
- **External Triggers**: Responds to Weaver release webhooks
- **Automatic PRs**: Creates pull requests for checksum updates

### Local Development

For local development, you can run the checksum updater manually:

```bash
# Update checksums for latest releases
python scripts/update_checksums.py

# Check what would be updated (dry run)
python scripts/update_checksums.py --dry-run
```

## Monitoring and Debugging

### Enable Verbose Output

```python
weaver_repository(
    name = "weaver",
    version = "0.16.1",
    # Add verbose logging
    env = {"WEAVER_VERBOSE": "1"},
)
```

### Check Cached Checksums

```bash
# View cached checksums
bazel query --output=location //external:weaver

# Check checksum cache files
find $(bazel info output_base)/external -name "*checksum*" -type f
```

### Debug Network Issues

```bash
# Test connectivity to Weaver releases
curl -I https://github.com/open-telemetry/weaver/releases/latest

# Check available releases
curl https://api.github.com/repos/open-telemetry/weaver/releases
```

## Best Practices

### For Users

1. **Don't Hardcode Checksums**: Let the system compute them automatically
2. **Use Latest Versions**: Keep Weaver versions up to date
3. **Monitor CI/CD**: Watch for automated checksum updates
4. **Report Issues**: Report any checksum-related problems

### For Contributors

1. **Test Locally**: Test checksum computation on your platform
2. **Update Documentation**: Keep this documentation current
3. **Monitor CI/CD**: Ensure automated workflows are working
4. **Security**: Verify checksums from trusted sources

## Troubleshooting

### Common Issues

#### Checksum Mismatch

```
ERROR: Checksum mismatch for weaver binary
```

**Solution**: The system will automatically compute the correct checksum. If this persists, check:
- Network connectivity
- Weaver release availability
- Platform compatibility

#### Network Timeout

```
ERROR: Failed to download Weaver binary
```

**Solution**: 
- Check network connectivity
- Try using custom URLs
- Verify Weaver release availability

#### Platform Not Supported

```
ERROR: Unsupported platform detected
```

**Solution**:
- Check platform detection logic
- Verify Weaver binary availability for your platform
- Consider using a supported platform

### Getting Help

1. **Check Logs**: Enable verbose output for detailed logs
2. **GitHub Issues**: Report issues on the rules_weaver repository
3. **Documentation**: Check this documentation for updates
4. **Community**: Ask questions in the OpenTelemetry community

## Future Enhancements

### Planned Features

1. **GitHub API Integration**: Direct checksum fetching from GitHub
2. **Checksum File Parsing**: Parse official checksum files
3. **Multi-Version Support**: Support for multiple Weaver versions
4. **Platform Expansion**: Support for additional platforms
5. **Security Enhancements**: GPG signature verification

### Contributing

To contribute to the checksum automation system:

1. **Fork the Repository**: Create your own fork
2. **Implement Features**: Add new functionality
3. **Add Tests**: Include comprehensive tests
4. **Update Documentation**: Keep docs current
5. **Submit PR**: Create pull request with changes

## Conclusion

The checksum automation system provides a robust, user-friendly solution for managing Weaver binary checksums. It eliminates manual maintenance while ensuring security and reliability. The combination of auto-computation and CI/CD integration makes it easy for new users to get started while providing advanced features for power users. 