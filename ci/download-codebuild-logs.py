#!/usr/bin/env -S uv run
# /// script
# requires-python = ">=3.13"
# dependencies = ["boto3"]
# ///
"""Download CloudWatch logs for all CodeBuild projects matching a CI prefix.

Usage:
    ./ci/download-codebuild-logs.py <ci-prefix> [--region REGION] [--output-dir DIR]

Examples:
    ./ci/download-codebuild-logs.py ci-202982
    ./ci/download-codebuild-logs.py ci-202982 --region eu-west-1
"""

import argparse
import logging
import sys
from pathlib import Path

# Allow importing ephemerallib when run from repo root or ci/ directory
sys.path.insert(0, str(Path(__file__).resolve().parent))

import boto3

from ephemerallib.codebuild_logs import download_codebuild_logs

logging.basicConfig(level=logging.INFO, format="%(message)s")


def main():
    parser = argparse.ArgumentParser(description="Download CodeBuild logs for a CI run.")
    parser.add_argument("ci_prefix", help="CI prefix (e.g. ci-202982)")
    parser.add_argument("--region", default="us-east-1", help="AWS region (default: us-east-1)")
    parser.add_argument("--output-dir", help="Output directory (default: codebuild-logs-<prefix>)")
    args = parser.parse_args()

    output_dir = args.output_dir or f"codebuild-logs-{args.ci_prefix}"
    session = boto3.Session(region_name=args.region)

    files = download_codebuild_logs(session, args.ci_prefix, output_dir)
    if not files:
        return

    print(f"\n{len(files)} log file(s) saved to {output_dir}/")


if __name__ == "__main__":
    main()
