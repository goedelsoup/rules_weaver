"""
Real Weaver Integration Test Configuration

This module provides configuration and setup for integration tests
that use actual Weaver binaries downloaded from GitHub releases.
"""

load("//tests/integration:real_weaver_integration_test.bzl", 
     "real_weaver_integration_test_suite",
     "real_weaver_performance_test_suite", 
     "real_weaver_error_test_suite",
     "real_weaver_platform_test_suite",
     "real_weaver_workflow_test_suite")

def setup_real_weaver_tests():
    """Set up all real Weaver integration tests."""
    
    # Basic integration tests
    real_weaver_integration_test_suite()
    
    # Note: Other test suites are commented out until they are implemented
    # real_weaver_performance_test_suite()
    # real_weaver_error_test_suite()
    # real_weaver_platform_test_suite()
    # real_weaver_workflow_test_suite()

def real_weaver_test_suite():
    """Create a comprehensive test suite for real Weaver integration."""
    
    # Set up all test suites
    setup_real_weaver_tests()
    
    # Create a comprehensive test suite that includes all real Weaver tests
    native.test_suite(
        name = "real_weaver_comprehensive_test_suite",
        tests = [
            # Basic integration tests
            "//tests:real_validation_test",
            "//tests:real_generated_code",
        ],
        testonly = True,
    )

def real_weaver_ci_test_suite():
    """Create a CI-optimized test suite for real Weaver integration."""
    
    # Set up all test suites
    setup_real_weaver_tests()
    
    # Create a CI-optimized test suite with faster tests
    native.test_suite(
        name = "real_weaver_ci_test_suite",
        tests = [
            # Core functionality tests (fast)
            "//tests:real_validation_test",
            "//tests:real_generated_code",
        ],
        testonly = True,
    )

def real_weaver_nightly_test_suite():
    """Create a nightly test suite for comprehensive real Weaver testing."""
    
    # Set up all test suites
    setup_real_weaver_tests()
    
    # Create a nightly test suite with all tests including performance
    native.test_suite(
        name = "real_weaver_nightly_test_suite",
        tests = [
            # All integration tests
            "//tests:real_weaver_comprehensive_test_suite",
        ],
        testonly = True,
    ) 