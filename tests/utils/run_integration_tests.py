#!/usr/bin/env python3
"""
Integration test runner for Weaver rules.

This script runs comprehensive integration tests for the Weaver rules
and validates that all components work correctly together.
"""

import os
import sys
import subprocess
import json
import time
from pathlib import Path

def run_bazel_command(args, capture_output=True):
    """Run a Bazel command and return the result."""
    try:
        result = subprocess.run(
            ["bazel"] + args,
            capture_output=capture_output,
            text=True,
            timeout=300  # 5 minute timeout
        )
        return result
    except subprocess.TimeoutExpired:
        print("ERROR: Bazel command timed out")
        return None
    except FileNotFoundError:
        print("ERROR: Bazel not found in PATH")
        return None

def test_mock_weaver_binary():
    """Test that the mock Weaver binary works correctly."""
    print("Testing mock Weaver binary...")
    
    # Test the mock binary directly
    mock_weaver_path = "tests/mock_weaver.py"
    if not os.path.exists(mock_weaver_path):
        print("ERROR: Mock Weaver binary not found")
        return False
    
    # Test help
    result = subprocess.run([mock_weaver_path, "--help"], capture_output=True, text=True)
    if result.returncode != 0:
        print("ERROR: Mock Weaver help failed")
        return False
    
    # Test generate command
    result = subprocess.run([
        mock_weaver_path, "generate",
        "tests/schemas/sample.yaml",
        "--output-dir", "/tmp/test_output",
        "--format", "typescript",
        "--verbose"
    ], capture_output=True, text=True)
    
    if result.returncode != 0:
        print("ERROR: Mock Weaver generate failed")
        print("STDOUT:", result.stdout)
        print("STDERR:", result.stderr)
        return False
    
    # Check that output files were created
    if not os.path.exists("/tmp/test_output/types.ts"):
        print("ERROR: Generated types.ts not found")
        return False
    
    if not os.path.exists("/tmp/test_output/client.ts"):
        print("ERROR: Generated client.ts not found")
        return False
    
    print("✅ Mock Weaver binary test passed")
    return True

def test_bazel_build():
    """Test that Bazel can build the Weaver rules."""
    print("Testing Bazel build...")
    
    # Test building the mock Weaver
    result = run_bazel_command(["build", "//tests:mock_weaver"])
    if not result or result.returncode != 0:
        print("ERROR: Failed to build mock Weaver")
        if result:
            print("STDOUT:", result.stdout)
            print("STDERR:", result.stderr)
        return False
    
    print("✅ Bazel build test passed")
    return True

def test_weaver_schema_rule():
    """Test the weaver_schema rule."""
    print("Testing weaver_schema rule...")
    
    # Test building a schema target
    result = run_bazel_command(["build", "//tests:test_schemas"])
    if not result or result.returncode != 0:
        print("ERROR: Failed to build weaver_schema target")
        if result:
            print("STDOUT:", result.stdout)
            print("STDERR:", result.stderr)
        return False
    
    print("✅ weaver_schema rule test passed")
    return True

def test_weaver_generate_rule():
    """Test the weaver_generate rule."""
    print("Testing weaver_generate rule...")
    
    # Test building a generate target
    result = run_bazel_command(["build", "//tests:test_generated_code"])
    if not result or result.returncode != 0:
        print("ERROR: Failed to build weaver_generate target")
        if result:
            print("STDOUT:", result.stdout)
            print("STDERR:", result.stderr)
        return False
    
    print("✅ weaver_generate rule test passed")
    return True

def test_weaver_validate_rule():
    """Test the weaver_validate rule."""
    print("Testing weaver_validate rule...")
    
    # Test building a validate target
    result = run_bazel_command(["build", "//tests:test_validation"])
    if not result or result.returncode != 0:
        print("ERROR: Failed to build weaver_validate target")
        if result:
            print("STDOUT:", result.stdout)
            print("STDERR:", result.stderr)
        return False
    
    print("✅ weaver_validate rule test passed")
    return True

def test_weaver_docs_rule():
    """Test the weaver_docs rule."""
    print("Testing weaver_docs rule...")
    
    # Test building a docs target
    result = run_bazel_command(["build", "//tests:test_documentation"])
    if not result or result.returncode != 0:
        print("ERROR: Failed to build weaver_docs target")
        if result:
            print("STDOUT:", result.stdout)
            print("STDERR:", result.stderr)
        return False
    
    print("✅ weaver_docs rule test passed")
    return True

