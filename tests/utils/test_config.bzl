"""
Test configuration for OpenTelemetry Weaver rules testing.

This module provides centralized configuration for test parameters,
thresholds, and settings used across the testing framework.
"""

# =============================================================================
# Performance Thresholds
# =============================================================================

# Execution time thresholds (in milliseconds)
PERFORMANCE_THRESHOLDS = {
    # Unit test thresholds
    "unit_test_execution": 50.0,
    "provider_creation": 10.0,
    "rule_implementation": 20.0,
    "action_creation": 15.0,
    
    # Integration test thresholds
    "integration_workflow": 500.0,
    "dependency_resolution": 100.0,
    "caching_operation": 50.0,
    "remote_execution_check": 100.0,
    
    # Performance test thresholds
    "large_schema_processing": 1000.0,
    "incremental_build": 200.0,
    "memory_profiling": 500.0,
    "cache_hit_rate": 100.0,
    
    # Error scenario test thresholds
    "error_detection": 100.0,
    "validation_error": 50.0,
    "dependency_error": 75.0,
    "configuration_error": 25.0,
    
    # Framework test thresholds
    "coverage_tracking": 50.0,
    "test_orchestration": 100.0,
    "result_aggregation": 100.0,
    "suite_integration": 500.0,
}

# Memory usage thresholds (in bytes)
MEMORY_THRESHOLDS = {
    "per_schema_memory": 10000,  # 10KB per schema max
    "peak_memory_ratio": 10,     # Peak should not be 10x initial
    "memory_growth_factor": 2,   # Memory should not grow more than 2x
}

# Cache performance thresholds
CACHE_THRESHOLDS = {
    "minimum_hit_rate": 0.5,     # 50% minimum hit rate for repeated patterns
    "maximum_hit_rate": 0.3,     # 30% maximum hit rate for sequential patterns
    "cache_efficiency": 50,      # Efficiency metric for incremental builds
}

# =============================================================================
# Test Data Configuration
# =============================================================================

# Schema generation parameters
SCHEMA_CONFIG = {
    "default_schema_count": 100,
    "large_schema_count": 500,
    "performance_test_sizes": [10, 50, 100, 500],
    "memory_test_sizes": [10, 25, 50],
    "incremental_test_sizes": [10, 25, 50, 100],
}

# Test workspace configuration
WORKSPACE_CONFIG = {
    "default_schema_count": 2,
    "default_policy_count": 2,
    "default_dependency_count": 2,
    "integration_workspace_size": 5,
}

# Error scenario configuration
ERROR_CONFIG = {
    "invalid_yaml_count": 3,
    "invalid_openapi_count": 4,
    "missing_dependency_count": 3,
    "circular_dependency_count": 4,
    "invalid_config_count": 4,
    "platform_error_count": 4,
}

# =============================================================================
# Test Coverage Targets
# =============================================================================

# Coverage percentage targets
COVERAGE_TARGETS = {
    "provider_coverage": 100.0,
    "rule_coverage": 95.0,
    "action_coverage": 90.0,
    "integration_coverage": 85.0,
    "error_coverage": 95.0,
    "performance_coverage": 80.0,
    "overall_coverage": 90.0,
}

# Test count targets
TEST_COUNT_TARGETS = {
    "unit_tests": 20,
    "integration_tests": 10,
    "performance_tests": 8,
    "error_tests": 12,
    "framework_tests": 4,
    "total_tests": 54,
}

# =============================================================================
# Platform Configuration
# =============================================================================

# Supported platforms for testing
SUPPORTED_PLATFORMS = [
    "linux",
    "darwin",
    "windows",
]

# Platform-specific configurations
PLATFORM_CONFIG = {
    "linux": {
        "error_scenarios": ["permission_denied", "disk_full"],
        "performance_multiplier": 1.0,
    },
    "darwin": {
        "error_scenarios": ["file_not_found"],
        "performance_multiplier": 1.1,
    },
    "windows": {
        "error_scenarios": ["path_too_long"],
        "performance_multiplier": 1.2,
    },
}

# =============================================================================
# Test Execution Configuration
# =============================================================================

# Test execution settings
EXECUTION_CONFIG = {
    "timeout_seconds": 300,           # 5 minutes per test
    "retry_count": 3,                 # Number of retries for flaky tests
    "parallel_execution": True,       # Enable parallel test execution
    "max_parallel_tests": 4,          # Maximum parallel tests
    "enable_performance_monitoring": True,
    "enable_memory_profiling": True,
    "enable_coverage_tracking": True,
}

