"""
Performance monitoring utilities for OpenTelemetry Weaver rules.

This module provides tools for tracking performance metrics, detecting
regressions, and generating performance reports for Weaver operations.
"""

load("@bazel_skylib//lib:paths.bzl", "paths")
load("//weaver/internal:performance.bzl", "performance_utils", "PerformanceMetrics")

# Performance thresholds for regression detection
PERFORMANCE_THRESHOLDS = {
    "analysis_time_ms": 100,      # Analysis time should be under 100ms
    "action_time_ms": 5000,       # Action time should be under 5s
    "cache_hit_rate": 90,         # Cache hit rate should be above 90%
    "memory_usage_mb": 50,        # Memory usage should be under 50MB
}

# Performance history for trend analysis
_performance_history = {}

def _record_performance_metrics(operation_name, metrics):
    """Record performance metrics for trend analysis.
    
    Args:
        operation_name: Name of the operation
        metrics: PerformanceMetrics provider
    
    Returns:
        None
    """
    if operation_name not in _performance_history:
        _performance_history[operation_name] = []
    
    _performance_history[operation_name].append({
        "timestamp": _get_current_timestamp(),
        "analysis_time_ms": metrics.analysis_time_ms,
        "action_time_ms": metrics.action_time_ms,
        "cache_hit_rate": metrics.cache_hit_rate,
        "memory_usage_mb": metrics.memory_usage_mb,
        "file_count": metrics.file_count,
        "schema_count": metrics.schema_count,
    })
    
    # Keep only last 100 entries to prevent memory bloat
    if len(_performance_history[operation_name]) > 100:
        _performance_history[operation_name] = _performance_history[operation_name][-100:]

def _get_current_timestamp():
    """Get current timestamp for performance tracking."""
    import time
    return time.time()

def _detect_performance_regression(operation_name, metrics):
    """Detect performance regression by comparing with historical data.
    
    Args:
        operation_name: Name of the operation
        metrics: PerformanceMetrics provider
    
    Returns:
        List of regression warnings
    """
    warnings = []
    
    if operation_name not in _performance_history:
        return warnings
    
    history = _performance_history[operation_name]
    if len(history) < 5:  # Need at least 5 data points for trend analysis
        return warnings
    
    # Calculate average performance from recent history
    recent_history = history[-10:]  # Last 10 entries
    avg_analysis_time = sum(h["analysis_time_ms"] for h in recent_history) / len(recent_history)
    avg_action_time = sum(h["action_time_ms"] for h in recent_history) / len(recent_history)
    avg_memory_usage = sum(h["memory_usage_mb"] for h in recent_history) / len(recent_history)
    
    # Check for regressions (20% degradation threshold)
    if metrics.analysis_time_ms > avg_analysis_time * 1.2:
        warnings.append("Analysis time regression: {}ms vs {}ms average".format(
            metrics.analysis_time_ms, avg_analysis_time))
    
    if metrics.action_time_ms > avg_action_time * 1.2:
        warnings.append("Action time regression: {}ms vs {}ms average".format(
            metrics.action_time_ms, avg_action_time))
    
    if metrics.memory_usage_mb > avg_memory_usage * 1.2:
        warnings.append("Memory usage regression: {}MB vs {}MB average".format(
            metrics.memory_usage_mb, avg_memory_usage))
    
    return warnings

def _check_performance_thresholds(metrics):
    """Check if performance metrics meet defined thresholds.
    
    Args:
        metrics: PerformanceMetrics provider
    
    Returns:
        List of threshold violations
    """
    violations = []
    
    if metrics.analysis_time_ms > PERFORMANCE_THRESHOLDS["analysis_time_ms"]:
        violations.append("Analysis time {}ms exceeds threshold {}ms".format(
            metrics.analysis_time_ms, PERFORMANCE_THRESHOLDS["analysis_time_ms"]))
    
    if metrics.action_time_ms > PERFORMANCE_THRESHOLDS["action_time_ms"]:
        violations.append("Action time {}ms exceeds threshold {}ms".format(
            metrics.action_time_ms, PERFORMANCE_THRESHOLDS["action_time_ms"]))
    
    if metrics.cache_hit_rate < PERFORMANCE_THRESHOLDS["cache_hit_rate"]:
        violations.append("Cache hit rate {}% below threshold {}%".format(
            metrics.cache_hit_rate, PERFORMANCE_THRESHOLDS["cache_hit_rate"]))
    
    if metrics.memory_usage_mb > PERFORMANCE_THRESHOLDS["memory_usage_mb"]:
        violations.append("Memory usage {}MB exceeds threshold {}MB".format(
            metrics.memory_usage_mb, PERFORMANCE_THRESHOLDS["memory_usage_mb"]))
    
    return violations

