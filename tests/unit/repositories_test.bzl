"""
Unit tests for weaver_repository rule.

This module contains tests for the repository rule implementation.
"""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("//weaver:repositories.bzl", "_detect_platform", "_get_download_urls")

def _test_platform_detection_linux_x86_64(ctx):
    """Test platform detection for Linux x86_64."""
    env = unittest.begin(ctx)
    
    # Mock repository_ctx.os
    class MockOs:
        name = "linux"
        arch = "x86_64"
    
    class MockRepositoryCtx:
        os = MockOs()
    
    platform = _detect_platform(MockRepositoryCtx())
    asserts.equals(env, "linux-x86_64", platform)
    
    return unittest.end(env)

def _test_platform_detection_linux_aarch64(ctx):
    """Test platform detection for Linux aarch64."""
    env = unittest.begin(ctx)
    
    class MockOs:
        name = "linux"
        arch = "aarch64"
    
    class MockRepositoryCtx:
        os = MockOs()
    
    platform = _detect_platform(MockRepositoryCtx())
    asserts.equals(env, "linux-aarch64", platform)
    
    return unittest.end(env)

def _test_platform_detection_macos_x86_64(ctx):
    """Test platform detection for macOS x86_64."""
    env = unittest.begin(ctx)
    
    class MockOs:
        name = "mac os x"
        arch = "x86_64"
    
    class MockRepositoryCtx:
        os = MockOs()
    
    platform = _detect_platform(MockRepositoryCtx())
    asserts.equals(env, "darwin-x86_64", platform)
    
    return unittest.end(env)

def _test_platform_detection_macos_aarch64(ctx):
    """Test platform detection for macOS aarch64."""
    env = unittest.begin(ctx)
    
    class MockOs:
        name = "mac os x"
        arch = "aarch64"
    
    class MockRepositoryCtx:
        os = MockOs()
    
    platform = _detect_platform(MockRepositoryCtx())
    asserts.equals(env, "darwin-aarch64", platform)
    
    return unittest.end(env)

def _test_platform_detection_windows_x86_64(ctx):
    """Test platform detection for Windows x86_64."""
    env = unittest.begin(ctx)
    
    class MockOs:
        name = "windows"
        arch = "x86_64"
    
    class MockRepositoryCtx:
        os = MockOs()
    
    platform = _detect_platform(MockRepositoryCtx())
    asserts.equals(env, "windows-x86_64", platform)
    
    return unittest.end(env)

def _test_platform_detection_unsupported_linux(ctx):
    """Test platform detection failure for unsupported Linux architecture."""
    env = unittest.begin(ctx)
    
    class MockOs:
        name = "linux"
        arch = "arm"
    
    class MockRepositoryCtx:
        os = MockOs()
    
    try:
        _detect_platform(MockRepositoryCtx())
        asserts.fail(env, "Expected failure for unsupported architecture")
    except:
        # Expected failure
        pass
    
    return unittest.end(env)

def _test_platform_detection_unsupported_os(ctx):
    """Test platform detection failure for unsupported OS."""
    env = unittest.begin(ctx)
    
    class MockOs:
        name = "freebsd"
        arch = "x86_64"
    
    class MockRepositoryCtx:
        os = MockOs()
    
    try:
        _detect_platform(MockRepositoryCtx())
        asserts.fail(env, "Expected failure for unsupported OS")
    except:
        # Expected failure
        pass
    
    return unittest.end(env)

def _test_get_download_urls_default(ctx):
    """Test default URL generation."""
    env = unittest.begin(ctx)
    
    version = "0.1.0"
    platform = "linux-x86_64"
    
    urls = _get_download_urls(version, platform)
    
    expected_urls = [
        "https://github.com/open-telemetry/weaver/releases/download/v0.1.0/weaver-0.1.0-linux-amd64.tar.gz",
        "https://github.com/open-telemetry/weaver/releases/download/v0.1.0/weaver-0.1.0-linux-amd64.zip",
    ]
    
    asserts.equals(env, expected_urls, urls)
    
    return unittest.end(env)

def _test_get_download_urls_custom(ctx):
    """Test custom URL override."""
    env = unittest.begin(ctx)
    
    version = "0.1.0"
    platform = "linux-x86_64"
    custom_urls = ["https://example.com/weaver.tar.gz"]
    
    urls = _get_download_urls(version, platform, custom_urls)
    
    asserts.equals(env, custom_urls, urls)
    
    return unittest.end(env)

def _test_get_download_urls_unsupported_platform(ctx):
    """Test URL generation failure for unsupported platform."""
    env = unittest.begin(ctx)
    
    version = "0.1.0"
    platform = "unsupported-platform"
    
    try:
        _get_download_urls(version, platform)
        asserts.fail(env, "Expected failure for unsupported platform")
    except:
        # Expected failure
        pass
    
    return unittest.end(env)

def _test_get_download_urls_different_platforms(ctx):
    """Test URL generation for different platforms."""
    env = unittest.begin(ctx)
    
    version = "0.2.0"
    
    # Test Linux aarch64
    linux_aarch64_urls = _get_download_urls(version, "linux-aarch64")
    expected_linux_aarch64 = [
        "https://github.com/open-telemetry/weaver/releases/download/v0.2.0/weaver-0.2.0-linux-arm64.tar.gz",
        "https://github.com/open-telemetry/weaver/releases/download/v0.2.0/weaver-0.2.0-linux-arm64.zip",
    ]
    asserts.equals(env, expected_linux_aarch64, linux_aarch64_urls)
    
    # Test macOS aarch64
    macos_aarch64_urls = _get_download_urls(version, "darwin-aarch64")
    expected_macos_aarch64 = [
        "https://github.com/open-telemetry/weaver/releases/download/v0.2.0/weaver-0.2.0-darwin-arm64.tar.gz",
        "https://github.com/open-telemetry/weaver/releases/download/v0.2.0/weaver-0.2.0-darwin-arm64.zip",
    ]
    asserts.equals(env, expected_macos_aarch64, macos_aarch64_urls)
    
    # Test Windows
    windows_urls = _get_download_urls(version, "windows-x86_64")
    expected_windows = [
        "https://github.com/open-telemetry/weaver/releases/download/v0.2.0/weaver-0.2.0-windows-amd64.tar.gz",
        "https://github.com/open-telemetry/weaver/releases/download/v0.2.0/weaver-0.2.0-windows-amd64.zip",
    ]
    asserts.equals(env, expected_windows, windows_urls)
    
    return unittest.end(env)

# Test suite
def repositories_test_suite(name):
    """Create test suite for repository rules."""
    unittest.suite(
        name,
        _test_platform_detection_linux_x86_64,
        _test_platform_detection_linux_aarch64,
        _test_platform_detection_macos_x86_64,
        _test_platform_detection_macos_aarch64,
        _test_platform_detection_windows_x86_64,
        _test_platform_detection_unsupported_linux,
        _test_platform_detection_unsupported_os,
        _test_get_download_urls_default,
        _test_get_download_urls_custom,
        _test_get_download_urls_unsupported_platform,
        _test_get_download_urls_different_platforms,
    ) 