# Test filtering configuration
FILTER_CONFIG = {
    "include_slow_tests": True,       # Include slow performance tests
    "include_flaky_tests": False,     # Exclude known flaky tests
    "include_experimental_tests": False,  # Exclude experimental tests
    "test_size": "medium",            # Default test size
}

# =============================================================================
# Validation Configuration
# =============================================================================

# Valid configuration values
VALID_CONFIG = {
    "formats": ["typescript", "javascript", "python", "go", "java", "html", "markdown"],
    "environment_variables": ["DEBUG", "NODE_ENV", "PYTHONPATH", "GOPATH"],
    "arguments": ["--verbose", "--strict", "--format", "--template"],
    "debug_values": ["0", "1", "true", "false"],
}

# Error message templates
ERROR_MESSAGES = {
    "invalid_format": "Invalid format: {}",
    "invalid_argument": "Invalid argument: {}",
    "invalid_env_var": "Invalid environment variable: {}",
    "invalid_debug_value": "Invalid DEBUG value: {}",
    "missing_source_files": "No source files provided",
    "yaml_syntax_error": "YAML syntax error: {}",
    "openapi_structure_error": "OpenAPI structure error: {}",
    "missing_dependency": "Missing dependency: {}",
    "circular_dependency": "Circular dependency detected: {}",
    "platform_error": "Platform-specific error: {}",
}

# =============================================================================
# Reporting Configuration
# =============================================================================

# Test reporting settings
REPORTING_CONFIG = {
    "generate_html_report": True,
    "generate_json_report": True,
    "generate_coverage_report": True,
    "report_directory": "test_reports",
    "coverage_format": "html",
    "performance_report": True,
    "error_summary": True,
}

# Report thresholds
REPORT_THRESHOLDS = {
    "minimum_coverage": 90.0,
    "maximum_execution_time": 1000.0,  # 1 second
    "minimum_test_count": 50,
    "maximum_failure_rate": 0.05,      # 5% failure rate
}

# =============================================================================
# CI/CD Configuration
# =============================================================================

# Continuous Integration settings
CI_CONFIG = {
    "run_on_push": True,
    "run_on_pull_request": True,
    "run_on_schedule": False,
    "required_tests": [
        "comprehensive_unit_test",
        "comprehensive_integration_test",
        "comprehensive_performance_test",
        "comprehensive_error_test",
    ],
    "optional_tests": [
        "performance_benchmark_test",
        "memory_profiling_test",
    ],
    "failure_threshold": 0.95,  # 95% success rate required
}

# Notification settings
NOTIFICATION_CONFIG = {
    "notify_on_failure": True,
    "notify_on_performance_regression": True,
    "notify_on_coverage_drop": True,
    "notification_channels": ["email", "slack"],
}

# =============================================================================
# Utility Functions
# =============================================================================

def get_performance_threshold(operation_name):
    """Get performance threshold for a specific operation."""
    return PERFORMANCE_THRESHOLDS.get(operation_name, 100.0)

def get_memory_threshold(threshold_name):
    """Get memory threshold for a specific metric."""
    return MEMORY_THRESHOLDS.get(threshold_name, 10000)

def get_cache_threshold(threshold_name):
    """Get cache threshold for a specific metric."""
    return CACHE_THRESHOLDS.get(threshold_name, 0.5)

def get_coverage_target(category):
    """Get coverage target for a specific category."""
    return COVERAGE_TARGETS.get(category, 90.0)

def get_test_count_target(category):
    """Get test count target for a specific category."""
    return TEST_COUNT_TARGETS.get(category, 10)

def is_platform_supported(platform):
    """Check if a platform is supported for testing."""
    return platform in SUPPORTED_PLATFORMS

def get_platform_config(platform):
    """Get configuration for a specific platform."""
    return PLATFORM_CONFIG.get(platform, {})

def get_error_message(template_name, *args):
    """Get formatted error message."""
    template = ERROR_MESSAGES.get(template_name, "Unknown error: {}")
    return template.format(*args)

def is_valid_format(format_name):
    """Check if a format is valid."""
    return format_name in VALID_CONFIG["formats"]

def is_valid_argument(argument):
    """Check if an argument is valid."""
    return argument in VALID_CONFIG["arguments"]

def is_valid_env_var(var_name):
    """Check if an environment variable is valid."""
    return var_name in VALID_CONFIG["environment_variables"]

def should_run_test(test_name):
    """Determine if a test should be run based on configuration."""
    if not FILTER_CONFIG["include_slow_tests"] and "performance" in test_name:
        return False
    if not FILTER_CONFIG["include_flaky_tests"] and "flaky" in test_name:
        return False
    if not FILTER_CONFIG["include_experimental_tests"] and "experimental" in test_name:
        return False
    return True 