def _generate_performance_report(operation_name, metrics, include_history = True):
    """Generate a comprehensive performance report.
    
    Args:
        operation_name: Name of the operation
        metrics: PerformanceMetrics provider
        include_history: Whether to include historical data
    
    Returns:
        Performance report string
    """
    report_lines = [
        "# Performance Report for {}".format(operation_name),
        "",
        "## Current Metrics",
        "Analysis Time: {}ms".format(metrics.analysis_time_ms),
        "Action Time: {}ms".format(metrics.action_time_ms),
        "Cache Hit Rate: {}%".format(metrics.cache_hit_rate),
        "Memory Usage: {}MB".format(metrics.memory_usage_mb),
        "Files Processed: {}".format(metrics.file_count),
        "Schemas Processed: {}".format(metrics.schema_count),
        "",
    ]
    
    # Check thresholds
    threshold_violations = _check_performance_thresholds(metrics)
    if threshold_violations:
        report_lines.extend([
            "## Threshold Violations",
        ] + threshold_violations + [""])
    else:
        report_lines.append("## Threshold Status: All thresholds met\n")
    
    # Check for regressions
    regression_warnings = _detect_performance_regression(operation_name, metrics)
    if regression_warnings:
        report_lines.extend([
            "## Performance Regressions",
        ] + regression_warnings + [""])
    else:
        report_lines.append("## Regression Status: No regressions detected\n")
    
    # Include historical data if requested
    if include_history and operation_name in _performance_history:
        history = _performance_history[operation_name]
        if history:
            report_lines.extend([
                "## Historical Data (Last 10 entries)",
                "Average Analysis Time: {}ms".format(
                    sum(h["analysis_time_ms"] for h in history[-10:]) / min(10, len(history))),
                "Average Action Time: {}ms".format(
                    sum(h["action_time_ms"] for h in history[-10:]) / min(10, len(history))),
                "Average Memory Usage: {}MB".format(
                    sum(h["memory_usage_mb"] for h in history[-10:]) / min(10, len(history))),
                "",
            ])
    
    return "\n".join(report_lines)

def _create_performance_monitoring_action(ctx, operation_name, metrics, output_file):
    """Create an action to generate and record performance reports.
    
    Args:
        ctx: The rule context
        operation_name: Name of the operation
        metrics: PerformanceMetrics provider
        output_file: Output file for the report
    
    Returns:
        None
    """
    # Record metrics for trend analysis
    _record_performance_metrics(operation_name, metrics)
    
    # Generate comprehensive report
    report_content = _generate_performance_report(operation_name, metrics)
    
    # Create the report file
    ctx.actions.write(
        output = output_file,
        content = report_content,
    )

def _get_performance_summary():
    """Get a summary of all recorded performance data.
    
    Returns:
        Performance summary string
    """
    if not _performance_history:
        return "No performance data recorded"
    
    summary_lines = ["# Performance Summary", ""]
    
    for operation_name, history in _performance_history.items():
        if not history:
            continue
        
        recent = history[-10:]  # Last 10 entries
        avg_analysis = sum(h["analysis_time_ms"] for h in recent) / len(recent)
        avg_action = sum(h["action_time_ms"] for h in recent) / len(recent)
        avg_memory = sum(h["memory_usage_mb"] for h in recent) / len(recent)
        
        summary_lines.extend([
            "## {}".format(operation_name),
            "Average Analysis Time: {:.1f}ms".format(avg_analysis),
            "Average Action Time: {:.1f}ms".format(avg_action),
            "Average Memory Usage: {:.1f}MB".format(avg_memory),
            "Data Points: {}".format(len(history)),
            "",
        ])
    
    return "\n".join(summary_lines)

# Export monitoring utilities
monitoring_utils = struct(
    record_performance_metrics = _record_performance_metrics,
    detect_performance_regression = _detect_performance_regression,
    check_performance_thresholds = _check_performance_thresholds,
    generate_performance_report = _generate_performance_report,
    create_performance_monitoring_action = _create_performance_monitoring_action,
    get_performance_summary = _get_performance_summary,
) 