#!/usr/bin/env python3
"""
Test Structure Validation Script

This script validates that the e2e test structure is correct and all required files are in place.
"""

import os
import sys
from pathlib import Path

def validate_test_structure():
    """Validate the e2e test structure."""
    base_dir = Path(__file__).parent
    errors = []
    warnings = []
    
    print("Validating e2e test structure...")
    
    # Required files and directories
    required_files = [
        "BUILD.bazel",
        "README.md",
        "test_runner.py",
        "test_workspace/BUILD.bazel",
        "test_workspace/WORKSPACE",
        "test_workspace/schemas/sample.yaml",
        "test_workspace/schemas/policies.yaml",
        "test_workspace/expected_outputs/README.md",
    ]
    
    # Check required files
    for file_path in required_files:
        full_path = base_dir / file_path
        if not full_path.exists():
            errors.append(f"Missing required file: {file_path}")
        else:
            print(f"✅ {file_path}")
    
    # Check test workspace structure
    workspace_dir = base_dir / "test_workspace"
    if workspace_dir.exists():
        # Check for additional files that should exist
        expected_dirs = ["schemas", "expected_outputs"]
        for dir_name in expected_dirs:
            dir_path = workspace_dir / dir_name
            if not dir_path.exists():
                errors.append(f"Missing directory: test_workspace/{dir_name}")
            else:
                print(f"✅ test_workspace/{dir_name}/")
    
    # Check BUILD.bazel content
    build_file = base_dir / "BUILD.bazel"
    if build_file.exists():
        with open(build_file, 'r') as f:
            content = f.read()
            if "new_user_integration_test" not in content:
                errors.append("BUILD.bazel missing new_user_integration_test target")
            if "e2e_test_suite" not in content:
                errors.append("BUILD.bazel missing e2e_test_suite target")
            if "integration_test_framework" not in content:
                warnings.append("BUILD.bazel may be missing integration_test_framework import")
    
    # Check test runner content
    runner_file = base_dir / "test_runner.py"
    if runner_file.exists():
        with open(runner_file, 'r') as f:
            content = f.read()
            if "NewUserIntegrationTest" not in content:
                errors.append("test_runner.py missing NewUserIntegrationTest class")
            if "test_new_user_experience" not in content:
                errors.append("test_runner.py missing test_new_user_experience method")
    
    # Check schema files
    sample_schema = base_dir / "test_workspace" / "schemas" / "sample.yaml"
    if sample_schema.exists():
        with open(sample_schema, 'r') as f:
            content = f.read()
            if "groups:" not in content:
                warnings.append("sample.yaml may not contain valid semantic convention groups")
    
    policy_file = base_dir / "test_workspace" / "schemas" / "policies.yaml"
    if policy_file.exists():
        with open(policy_file, 'r') as f:
            content = f.read()
            if "policies:" not in content:
                warnings.append("policies.yaml may not contain valid policies")
    
    # Report results
    print("\n" + "="*50)
    print("VALIDATION RESULTS")
    print("="*50)
    
    if errors:
        print(f"\n❌ ERRORS ({len(errors)}):")
        for error in errors:
            print(f"  - {error}")
    
    if warnings:
        print(f"\n⚠️  WARNINGS ({len(warnings)}):")
        for warning in warnings:
            print(f"  - {warning}")
    
    if not errors and not warnings:
        print("\n✅ All validations passed!")
        print("The e2e test structure is correct and ready for use.")
    
    if errors:
        print(f"\n❌ Found {len(errors)} errors. Please fix them before running the test.")
        return False
    
    if warnings:
        print(f"\n⚠️  Found {len(warnings)} warnings. Please review them.")
    
    return True

def main():
    """Main validation function."""
    success = validate_test_structure()
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main() 