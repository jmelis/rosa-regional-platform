# ROSA Regional Platform

## Overview

The ROSA Regional Platform is a strategic initiative to redesign ROSA HCP (Hosted Control Planes) from a globally-centralized management model to a regionally-distributed architecture. Each AWS region operates independently with its own control plane infrastructure, improving reliability and reducing dependencies on global services.

## Architecture

Each region has three layers:

1. **Regional Cluster (RC)** - EKS cluster running Platform API, CLM, Maestro, ArgoCD, and Tekton
2. **Management Clusters (MC)** - EKS clusters hosting customer HCP control planes via HyperShift
3. **Customer Hosted Clusters** - ROSA HCP clusters with control planes in MC and workers in customer accounts

For architectural Q&A, see [FAQ.md](FAQ.md).

## Design Documents

- [ECS Fargate Bootstrap for Private EKS](design/fully-private-eks-bootstrap.md) - How private clusters are bootstrapped
- [GitOps Cluster Configuration](design/gitops-cluster-configuration.md) - ArgoCD ApplicationSet patterns and progressive deployment
- [Maestro MQTT Resource Distribution](design/maestro-mqtt-resource-distribution.md) - RC-to-MC communication via AWS IoT Core
- [Pipeline-Based Cluster Lifecycle](design/pipeline-based-lifecycle.md) - CodePipeline hierarchy for cluster provisioning
- [Regional Account Minting](design/regional-account-minting.md) - AWS account structure and provisioning pipelines

## Operational Guides

- [Provision a New Central Pipeline](central-pipeline-provisioning.md) - CodePipeline-based provisioning
- [Provision a New Region (Manual)](full-region-provisioning.md) - Step-by-step manual provisioning
