#!/usr/bin/env python3
"""
Mock Weaver binary for testing OpenTelemetry Weaver rules.

This script simulates the behavior of the actual Weaver binary
for testing purposes.
"""

import sys
import os
import argparse
import json
from pathlib import Path

def create_output_files(output_dir, format_type, schema_names):
    """Create mock output files based on the format and schema names."""
    output_path = Path(output_dir)
    output_path.mkdir(parents=True, exist_ok=True)
    
    for schema_name in schema_names:
        schema_dir = output_path / schema_name
        schema_dir.mkdir(exist_ok=True)
        
        if format_type == "typescript":
            # Create TypeScript output
            ts_file = schema_dir / "index.ts"
            ts_file.write_text(f"""// Generated TypeScript code for {schema_name}
export interface {schema_name.title()}Config {{
    // Mock TypeScript interface
}}

export class {schema_name.title()}Service {{
    constructor(config: {schema_name.title()}Config) {{
        // Mock service implementation
    }}
}}
""")
        elif format_type == "html":
            # Create HTML documentation
            html_file = schema_dir / "index.html"
            html_file.write_text(f"""<!DOCTYPE html>
<html>
<head>
    <title>{schema_name} Documentation</title>
</head>
<body>
    <h1>{schema_name} Documentation</h1>
    <p>Mock HTML documentation for {schema_name}</p>
</body>
</html>
""")
        elif format_type == "markdown":
            # Create Markdown documentation
            md_file = schema_dir / f"{schema_name}.md"
            md_file.write_text(f"""# {schema_name} Documentation

Mock Markdown documentation for {schema_name}.

## Overview
This is a mock documentation file generated for testing purposes.
""")

def main():
    parser = argparse.ArgumentParser(description="Mock Weaver binary")
    parser.add_argument("command", choices=["generate", "validate", "docs"], help="Weaver command")
    parser.add_argument("--output-dir", help="Output directory")
    parser.add_argument("--output", help="Output file path")
    parser.add_argument("--format", help="Output format")
    parser.add_argument("--policy", action="append", help="Policy files")
    parser.add_argument("--template", help="Template file")
    parser.add_argument("--verbose", action="store_true", help="Verbose output")
    parser.add_argument("--strict", action="store_true", help="Strict mode")
    parser.add_argument("schema_files", nargs="*", help="Schema files")
    
    # Parse all arguments
    args = parser.parse_args()
    
    # Always print debug info for now
    print(f"Mock Weaver: Debug - Command: {args.command}")
    print(f"Mock Weaver: Debug - Schema files: {args.schema_files}")
    print(f"Mock Weaver: Debug - Output dir: {args.output_dir}")
    print(f"Mock Weaver: Debug - Output file: {args.output}")
    print(f"Mock Weaver: Debug - Format: {args.format}")
    print(f"Mock Weaver: Debug - All sys.argv: {sys.argv}")
    
    if args.verbose:
        print(f"Mock Weaver: Executing {args.command} command")
        print(f"Schema files: {args.schema_files}")
        print(f"Output directory: {args.output_dir}")
        print(f"Output file: {args.output}")
        print(f"Format: {args.format}")
    
    if args.command == "generate":
        if not args.output_dir or not args.format:
            print("Error: --output-dir and --format are required for generate command")
            sys.exit(1)
        
        # Extract schema names from file paths
        schema_names = []
        for schema_file in args.schema_files:
            if schema_file.endswith('.yaml') or schema_file.endswith('.yml'):
                schema_name = Path(schema_file).stem
                schema_names.append(schema_name)
        
        create_output_files(args.output_dir, args.format, schema_names)
        print(f"Mock Weaver: Generated {args.format} code for {len(schema_names)} schemas")
        
    elif args.command == "validate":
        # Use the specified output file path or default
        output_file = args.output or "validation_result.txt"
        print(f"Mock Weaver: Debug - Creating validation output at: {output_file}")
        
        # Create validation result file at the expected location
        with open(output_file, "w") as f:
            f.write("Mock validation completed successfully\n")
            f.write(f"Validated {len(args.schema_files)} schema files\n")
            if args.strict:
                f.write("Strict mode enabled\n")
        
        print(f"Mock Weaver: Validation completed, results written to {output_file}")
        
    elif args.command == "docs":
        if not args.output_dir:
            print("Error: --output-dir is required for docs command")
            sys.exit(1)
        
        format_type = args.format or "html"
        
        # Extract schema names from file paths
        schema_names = []
        for schema_file in args.schema_files:
            if schema_file.endswith('.yaml') or schema_file.endswith('.yml'):
                schema_name = Path(schema_file).stem
                schema_names.append(schema_name)
        
        create_output_files(args.output_dir, format_type, schema_names)
        print(f"Mock Weaver: Generated {format_type} documentation for {len(schema_names)} schemas")
    
    print("Mock Weaver: Command completed successfully")
    sys.exit(0)

if __name__ == "__main__":
    main() 