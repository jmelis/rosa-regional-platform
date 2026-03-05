### What cluster types does the regional architecture support?

- Designed exclusively for **ROSA HCP** (Hosted Control Planes)
- ROSA Classic and OSD are not supported and remain globally managed

### What is the difference between the Regional Cluster and the Regional-Access Cluster?

We will **not** use Regional-Access Clusters. Instead, we use zero-operator access as the default model, with ephemeral boundary containers for break-glass scenarios.

### What is the Management Cluster Reconciler (MCR)?

MCR is a component within CLM that orchestrates Management Cluster lifecycle, enabling scalable management of multiple MCs per region (dynamic rather than static). Developed by the Hyperfleet team.

### Where is the global control plane located?

Its purpose is to run the Regional Provisioning Pipelines. The technology stack and location decision is pending. See [Pipeline-Based Cluster Lifecycle](design/pipeline-based-lifecycle.md).

### Where does the AuthZ service run?

Decision pending. Current design envisions AWS IAM via Roles/Permissions created by customers in their own accounts. Kessel is being considered as an alternative (would run in the RC).

### Is the Central Data Plane in the regional accounts or the global account?

- The Central Data Plane (IAM, identity, global access control) is **global** via AWS IAM
- Red Hat SSO is needed once to link Red Hat identities to AWS IAM identities; after that, all access control is via AWS IAM
- Billing through AWS Marketplace

### How long can a region operate if Global Services go down?

- Depends on AWS IAM availability
- Each region is independent of other regions
- No Red Hat global services are critical for regional operation

### Is there a requirement to bring up a consoledot equivalent in another region within a set timeframe?

The console will be served via CloudFront CDN, connecting to regional endpoints. No global ROSA API endpoints will exist.

### What is the path to recovery after a disaster?

See the disaster recovery section in the [Maestro design doc](design/maestro-mqtt-resource-distribution.md#state-management) for state management details.

- **CLM**: Single source of truth, persisted in RDS with cross-region backups
- **MC etcd**: Continuously backed up to a dedicated DR AWS account
- **Maestro cache**: Rebuilt from CLM; loss doesn't impact recovery
- **Break-glass access**: Ephemeral containers for emergency access

### What are the key SLOs to maintain during an outage?

- Customer cluster API access (HCP control planes) and CUJs
- CLM for cluster lifecycle operations
- MC Reconciler for dynamic scaling of MCs
- Management Cluster availability

### What happens when the Kubernetes API on a Management Cluster goes down?

We open a support case with AWS. If unrecoverable, provision a new MC, restore HCPs from etcd backups, and update CLM.

### Should we use AWS Landing Zone for region setup?

TBD. The pipeline-based approach supports either implementation. See [Regional Account Minting](design/regional-account-minting.md).

### Is there a canary region for testing new releases?

Yes, sector-based progressive deployment aligned with [ADR-0032](https://github.com/openshift-online/architecture/blob/main/hcm/decisions/archives/SD-ADR-0032_HyperShift_Change_Management_Strategy.md). See [GitOps Cluster Configuration](design/gitops-cluster-configuration.md#progressive-deployment-strategy).

### Is the Regional API Gateway Red Hat managed?

Yes. Consists of AWS API Gateway + VPC Link v2 + Internal ALB, deployed via Terraform. See the [api-gateway module](../terraform/modules/api-gateway/).

### How is PrivateLink used in this architecture?

- RC and MC are in separate VPCs with private Kube APIs
- RC MUST have **no** network path to MC Kube API (and vice versa)
- PrivateLink is being considered for observability and ArgoCD but we're trying to avoid it. TBD.

### Is OCM/CS deployed to each region?

**No**. OCM/CS/AMS are replaced by **CLM** (Cluster Lifecycle Manager). One CLM instance per RC. See the [HyperFleet infrastructure module](../terraform/modules/hyperfleet-infrastructure/).

### Is this design without App-Interface in favor of ArgoCD?

**Yes** for CD purposes. We might still use App-Interface for the Central Control Plane (pending). See [GitOps Cluster Configuration](design/gitops-cluster-configuration.md).

### Is Backplane part of the Regional Cluster or its own cluster?

Backplane will not be used. We favor zero-operator access with ephemeral boundary containers. See the [bastion module](../terraform/modules/bastion/).

### What is used for IDS?

Not yet explored.

### Is Splunk cloud or local to each region?

Not yet explored.
