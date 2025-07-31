#!/bin/bash
# End-to-End Integration Test Runner Shell Wrapper
# This script runs the Python test runner for the new user integration test

set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Find the Python test runner
PYTHON_SCRIPT="${SCRIPT_DIR}/test_runner.py"

# Check if Python is available
if ! command -v python3 &> /dev/null; then
    echo "ERROR: python3 is not available"
    exit 1
fi

# Check if the Python script exists
if [[ ! -f "${PYTHON_SCRIPT}" ]]; then
    echo "ERROR: Python test runner not found at ${PYTHON_SCRIPT}"
    exit 1
fi

# Set up environment variables
export TEST_TMPDIR="${TEST_TMPDIR:-/tmp}"
export DEBUG="${DEBUG:-0}"

echo "Starting End-to-End Integration Test for New User Experience"
echo "=============================================================="
echo "Test Directory: ${SCRIPT_DIR}"
echo "Python Script: ${PYTHON_SCRIPT}"
echo "Debug Mode: ${DEBUG}"
echo ""

# Run the Python test
python3 "${PYTHON_SCRIPT}" "$@"

# Capture the exit code
EXIT_CODE=$?

echo ""
echo "=============================================================="
if [[ ${EXIT_CODE} -eq 0 ]]; then
    echo "✅ End-to-End Integration Test PASSED"
else
    echo "❌ End-to-End Integration Test FAILED (exit code: ${EXIT_CODE})"
fi
echo "=============================================================="

exit ${EXIT_CODE} 