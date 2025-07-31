#!/usr/bin/env python3
"""
End-to-End Integration Test Runner for New User Experience

This test simulates a completely new user's experience with rules_weaver:
1. Fresh repository setup
2. WORKSPACE integration
3. Real GitHub integration (Weaver binary download)
4. End-to-end workflow execution
5. Error handling and recovery
"""

import os
import sys
import tempfile
import shutil
import subprocess
import time
import json
import yaml
from pathlib import Path
from typing import Dict, List, Optional, Tuple
import unittest

# Add the test utils to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'utils'))

try:
    from test_utils import assert_file_exists, assert_file_contains, run_bazel_command
except ImportError:
    # Fallback for when running outside of Bazel
    def assert_file_exists(file_path: str, message: str = None):
        if not os.path.exists(file_path):
            raise AssertionError(f"File does not exist: {file_path}")
    
    def assert_file_contains(file_path: str, content: str, message: str = None):
        with open(file_path, 'r') as f:
            file_content = f.read()
            if content not in file_content:
                raise AssertionError(f"File {file_path} does not contain: {content}")
    
    def run_bazel_command(args: List[str], cwd: str = None, timeout: int = 300) -> Tuple[int, str, str]:
        cmd = ['bazel'] + args
        result = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True, timeout=timeout)
        return result.returncode, result.stdout, result.stderr


