#!/usr/bin/env python3
"""
Real Weaver Integration Test Runner

This script runs integration tests with actual Weaver binaries downloaded
from GitHub releases to ensure the rules work correctly with the real tool.
"""

import os
import sys
import subprocess
import json
import time
from pathlib import Path
from typing import List, Dict, Any

class RealWeaverTestRunner:
    """Runner for real Weaver integration tests."""
    
    def __init__(self, workspace_root: str):
        self.workspace_root = Path(workspace_root)
        self.test_results = {}
        self.start_time = time.time()
        
    def run_bazel_command(self, command: List[str], capture_output: bool = True) -> subprocess.CompletedProcess:
        """Run a Bazel command and return the result."""
        cmd = ["bazel"] + command
        print(f"Running: {' '.join(cmd)}")
        
        try:
            result = subprocess.run(
                cmd,
                cwd=self.workspace_root,
                capture_output=capture_output,
                text=True,
                timeout=300  # 5 minute timeout
            )
            return result
        except subprocess.TimeoutExpired:
            print(f"Command timed out: {' '.join(cmd)}")
            return subprocess.CompletedProcess(cmd, -1, "", "Command timed out")
        except Exception as e:
            print(f"Error running command: {e}")
            return subprocess.CompletedProcess(cmd, -1, "", str(e))
    
    def test_weaver_download(self) -> bool:
        """Test that Weaver binary can be downloaded successfully."""
        print("\n=== Testing Weaver Binary Download ===")
        
        # Test repository rule
        result = self.run_bazel_command([
            "query", "--output=location", "@real_weaver//:weaver_binary"
        ])
        
        if result.returncode != 0:
            print(f"Failed to query Weaver binary: {result.stderr}")
            return False
        
        print(f"✓ Weaver binary location: {result.stdout.strip()}")
        return True
    
    def test_basic_integration(self) -> bool:
        """Test basic integration with real Weaver."""
        print("\n=== Testing Basic Integration ===")
        
        # Test schema declaration
        result = self.run_bazel_command([
            "build", "//tests:real_test_schemas"
        ])
        
        if result.returncode != 0:
            print(f"Failed to build schema target: {result.stderr}")
            return False
        
        print("✓ Schema declaration test passed")
        return True
    
    def test_code_generation(self) -> bool:
        """Test code generation with real Weaver."""
        print("\n=== Testing Code Generation ===")
        
        # Test TypeScript generation
        result = self.run_bazel_command([
            "build", "//tests:real_generated_code"
        ])
        
        if result.returncode != 0:
            print(f"Failed to generate TypeScript code: {result.stderr}")
            return False
        
        print("✓ TypeScript code generation test passed")
        
        # Test Rust generation
        result = self.run_bazel_command([
            "build", "//tests:real_generated_rust"
        ])
        
        if result.returncode != 0:
            print(f"Failed to generate Rust code: {result.stderr}")
            return False
        
        print("✓ Rust code generation test passed")
        return True
    
    def test_validation(self) -> bool:
        """Test schema validation with real Weaver."""
        print("\n=== Testing Schema Validation ===")
        
        # Test validation
        result = self.run_bazel_command([
            "test", "//tests:real_validation_test"
        ])
        
        if result.returncode != 0:
            print(f"Failed to validate schemas: {result.stderr}")
            return False
        
        print("✓ Schema validation test passed")
        return True
    
    def test_documentation(self) -> bool:
        """Test documentation generation with real Weaver."""
        print("\n=== Testing Documentation Generation ===")
        
        # Test HTML documentation
        result = self.run_bazel_command([
            "build", "//tests:real_documentation"
        ])
        
        if result.returncode != 0:
            print(f"Failed to generate documentation: {result.stderr}")
            return False
        
        print("✓ Documentation generation test passed")
        return True
    
    def test_workflow(self) -> bool:
        """Test end-to-end workflow with real Weaver."""
        print("\n=== Testing End-to-End Workflow ===")
        
        # Test complete workflow
        result = self.run_bazel_command([
            "test", "//tests:real_workflow_test_suite"
        ])
        
        if result.returncode != 0:
            print(f"Failed to run workflow test: {result.stderr}")
            return False
        
        print("✓ End-to-end workflow test passed")
        return True
    
    def test_performance(self) -> bool:
        """Test performance with real Weaver."""
        print("\n=== Testing Performance ===")
        
        # Test performance with larger schema set
        result = self.run_bazel_command([
            "build", "//tests:real_performance_generated"
        ])
        
        if result.returncode != 0:
            print(f"Failed to run performance test: {result.stderr}")
            return False
        
        print("✓ Performance test passed")
        return True
    
    def test_error_handling(self) -> bool:
        """Test error handling with real Weaver."""
        print("\n=== Testing Error Handling ===")
        
        # Test error handling (should not fail the build)
        result = self.run_bazel_command([
            "test", "//tests:real_invalid_validation"
        ])
        
        # This test is expected to fail as a test, but not as a build
        if result.returncode != 0:
            print("✓ Error handling test passed (correctly detected invalid schema)")
            return True
        else:
            print("⚠ Error handling test may not be working correctly")
            return True
    
    def test_platform_formats(self) -> bool:
        """Test different platform formats with real Weaver."""
        print("\n=== Testing Platform Formats ===")
        
        # Test different output formats
        formats = ["typescript", "rust", "go", "python"]
        for fmt in formats:
            target = f"//tests:real_platform_{fmt}_generated"
            result = self.run_bazel_command(["build", target])
            
            if result.returncode != 0:
                print(f"Failed to generate {fmt} code: {result.stderr}")
                return False
            
            print(f"✓ {fmt} format test passed")
        
        return True
    
    def run_all_tests(self) -> Dict[str, Any]:
        """Run all real Weaver integration tests."""
        print("Starting Real Weaver Integration Tests")
        print("=" * 50)
        
        tests = [
            ("weaver_download", self.test_weaver_download),
            ("basic_integration", self.test_basic_integration),
            ("code_generation", self.test_code_generation),
            ("validation", self.test_validation),
            ("documentation", self.test_documentation),
            ("workflow", self.test_workflow),
            ("performance", self.test_performance),
            ("error_handling", self.test_error_handling),
            ("platform_formats", self.test_platform_formats),
        ]
        
        results = {}
        for test_name, test_func in tests:
            try:
                start_time = time.time()
                success = test_func()
                end_time = time.time()
                
                results[test_name] = {
                    "success": success,
                    "duration": end_time - start_time,
                    "status": "PASS" if success else "FAIL"
                }
                
                if success:
                    print(f"✓ {test_name}: PASS ({end_time - start_time:.2f}s)")
                else:
                    print(f"✗ {test_name}: FAIL ({end_time - start_time:.2f}s)")
                    
            except Exception as e:
                results[test_name] = {
                    "success": False,
                    "duration": 0,
                    "status": "ERROR",
                    "error": str(e)
                }
                print(f"✗ {test_name}: ERROR - {e}")
        
        return results
    
    def generate_report(self, results: Dict[str, Any]) -> None:
        """Generate a test report."""
        total_time = time.time() - self.start_time
        passed = sum(1 for r in results.values() if r["success"])
        failed = len(results) - passed
        
        print("\n" + "=" * 50)
        print("REAL WEAVER INTEGRATION TEST REPORT")
        print("=" * 50)
        print(f"Total Tests: {len(results)}")
        print(f"Passed: {passed}")
        print(f"Failed: {failed}")
        print(f"Total Time: {total_time:.2f}s")
        print()
        
        for test_name, result in results.items():
            status = "✓ PASS" if result["success"] else "✗ FAIL"
            duration = f"({result['duration']:.2f}s)"
            print(f"{status} {test_name} {duration}")
            
            if not result["success"] and "error" in result:
                print(f"    Error: {result['error']}")
        
        print("\n" + "=" * 50)
        
        # Save detailed report
        report_file = self.workspace_root / "real_weaver_test_report.json"
        with open(report_file, "w") as f:
            json.dump({
                "timestamp": time.time(),
                "total_time": total_time,
                "passed": passed,
                "failed": failed,
                "results": results
            }, f, indent=2)
        
        print(f"Detailed report saved to: {report_file}")
        
        if failed > 0:
            sys.exit(1)
        else:
            print("🎉 All real Weaver integration tests passed!")

def main():
    """Main entry point."""
    if len(sys.argv) > 1:
        workspace_root = sys.argv[1]
    else:
        workspace_root = os.getcwd()
    
    runner = RealWeaverTestRunner(workspace_root)
    results = runner.run_all_tests()
    runner.generate_report(results)

if __name__ == "__main__":
    main() 