def test_weaver_library_macro():
    """Test the weaver_library macro."""
    print("Testing weaver_library macro...")
    
    # Test building a library target
    result = run_bazel_command(["build", "//tests:test_library"])
    if not result or result.returncode != 0:
        print("ERROR: Failed to build weaver_library target")
        if result:
            print("STDOUT:", result.stdout)
            print("STDERR:", result.stderr)
        return False
    
    print("✅ weaver_library macro test passed")
    return True

def test_unit_tests():
    """Test that unit tests pass."""
    print("Testing unit tests...")
    
    # Test running unit tests
    result = run_bazel_command(["test", "//tests:all_unit_tests"])
    if not result or result.returncode != 0:
        print("ERROR: Unit tests failed")
        if result:
            print("STDOUT:", result.stdout)
            print("STDERR:", result.stderr)
        return False
    
    print("✅ Unit tests passed")
    return True

def test_integration_tests():
    """Test that integration tests pass."""
    print("Testing integration tests...")
    
    # Test running integration tests
    result = run_bazel_command(["test", "//tests:all_integration_tests"])
    if not result or result.returncode != 0:
        print("ERROR: Integration tests failed")
        if result:
            print("STDOUT:", result.stdout)
            print("STDERR:", result.stderr)
        return False
    
    print("✅ Integration tests passed")
    return True

def test_performance_tests():
    """Test that performance tests pass."""
    print("Testing performance tests...")
    
    # Test running performance tests
    result = run_bazel_command(["test", "//tests:all_performance_tests"])
    if not result or result.returncode != 0:
        print("ERROR: Performance tests failed")
        if result:
            print("STDOUT:", result.stdout)
            print("STDERR:", result.stderr)
        return False
    
    print("✅ Performance tests passed")
    return True

def test_error_tests():
    """Test that error tests pass."""
    print("Testing error tests...")
    
    # Test running error tests
    result = run_bazel_command(["test", "//tests:all_error_tests"])
    if not result or result.returncode != 0:
        print("ERROR: Error tests failed")
        if result:
            print("STDOUT:", result.stdout)
            print("STDERR:", result.stderr)
        return False
    
    print("✅ Error tests passed")
    return True

def test_comprehensive_suite():
    """Test the comprehensive test suite."""
    print("Testing comprehensive test suite...")
    
    # Test running comprehensive tests
    result = run_bazel_command(["test", "//tests:comprehensive_test_suite"])
    if not result or result.returncode != 0:
        print("ERROR: Comprehensive test suite failed")
        if result:
            print("STDOUT:", result.stdout)
            print("STDERR:", result.stderr)
        return False
    
    print("✅ Comprehensive test suite passed")
    return True

def main():
    """Run all integration tests."""
    print("🚀 Starting Weaver Rules Integration Testing")
    print("=" * 50)
    
    tests = [
        ("Mock Weaver Binary", test_mock_weaver_binary),
        ("Bazel Build", test_bazel_build),
        ("weaver_schema Rule", test_weaver_schema_rule),
        ("weaver_generate Rule", test_weaver_generate_rule),
        ("weaver_validate Rule", test_weaver_validate_rule),
        ("weaver_docs Rule", test_weaver_docs_rule),
        ("weaver_library Macro", test_weaver_library_macro),
        ("Unit Tests", test_unit_tests),
        ("Integration Tests", test_integration_tests),
        ("Performance Tests", test_performance_tests),
        ("Error Tests", test_error_tests),
        ("Comprehensive Test Suite", test_comprehensive_suite),
    ]
    
    passed = 0
    failed = 0
    
    for test_name, test_func in tests:
        print(f"\n📋 Running {test_name}...")
        start_time = time.time()
        
        try:
            if test_func():
                passed += 1
                duration = time.time() - start_time
                print(f"✅ {test_name} passed ({duration:.2f}s)")
            else:
                failed += 1
                duration = time.time() - start_time
                print(f"❌ {test_name} failed ({duration:.2f}s)")
        except Exception as e:
            failed += 1
            duration = time.time() - start_time
            print(f"❌ {test_name} failed with exception ({duration:.2f}s): {e}")
    
    print("\n" + "=" * 50)
    print("📊 Integration Test Results")
    print("=" * 50)
    print(f"✅ Passed: {passed}")
    print(f"❌ Failed: {failed}")
    print(f"📈 Total: {passed + failed}")
    
    if failed == 0:
        print("\n🎉 All integration tests passed!")
        return 0
    else:
        print(f"\n⚠️  {failed} test(s) failed. Please check the output above.")
        return 1

if __name__ == "__main__":
    sys.exit(main()) 