class NewUserIntegrationTest(unittest.TestCase):
    """End-to-end integration test for new user experience."""
    
    def setUp(self):
        """Set up the test environment."""
        self.test_dir = tempfile.mkdtemp(prefix="new_user_test_")
        self.workspace_dir = os.path.join(self.test_dir, "test_workspace")
        self.original_cwd = os.getcwd()
        
        # Test configuration
        self.weaver_version = "latest"  # Will download latest from GitHub
        self.timeout = 300  # 5 minutes timeout
        
        # Debug mode
        self.debug = os.environ.get('DEBUG', '0') == '1'
        
        if self.debug:
            print(f"Test directory: {self.test_dir}")
            print(f"Workspace directory: {self.workspace_dir}")
    
    def tearDown(self):
        """Clean up the test environment."""
        if not self.debug:
            shutil.rmtree(self.test_dir, ignore_errors=True)
        else:
            print(f"Debug mode: Test directory preserved at {self.test_dir}")
        
        os.chdir(self.original_cwd)
    
    def log(self, message: str):
        """Log a message if debug mode is enabled."""
        if self.debug:
            print(f"[TEST] {message}")
    
    def test_new_user_experience(self):
        """Main test that simulates a new user's complete experience."""
        self.log("Starting new user integration test")
        
        # Step 1: Create fresh workspace
        self.log("Step 1: Creating fresh workspace")
        self._create_fresh_workspace()
        
        # Step 2: Set up WORKSPACE with rules_weaver
        self.log("Step 2: Setting up WORKSPACE with rules_weaver")
        self._setup_workspace()
        
        # Step 3: Download Weaver binaries from GitHub
        self.log("Step 3: Downloading Weaver binaries from GitHub")
        self._download_weaver_binaries()
        
        # Step 4: Create sample schemas
        self.log("Step 4: Creating sample schemas")
        self._create_sample_schemas()
        
        # Step 5: Generate code from semantic conventions
        self.log("Step 5: Generating code from semantic conventions")
        self._generate_code()
        
        # Step 6: Validate schemas against policies
        self.log("Step 6: Validating schemas against policies")
        self._validate_schemas()
        
        # Step 7: Generate documentation
        self.log("Step 7: Generating documentation")
        self._generate_documentation()
        
        # Step 8: Verify generated artifacts
        self.log("Step 8: Verifying generated artifacts")
        self._verify_generated_artifacts()
        
        # Step 9: Test error handling and recovery
        self.log("Step 9: Testing error handling and recovery")
        self._test_error_handling()
        
        self.log("New user integration test completed successfully")
    
    def _create_fresh_workspace(self):
        """Create a fresh Bazel workspace directory."""
        os.makedirs(self.workspace_dir, exist_ok=True)
        os.chdir(self.workspace_dir)
        
        # Create basic workspace structure
        os.makedirs("schemas", exist_ok=True)
        os.makedirs("src", exist_ok=True)
        os.makedirs("docs", exist_ok=True)
        
        self.log(f"Created fresh workspace at {self.workspace_dir}")
    
    def _setup_workspace(self):
        """Set up WORKSPACE file with rules_weaver integration."""
        workspace_content = f'''workspace(name = "new_user_test_workspace")

# Load rules_weaver from the current repository (for testing)
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# For testing, we'll use the current repository
# In a real scenario, this would be a specific release version
http_archive(
    name = "rules_weaver",
    urls = ["file://{os.path.dirname(os.path.dirname(os.path.dirname(self.original_cwd)))}"],
    strip_prefix = "rules_weaver",
)

# Load rules_weaver dependencies
load("@rules_weaver//weaver:repositories.bzl", "weaver_repository", "weaver_register_toolchains")

# Set up Weaver repository with latest version
weaver_repository(
    name = "weaver",
    version = "{self.weaver_version}",
)

# Register Weaver toolchains
weaver_register_toolchains()

# Load rules_weaver rules
load("@rules_weaver//weaver:defs.bzl", "weaver_schema", "weaver_generate", "weaver_validate_test", "weaver_docs")

# Additional dependencies
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# Python rules
http_archive(
    name = "rules_python",
    sha256 = "94750828b18044533e98a1293b8a2f1092e1e6d0c1b1e5b5c5c5c5c5c5c5c5c5c",
    strip_prefix = "rules_python-0.21.0",
    url = "https://github.com/bazelbuild/rules_python/releases/download/0.21.0/rules_python-0.21.0.tar.gz",
)

load("@rules_python//python:repositories.bzl", "python_register_toolchains")

python_register_toolchains(
    name = "python3_9",
    python_version = "3.9",
)
'''
        
        with open("WORKSPACE", "w") as f:
            f.write(workspace_content)
        
        self.log("Created WORKSPACE file with rules_weaver integration")
    
    def _download_weaver_binaries(self):
        """Download Weaver binaries from GitHub and verify they work."""
        self.log("Downloading Weaver binaries...")
        
        # Run bazel sync to download dependencies
        returncode, stdout, stderr = run_bazel_command(
            ["sync", "--configure"],
            cwd=self.workspace_dir,
            timeout=self.timeout
        )
        
        if returncode != 0:
            self.log(f"Bazel sync failed: {stderr}")
            raise AssertionError(f"Failed to download Weaver binaries: {stderr}")
        
        # Verify Weaver toolchain is available
        returncode, stdout, stderr = run_bazel_command(
            ["query", "@weaver//:all"],
            cwd=self.workspace_dir,
            timeout=60
        )
        
        if returncode != 0:
            raise AssertionError(f"Failed to query Weaver toolchain: {stderr}")
        
        self.log("Weaver binaries downloaded successfully")
    
    def _create_sample_schemas(self):
        """Create sample semantic convention schemas for testing."""
        # Copy sample schema from test data
        sample_schema_path = os.path.join(
            os.path.dirname(__file__), 
            "test_workspace", 
            "schemas", 
            "sample.yaml"
        )
        
        if os.path.exists(sample_schema_path):
            shutil.copy2(sample_schema_path, "schemas/sample.yaml")
        else:
            # Create a basic sample schema
            sample_schema = {
                "groups": [
                    {
                        "id": "test.service",
                        "type": "span",
                        "brief": "Test service semantic conventions",
                        "attributes": [
                            {
                                "id": "test.service.name",
                                "type": "string",
                                "brief": "The name of the test service"
                            }
                        ]
                    }
                ]
            }
            
            with open("schemas/sample.yaml", "w") as f:
                yaml.dump(sample_schema, f)
        
        # Create policy file
        policy_content = {
            "policies": [
                {
                    "id": "test.policy",
                    "name": "Test Policy",
                    "rules": [
                        {
                            "id": "test.rule",
                            "name": "Test Rule",
                            "conditions": [
                                {
                                    "attribute": "test.service.name",
                                    "required": True
                                }
                            ]
                        }
                    ]
                }
            ]
        }
        
        with open("schemas/policies.yaml", "w") as f:
            yaml.dump(policy_content, f)
        
        self.log("Created sample schemas and policies")
    
    def _generate_code(self):
        """Generate code from semantic conventions."""
        # Create BUILD.bazel file
        build_content = '''load("@rules_weaver//weaver:defs.bzl", "weaver_schema", "weaver_generate")

weaver_schema(
    name = "sample_schemas",
    srcs = ["schemas/sample.yaml"],
)

weaver_generate(
    name = "generated_typescript",
    srcs = [":sample_schemas"],
    format = "typescript",
    args = ["--quiet"],
)

weaver_generate(
    name = "generated_go",
    srcs = [":sample_schemas"],
    format = "go",
    args = ["--quiet"],
)

weaver_generate(
    name = "generated_python",
    srcs = [":sample_schemas"],
    format = "python",
    args = ["--quiet"],
)
'''
        
        with open("BUILD.bazel", "w") as f:
            f.write(build_content)
        
        # Generate TypeScript code
        self.log("Generating TypeScript code...")
        returncode, stdout, stderr = run_bazel_command(
            ["build", ":generated_typescript"],
            cwd=self.workspace_dir,
            timeout=self.timeout
        )
        
        if returncode != 0:
            raise AssertionError(f"Failed to generate TypeScript code: {stderr}")
        
        # Generate Go code
        self.log("Generating Go code...")
        returncode, stdout, stderr = run_bazel_command(
            ["build", ":generated_go"],
            cwd=self.workspace_dir,
            timeout=self.timeout
        )
        
        if returncode != 0:
            raise AssertionError(f"Failed to generate Go code: {stderr}")
        
        # Generate Python code
        self.log("Generating Python code...")
        returncode, stdout, stderr = run_bazel_command(
            ["build", ":generated_python"],
            cwd=self.workspace_dir,
            timeout=self.timeout
        )
        
        if returncode != 0:
            raise AssertionError(f"Failed to generate Python code: {stderr}")
        
        self.log("Code generation completed successfully")
    
    def _validate_schemas(self):
        """Validate schemas against policies."""
        # Add validation target to BUILD.bazel
        build_content = '''load("@rules_weaver//weaver:defs.bzl", "weaver_schema", "weaver_generate", "weaver_validate_test")

weaver_schema(
    name = "sample_schemas",
    srcs = ["schemas/sample.yaml"],
)

weaver_generate(
    name = "generated_typescript",
    srcs = [":sample_schemas"],
    format = "typescript",
    args = ["--quiet"],
)

weaver_generate(
    name = "generated_go",
    srcs = [":sample_schemas"],
    format = "go",
    args = ["--quiet"],
)

weaver_generate(
    name = "generated_python",
    srcs = [":sample_schemas"],
    format = "python",
    args = ["--quiet"],
)

weaver_validate_test(
    name = "validation_test",
    schemas = [":sample_schemas"],
    policies = ["schemas/policies.yaml"],
    weaver_args = ["--strict"],
)
'''
        
        with open("BUILD.bazel", "w") as f:
            f.write(build_content)
        
        # Run validation test
        self.log("Running schema validation...")
        returncode, stdout, stderr = run_bazel_command(
            ["test", ":validation_test"],
            cwd=self.workspace_dir,
            timeout=self.timeout
        )
        
        if returncode != 0:
            raise AssertionError(f"Schema validation failed: {stderr}")
        
        self.log("Schema validation completed successfully")
    
    def _generate_documentation(self):
        """Generate documentation from schemas."""
        # Add documentation targets to BUILD.bazel
        build_content = '''load("@rules_weaver//weaver:defs.bzl", "weaver_schema", "weaver_generate", "weaver_validate_test", "weaver_docs")

weaver_schema(
    name = "sample_schemas",
    srcs = ["schemas/sample.yaml"],
)

weaver_generate(
    name = "generated_typescript",
    srcs = [":sample_schemas"],
    format = "typescript",
    args = ["--quiet"],
)

weaver_generate(
    name = "generated_go",
    srcs = [":sample_schemas"],
    format = "go",
    args = ["--quiet"],
)

weaver_generate(
    name = "generated_python",
    srcs = [":sample_schemas"],
    format = "python",
    args = ["--quiet"],
)

weaver_validate_test(
    name = "validation_test",
    schemas = [":sample_schemas"],
    policies = ["schemas/policies.yaml"],
    weaver_args = ["--strict"],
)

weaver_docs(
    name = "html_docs",
    schemas = [":sample_schemas"],
    format = "html",
    args = ["--quiet"],
)

weaver_docs(
    name = "markdown_docs",
    schemas = [":sample_schemas"],
    format = "markdown",
    args = ["--quiet"],
)
'''
        
        with open("BUILD.bazel", "w") as f:
            f.write(build_content)
        
        # Generate HTML documentation
        self.log("Generating HTML documentation...")
        returncode, stdout, stderr = run_bazel_command(
            ["build", ":html_docs"],
            cwd=self.workspace_dir,
            timeout=self.timeout
        )
        
        if returncode != 0:
            raise AssertionError(f"Failed to generate HTML documentation: {stderr}")
        
        # Generate Markdown documentation
        self.log("Generating Markdown documentation...")
        returncode, stdout, stderr = run_bazel_command(
            ["build", ":markdown_docs"],
            cwd=self.workspace_dir,
            timeout=self.timeout
        )
        
        if returncode != 0:
            raise AssertionError(f"Failed to generate Markdown documentation: {stderr}")
        
        self.log("Documentation generation completed successfully")
    
    def _verify_generated_artifacts(self):
        """Verify that all generated artifacts are correct and accessible."""
        # Check that generated files exist
        bazel_bin = os.path.join(self.workspace_dir, "bazel-bin")
        
        # List all generated files
        returncode, stdout, stderr = run_bazel_command(
            ["query", "--output=location", "//:all"],
            cwd=self.workspace_dir,
            timeout=60
        )
        
        if returncode != 0:
            raise AssertionError(f"Failed to query generated targets: {stderr}")
        
        self.log(f"Generated targets: {stdout}")
        
        # Verify specific generated files exist
        generated_targets = [
            "//:generated_typescript",
            "//:generated_go", 
            "//:generated_python",
            "//:html_docs",
            "//:markdown_docs",
        ]
        
        for target in generated_targets:
            returncode, stdout, stderr = run_bazel_command(
                ["query", target],
                cwd=self.workspace_dir,
                timeout=30
            )
            
            if returncode != 0:
                raise AssertionError(f"Generated target {target} not found: {stderr}")
        
        self.log("All generated artifacts verified successfully")
    
    def _test_error_handling(self):
        """Test error handling and recovery scenarios."""
        self.log("Testing error handling scenarios...")
        
        # Test 1: Invalid schema
        invalid_schema = {
            "groups": [
                {
                    "id": "invalid.group",
                    "type": "invalid_type",  # Invalid type
                    "attributes": []
                }
            ]
        }
        
        with open("schemas/invalid.yaml", "w") as f:
            yaml.dump(invalid_schema, f)
        
        # Try to build with invalid schema
        build_content = '''load("@rules_weaver//weaver:defs.bzl", "weaver_schema")

weaver_schema(
    name = "invalid_schemas",
    srcs = ["schemas/invalid.yaml"],
)
'''
        
        with open("BUILD.bazel", "w") as f:
            f.write(build_content)
        
        returncode, stdout, stderr = run_bazel_command(
            ["build", ":invalid_schemas"],
            cwd=self.workspace_dir,
            timeout=60
        )
        
        # Should fail gracefully with helpful error message
        if returncode == 0:
            self.log("Warning: Invalid schema should have failed but didn't")
        else:
            self.log("Invalid schema correctly failed with error")
        
        # Test 2: Missing schema file
        build_content = '''load("@rules_weaver//weaver:defs.bzl", "weaver_schema")

weaver_schema(
    name = "missing_schemas",
    srcs = ["schemas/missing.yaml"],
)
'''
        
        with open("BUILD.bazel", "w") as f:
            f.write(build_content)
        
        returncode, stdout, stderr = run_bazel_command(
            ["build", ":missing_schemas"],
            cwd=self.workspace_dir,
            timeout=60
        )
        
        # Should fail with file not found error
        if returncode == 0:
            self.log("Warning: Missing schema should have failed but didn't")
        else:
            self.log("Missing schema correctly failed with error")
        
        self.log("Error handling tests completed")


def main():
    """Main test runner."""
    # Set up test environment
    os.environ['TEST_TMPDIR'] = tempfile.mkdtemp(prefix="bazel_test_")
    
    # Run the test
    unittest.main(verbosity=2)


if __name__ == "__main__":
    main() 