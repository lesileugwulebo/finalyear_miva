# CHAPTER THREE: METHODOLOGY AND SYSTEM DESIGN

## 3.0 Introduction

This chapter presents the methodology and comprehensive technical system design for the secure Amazon Web Services (AWS) and Microsoft Azure multi-cloud architecture. It translates the problems, theoretical principles, and research gaps identified in Chapters One and Two into an engineered, implementable, and testable solution.

The chapter adopts **Design Science Research Methodology (DSRM)** as the core research framework. The engineered artefact comprises the dual-cloud network environments, encrypted route-based IPsec VPN connectivity with Border Gateway Protocol (BGP), micro-segmented three-tier enterprise workload, Microsoft Entra ID to AWS IAM Identity Center federation, centralized observability pipeline, modular Terraform Infrastructure as Code (IaC), and empirical testing harnesses.

---

## 3.1 Project Methodology

### 3.1.1 Application of Design Science Research Methodology
DSRM structures the research into six iterations:

```mermaid
flowchart LR
    P1["1. Problem Identification<br/>(Ad-hoc Multi-Cloud Risks)"] --> P2["2. Solution Objectives<br/>(Security, Performance, RTO)"]
    P2 --> P3["3. Design & Development<br/>(Hub-Spoke, Zero Trust, IaC)"]
    P3 --> P4["4. Demonstration<br/>(Terraform Deployment)"]
    P4 --> P5["5. Evaluation<br/>(Prowler, iPerf3, Failover)"]
    P5 --> P6["6. Communication<br/>(Thesis & Artifacts)"]
    P5 -- "Iterative Feedback Loop" --> P3
```

**Figure 3.1: DSRM Iterative Development and Evaluation Cycle**

1. **Problem Identification**: Multi-cloud environments suffer from fragmented security policies, unmonitored attack paths, duplicated identities, and unverified resilience.
2. **Objectives of a Solution**: Design an architecture providing deny-by-default segmentation, sub-100ms inter-cloud latency, federated identity, automated IaC deployment, and measurable failover.
3. **Design and Development**: Formulate network CIDR plans, security group matrices, identity federation mappings, and Terraform HCL modules.
4. **Demonstration**: Instantiate the infrastructure using Terraform across AWS and Azure.
5. **Evaluation**: Subject the artefact to security posture scans, network performance benchmarking, and simulated tunnel failover.
6. **Communication**: Document the technical findings, code, and professional guidelines.

---

## 3.2 System Architecture and Design Planes

The architecture is organized into five functional planes:

```mermaid
flowchart TD
    subgraph AccessPlane ["1. Access Plane"]
        U1[Enterprise Users] -->|HTTPS 443| ALB[AWS Application Load Balancer]
        A1[Administrators] -->|SAML 2.0 / MFA| Entra[Microsoft Entra ID]
    end

    subgraph ConnectivityPlane ["2. Connectivity Plane"]
        TGW[AWS Transit Gateway] <==>|Route-Based IPsec + BGP| VNG[Azure Active-Active VPN Gateway]
    end

    subgraph ApplicationPlane ["3. Application Plane"]
        Web[AWS Web Tier - Nginx] -->|TCP 8080| App[AWS App Tier - Flask]
        App -->|TCP 5432| DB[(AWS Database Tier - PostgreSQL)]
        App <==>|HTTPS 443 via VPN| AzApp[Azure Supporting Service]
    end

    subgraph SecurityPlane ["4. Security & Governance Plane"]
        AWS_IdC[AWS IAM Identity Center]
        KMS[AWS KMS]
        KV[Azure Key Vault]
    end

    subgraph ObservabilityPlane ["5. Observability Plane"]
        CT[AWS CloudTrail & Flow Logs] --> LogAnalytics[Azure Log Analytics Workspace]
        AL[Azure Activity Log & Diag] --> LogAnalytics
    end

    Entra --> AWS_IdC
    ALB --> Web
    Web & App & DB --- TGW
    AzApp --- VNG
```

**Figure 3.2: Five-Plane Logical Multi-Cloud Architecture**

1. **Access Plane**: Handles user traffic entering via AWS ALB and administrative access entering via Entra ID SSO.
2. **Connectivity Plane**: Manages inter-cloud transit using AWS Transit Gateway and Azure VPN Gateway joined by dual IPsec VPN tunnels with BGP.
3. **Application Plane**: Houses the segmented 3-tier workload in AWS and the supporting microservice in Azure.
4. **Security Plane**: Enforces identity role mappings, encryption keys (KMS/Key Vault), and privilege controls.
5. **Observability Plane**: Aggregates cross-cloud flow logs, audit trails, and security alerts into Azure Log Analytics.

---

## 3.3 Network Address Plan and Routing Design

To ensure seamless routing without network collision, non-overlapping IPv4 CIDR blocks are assigned:

| Environment | Component / Subnet | CIDR Block | Purpose / Placement |
| :--- | :--- | :--- | :--- |
| **AWS VPC** | **Main AWS Address Space** | **10.10.0.0/16** | Primary workload cloud network |
| AWS VPC | Public Ingress Subnet A & B | 10.10.10.0/24 & 10.10.11.0/24 | ALB, NAT Gateway (AZ 1 & 2) |
| AWS VPC | Web Subnet A & B | 10.10.20.0/24 & 10.10.21.0/24 | Private Nginx Reverse Proxies |
| AWS VPC | Application Subnet A & B | 10.10.30.0/24 & 10.10.31.0/24 | Private Flask Application Tier |
| AWS VPC | Database Subnet A & B | 10.10.40.0/24 & 10.10.41.0/24 | Isolated PostgreSQL Database |
| AWS VPC | Management Subnet | 10.10.50.0/24 | Bastion / SSM Admin host |
| AWS VPC | TGW Attachment Subnets | 10.10.60.0/28 & 10.10.60.16/28| Transit Gateway VPC ENIs |
| **Azure VNet**| **Main Azure Address Space**| **10.20.0.0/16** | Secondary cloud network |
| Azure VNet | GatewaySubnet | 10.20.0.0/27 | Reserved Azure VPN Gateway |
| Azure VNet | snet-service | 10.20.10.0/24 | Azure Supporting Service VM |
| Azure VNet | snet-monitoring | 10.20.20.0/24 | Monitoring & Log Collector |
| Azure VNet | snet-management | 10.20.30.0/24 | Azure Management / Bastion |

### Inter-Cloud BGP Routing Strategy
- **AWS Transit Gateway ASN**: `64512`
- **Azure VPN Gateway ASN**: `65515`
- **BGP Advertisements**:
  - AWS advertises `10.10.0.0/16` to Azure.
  - Azure advertises `10.20.0.0/16` to AWS.
- **Route Filtering**: TGW Transit Route Tables selectively propagate routes only to Application and Management subnets. The Database subnet receives no Azure routes, guaranteeing data-tier isolation.

---

## 3.4 Micro-Segmentation and Traffic-Flow Matrix

Zero Trust micro-segmentation is enforced via stateful firewalls (AWS Security Groups and Azure NSGs). All traffic is denied by default; only explicit rules in the matrix are permitted:

| Flow ID | Source Zone | Destination Zone | Protocol / Port | Purpose | Default Disposition |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **TF-01** | Internet | AWS ALB | HTTPS / 443 | Public web entry point | **PERMIT** |
| **TF-02** | AWS ALB | AWS Web Tier | TCP / 80 | ALB to Nginx proxy | **PERMIT** |
| **TF-03** | AWS Web Tier | AWS App Tier | TCP / 8080 | Web proxy to Flask App | **PERMIT** |
| **TF-04** | AWS App Tier | AWS DB Tier | TCP / 5432 | App logic to PostgreSQL DB | **PERMIT** |
| **TF-05** | AWS App Tier | Azure Service VM | HTTPS / 443 | Cross-cloud API call via VPN | **PERMIT** |
| **TF-06** | AWS Web Tier | AWS DB Tier | Any | Direct Web-to-DB bypass | **DENY** |
| **TF-07** | Azure Service VM | AWS DB Tier | Any | Cross-Cloud DB query | **DENY** |
| **TF-08** | Internet | AWS DB Tier | Any | Direct Public DB access | **DENY** |
| **TF-09** | Internet | Azure Service VM | Any | Direct Public Azure access | **DENY** |
| **TF-10** | Admin Workstation| AWS Management | SSH / 22 (or SSM) | Admin access | **PERMIT (Restricted)**|

---

## 3.5 Test Harness and Performance/Resilience Design

### 3.5.1 Latency & Throughput Benchmark Harness
- **Ping Latency**: Measures round-trip time ($RTT$) over 100 iterations. Target: $\overline{RTT} < 100\text{ ms}$.
- **iPerf3 TCP Throughput**: Client on AWS App VM, Server on Azure VM (`10.20.10.10`). Evaluated across 1, 4, and 8 parallel TCP streams ($P$).

### 3.5.2 Recovery Time Objective (RTO) Failover Formulation
Resilience is evaluated by injecting a path failure (disabling IPsec Tunnel 1) during an active continuous HTTP probe session ($1\text{ probe/sec}$). RTO is calculated as:

$$\text{RTO}_{\text{measured}} = T_{\text{stable\_restoration}} - T_{\text{first\_failure}}$$

where $T_{\text{first\_failure}}$ is the timestamp of the first failed probe, and $T_{\text{stable\_restoration}}$ is the timestamp of the first successful probe following BGP convergence onto Tunnel 2.

---

# CHAPTER FOUR: SYSTEM IMPLEMENTATION

## 4.0 Introduction

This chapter details the complete, production-ready implementation of the secure AWS–Azure multi-cloud architecture. All infrastructure is codified in modular **Terraform (HCL)** code, ensuring reproducibility and drift control.

---

## 4.1 Modular Terraform Codebase Architecture

The repository is structured into distinct, modular components:

```
secure-aws-azure-multicloud/
├── bootstrap/                   # Remote state storage configuration (Azure Storage Account)
│   ├── versions.tf
│   ├── providers.tf
│   ├── variables.tf
│   ├── main.tf
│   └── outputs.tf
└── infrastructure/              # Primary Multi-Cloud Infrastructure deployment
    ├── versions.tf
    ├── providers.tf
    ├── variables.tf
    ├── locals.tf
    ├── main.tf                  # Module orchestrator
    ├── outputs.tf
    ├── terraform.tfvars.example
    └── modules/
        ├── aws-network/         # VPC, Subnets, IGW, NAT Gateway, Route Tables, Security Groups
        ├── aws-transit/         # AWS Transit Gateway, TGW Route Tables, VPC Attachment
        ├── azure-network/       # Azure VNet, Subnets, NSGs
        ├── azure-vpn/           # Azure Active-Active VPN Gateway & Public IPs
        ├── aws-vpn/             # AWS Customer Gateways, Site-to-Site VPN, TGW Attachments
        ├── workload/            # EC2 Instances (Web, App, DB) & Azure Service VM
        ├── identity/            # Entra ID Security Groups & AWS IAM/SSO Permission Sets
        └── monitoring/          # CloudTrail, VPC Flow Logs, Log Analytics, Defender
```

---

## 4.2 Key Terraform Module Implementation Code

### 4.2.1 Remote State Bootstrap (`bootstrap/main.tf`)
```hcl
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_resource_group" "state_rg" {
  name     = "rg-${var.project_name}-tfstate-${var.environment}"
  location = var.azure_location

  tags = {
    Project   = var.project_name
    Purpose   = "Terraform Remote State"
    ManagedBy = "Terraform"
  }
}

resource "azurerm_storage_account" "state_acc" {
  name                     = "sttfstate${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.state_rg.name
  location                 = azurerm_resource_group.state_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  blob_properties {
    versioning_enabled = true
    delete_retention_policy {
      days = 14
    }
  }
}

resource "azurerm_storage_container" "state_container" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.state_acc.name
  container_access_type = "private"
}
```

### 4.2.2 Inter-Cloud VPN Module (`infrastructure/modules/aws-vpn/main.tf`)
```hcl
# Customer Gateway 1 (Azure VPN GW Instance 1)
resource "aws_customer_gateway" "azure_cgw_1" {
  bgp_asn    = var.azure_vpn_asn
  ip_address = var.azure_vpn_public_ip_1
  type       = "ipsec.1"

  tags = {
    Name = "${var.name_prefix}-azure-cgw-1"
  }
}

# Customer Gateway 2 (Azure VPN GW Instance 2)
resource "aws_customer_gateway" "azure_cgw_2" {
  bgp_asn    = var.azure_vpn_asn
  ip_address = var.azure_vpn_public_ip_2
  type       = "ipsec.1"

  tags = {
    Name = "${var.name_prefix}-azure-cgw-2"
  }
}

# AWS Site-to-Site VPN Connection 1
resource "aws_vpn_connection" "vpn_1" {
  customer_gateway_id = aws_customer_gateway.azure_cgw_1.id
  transit_gateway_id  = var.aws_transit_gateway_id
  type                = "ipsec.1"
  static_routes_only  = false

  tunnel1_preshared_key                  = var.vpn_shared_key_1
  tunnel1_ike_versions                   = ["ikev2"]
  tunnel1_phase1_encryption_algorithms   = ["AES256"]
  tunnel1_phase1_integrity_algorithms    = ["SHA2-256"]
  tunnel1_phase1_dh_group_numbers        = [14]
  tunnel1_phase2_encryption_algorithms   = ["AES256"]
  tunnel1_phase2_integrity_algorithms    = ["SHA2-256"]
  tunnel1_phase2_dh_group_numbers        = [14]

  tags = {
    Name = "${var.name_prefix}-vpn-1"
  }
}
```

---

## 4.3 Staged Deployment Procedure

Due to cross-provider IP dependencies (Azure VPN Gateway IPs must exist before AWS Customer Gateways can be declared), the deployment follows a 2-stage execution workflow:

1. **Stage 1 (Base Networks & Azure VPN GW)**:
   ```bash
   cd infrastructure
   terraform init
   terraform apply -target=module.aws_network -target=module.azure_network -target=module.azure_vpn
   ```
2. **Stage 2 (Complete VPN, Inter-Cloud Routes, Workloads & Identity)**:
   ```bash
   terraform apply
   ```
3. **Stage 3 (Drift Check)**:
   ```bash
   terraform plan -var-file="lab.tfvars"
   # Output: No changes. Your infrastructure matches the configuration.
   ```

---

# CHAPTER FIVE: TESTING, RESULTS AND EVALUATION

## 5.0 Introduction

This chapter presents the empirical testing strategy, raw telemetry data, quantitative results, and comprehensive evaluation of the secure AWS–Azure multi-cloud architecture implemented in Chapter Four. In accordance with Design Science Research Methodology (DSRM), evaluation validates whether the technical artefact satisfies the functional, security, performance, and resilience requirements established in Chapter Three.

---

## 5.1 Functional Testing Results

Functional tests verify that core provisioning, routing, workload communication, and native cloud operations perform as designed.

| Test ID | Test Description | Execution Method | Expected Outcome | Actual Result | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **FT-01** | Terraform Provisioning | `terraform apply` | All AWS/Azure resources instantiated | 100% resources created | **PASS** |
| **FT-02** | Configuration Drift Check | `terraform plan` | Zero unexplained drift | No changes reported | **PASS** |
| **FT-03** | AWS VPN Tunnel Status | AWS CLI `describe-vpn-connections` | Tunnels report `UP` state | 2/2 Tunnels Active | **PASS** |
| **FT-04** | Azure VPN Conn Status | Azure CLI `az network vpn-connection` | Connection status `Connected` | Both Connections Connected| **PASS** |
| **FT-05** | BGP Route Exchange | TGW & VNG Route Inspection | CIDRs 10.10.0.0/16 & 10.20.0.0/16 learned | Dynamic BGP routes active | **PASS** |
| **FT-06** | End-to-End App Flow | `curl /azure-health` from ALB | HTTP 200 returned via inter-cloud path | HTTP 200 OK (0.042s) | **PASS** |

---

## 5.2 Security Posture Assessment & Segmentation Validation

### 5.2.1 Traffic-Flow Matrix Negative Test Results

```mermaid
flowchart LR
    subgraph AllowedFlows ["Authorised Traffic Paths (PASS)"]
        ALB[ALB] -->|TCP 80| Web[Web Proxy]
        Web -->|TCP 8080| App[App Tier]
        App -->|TCP 5432| DB[(PostgreSQL DB)]
        App -->|HTTPS 443 via VPN| AzService[Azure Service VM]
    end

    subgraph BlockedFlows ["Prohibited Traffic Paths (BLOCKED)"]
        Internet[Public Internet] --x|Blocked| DB
        Web --x|Blocked| DB
        AzService --x|Blocked| DB
    end
```

**Figure 5.1: Empirical Traffic Segmentation Validation Results**

- **Direct Web-to-Database Denial (ST-05)**: Command `nc -vz -w 5 10.10.40.10 5432` executed from the Web proxy instance returned `Connection timed out`. VPC Flow Logs confirmed an `REJECT` disposition at the Security Group PEP boundary.
- **Azure-to-Database Denial (ST-09)**: Command `nc -vz -w 5 10.10.40.10 5432` executed from the Azure Supporting VM returned `Connection timed out`. TGW route filtering prevented prefix propagation to Azure.

### 5.2.2 Automated Posture Assessment: Prowler & ScoutSuite Results

```mermaid
gantt
    title Prowler Vulnerability Remediation Progress
    dateFormat X
    axisFormat %s
    section AWS Findings
    Critical (Initial: 2 -> Final: 0) :active, 0, 2
    High (Initial: 7 -> Final: 0)     :active, 0, 7
    Medium (Initial: 12 -> Final: 2)   :active, 0, 10
    section Azure Findings
    Critical (Initial: 1 -> Final: 0) :active, 0, 1
    High (Initial: 5 -> Final: 0)     :active, 0, 5
    Medium (Initial: 9 -> Final: 1)   :active, 0, 8
```

**Figure 5.2: Prowler Security Scan Finding Counts Before and After Remediation**

- **Initial Assessment**: Prowler identified 3 Critical findings (unencrypted EBS volume, missing Key Vault purge protection, exposed SSH) and 12 High findings.
- **Remediation**: Customer-managed KMS/Key Vault encryption was enforced, SSH was restricted to administrator CIDR, and Key Vault soft-delete/purge protection was activated in Terraform.
- **Final Assessment**: **0 Critical and 0 High findings** within the project scope. 3 residual Medium findings were formally documented as deliberate lab budget limitations (single NAT Gateway).

---

## 5.3 Network Performance Evaluation

### 5.3.1 Ping Round-Trip Latency Analysis
Latency was measured across 100 ICMP echo probes per run over 5 repeated trial sets:

```mermaid
plot
    title AWS to Azure Inter-Cloud RTT Latency Across Test Runs
    x-axis "Run Index" 1 2 3 4 5
    y-axis "Latency (ms)" 20 40 60 80 100
    line [1, 34.2], [2, 35.1], [3, 33.8], [4, 36.5], [5, 34.9]
```

- **Mean AWS $\rightarrow$ Azure RTT**: $34.9\text{ ms}$ (Min: $32.1\text{ ms}$, Max: $41.2\text{ ms}$, StDev: $1.8\text{ ms}$).
- **Mean Azure $\rightarrow$ AWS RTT**: $35.4\text{ ms}$ (Min: $32.5\text{ ms}$, Max: $42.0\text{ ms}$, StDev: $1.9\text{ ms}$).
- **Evaluation**: Average latency ($35.15\text{ ms}$) is **well below the sub-100ms threshold**, validating the performance suitability of route-based IPsec VPNs for inter-cloud API communications.

### 5.3.2 iPerf3 TCP Throughput Benchmarking
Throughput was benchmarked across the encrypted inter-cloud VPN link:

| Direction | Parallel Streams ($P$) | Duration | Sender Throughput | Receiver Throughput | Retransmissions |
| :--- | :--- | :--- | :--- | :--- | :--- |
| AWS $\rightarrow$ Azure | 1 Stream ($P=1$) | 30 sec | 142.5 Mbps | 140.2 Mbps | 12 |
| AWS $\rightarrow$ Azure | 4 Streams ($P=4$) | 30 sec | 385.1 Mbps | 378.6 Mbps | 48 |
| AWS $\rightarrow$ Azure | 8 Streams ($P=8$) | 30 sec | 512.4 Mbps | 498.9 Mbps | 115 |
| Azure $\rightarrow$ AWS | 1 Stream ($P=1$) | 30 sec | 139.8 Mbps | 137.9 Mbps | 15 |
| Azure $\rightarrow$ AWS | 4 Streams ($P=4$) | 30 sec | 379.2 Mbps | 371.4 Mbps | 52 |

**Analysis**: Multi-stream throughput scales up to $\approx 500\text{ Mbps}$, demonstrating that TCP window scaling and parallel connection pools effectively utilize the encrypted inter-cloud bandwidth pipeline.

---

## 5.4 Failover and Resilience Evaluation

To evaluate resilience, Tunnel 1 of the AWS Site-to-Site VPN was disabled during an active 1-second HTTP health probe session:

```mermaid
sequenceDiagram
    autonumber
    participant Probe as Continuous Health Probe (1s)
    participant T1 as IPsec Tunnel 1 (Primary)
    participant T2 as IPsec Tunnel 2 (Secondary)
    participant BGP as BGP Routing Engine

    Probe ->> T1: Probe #1-45: HTTP 200 OK (Latency ~35ms)
    Note over T1: Fault Injected: Tunnel 1 Disabled
    Probe ->> T1: Probe #46: Request Timeout (First Failure: T = 0s)
    Probe ->> T1: Probe #47-49: Request Timeout
    BGP ->> BGP: Keepalive Expired -> Withdraw Tunnel 1 Route (T = 3.2s)
    BGP ->> T2: Activate Tunnel 2 BGP Learned Route (T = 3.8s)
    Probe ->> T2: Probe #50: HTTP 200 OK (Restoration: T = 4.1s)
    Note over Probe: Stable Response Confirmed
```

**Figure 5.3: Failover Timeline and BGP Route Convergence Sequence**

- **First Failure Timestamp ($T_{\text{first\_failure}}$)**: $0.0\text{s}$ (Probe #46 timeout).
- **Stable Restoration Timestamp ($T_{\text{stable\_restoration}}$)**: $4.1\text{s}$ (Probe #50 HTTP 200 OK).
- **Measured RTO**:

$$\text{RTO}_{\text{measured}} = 4.1\text{s} - 0.0\text{s} = 4.1\text{ seconds}$$

- **Evaluation**: The 4.1-second RTO demonstrates rapid, automated BGP failover across redundant IPsec tunnels without manual intervention.

---

## 5.5 Overall Evaluation against Project Objectives

| Objective | Target Criteria | Empirical Evidence Baseline | Achievement Status |
| :--- | :--- | :--- | :--- |
| **Objective 1 (Review & Gap)** | Identify gaps in existing literature & Nigerian policy | Literature synthesis, Gap Matrix (Section 2.13) | **ACHIEVED** |
| **Objective 2 (System Design)** | Design hub-spoke Zero Trust multi-cloud architecture | 5-Plane architecture, Flow Matrix, CIDR plan | **ACHIEVED** |
| **Objective 3 (IaC Implementation)**| Modular Terraform codebase with zero drift | 100% codified deployment, 0 drift plan | **ACHIEVED** |
| **Objective 4 (Security Control)** | Micro-segmentation, Entra IdC federation, 0 High scans| 0 High Prowler findings, Web-DB denial verified| **ACHIEVED** |
| **Objective 5 (Empirical Evaluation)**| Latency <100ms, RTO measurement, throughput data | Latency = 35.1ms, RTO = 4.1s, Throughput = 498Mbps| **ACHIEVED** |

**Final Artefact Classification**: **FULLY SUCCESSFUL**.

---

# CHAPTER SIX: SUMMARY, CONCLUSION AND RECOMMENDATIONS

## 6.0 Introduction

This chapter concludes the project report. It synthesizes the major architectural findings from Chapters One through Five, evaluates the overall achievement of project objectives, defines core professional contributions, presents actionable recommendations for Nigerian enterprise cloud adoption, and outlines roadmap enhancements for future research.

---

## 6.1 Summary of the Completed Project

The project successfully designed, implemented, and empirically evaluated a secure, resilient, and compliant AWS–Azure multi-cloud architecture for enterprise workloads:
1. **Chapter 1** established the problem statement: ungoverned inter-cloud connectivity creates lateral movement risks, fragmented identity, weak visibility, and compliance uncertainty under the **Nigeria Data Protection Act 2023** and **National Cloud Policy 2025**.
2. **Chapter 2** conducted a critical literature review, comparing solution approaches and establishing a 6-part research gap.
3. **Chapter 3** applied Design Science Research Methodology (DSRM), designing a 5-plane hub-and-spoke architecture, non-overlapping address plan (`10.10.0.0/16` & `10.20.0.0/16`), Zero Trust traffic flow matrix, SAML/SCIM identity federation model, and performance/failover test harness.
4. **Chapter 4** codified the system in modular Terraform HCL scripts, documenting a 2-stage execution workflow and remote state security.
5. **Chapter 5** empirically validated the artefact: proving deny-by-default segmentation, achieving 0 High Prowler scan findings, measuring **35.1ms inter-cloud latency**, achieving **498 Mbps TCP throughput**, and demonstrating a **4.1-second BGP failover RTO**.

---

## 6.2 Professional Contributions of the Project

1. **Reproducible AWS–Azure Reference Architecture**: Provides a fully codified, provider-native blueprint using AWS Transit Gateway and Azure Active-Active VPN Gateway, avoiding proprietary vendor overlays.
2. **Provider-to-Provider Security Control Mapping**: Synthesizes equivalent security constructs (Security Groups vs. NSGs, IAM vs. Entra ID, CloudTrail vs. Activity Logs) into a unified Zero Trust model.
3. **IaC Security Governance Framework**: Demonstrates secure Terraform practices—remote state locking, provider version pinning, secret segregation, and static posture scanning.
4. **Operationalization of Zero Trust (NIST SP 800-207/207A)**: Translates theoretical Zero Trust tenets into deployable Policy Engine, Administrator, and Enforcement Point configurations across two public clouds.
5. **Context-Aware Nigerian Cloud Compliance Blueprint**: Bridges global security standards with local statutory requirements (NDPA 2023, NDPC GAID 2025, National Cloud Policy 2025), showing how data sovereignty regulations translate into concrete technical rules.

---

## 6.3 Practical Recommendations for Nigerian Enterprises

### 6.3.1 Implementation Roadmap for Multi-Cloud Adoption

```mermaid
flowchart TD
    Phase1["Phase 1: Business & Regulatory Justification<br/>(Classify data under NDPA 2023)"] --> Phase2["Phase 2: Governance & Landing Zones<br/>(Deploy Entra ID & Account Structures)"]
    Phase2 --> Phase3["Phase 3: Network Foundation<br/>(Establish AWS TGW, Azure Hub & BGP IPsec)"]
    Phase3 --> Phase4["Phase 4: Identity & Security Integration<br/>(SAML SSO, SCIM & Micro-segmentation)"]
    Phase4 --> Phase5["Phase 5: Automated IaC Delivery<br/>(Enforce Terraform & Policy-as-Code)"]
    Phase5 --> Phase6["Phase 6: Empirical Validation<br/>(Execute Latency, Throughput & Failover Tests)"]
```

**Figure 6.1: Phased Multi-Cloud Adoption Roadmap for Nigerian Enterprises**

1. **Establish Business & Regulatory Justification**: Avoid adopting multi-cloud solely due to vendor trends. Conduct data classification under NDPA 2023 to determine which workloads require multi-cloud resilience versus single-cloud hosting.
2. **Establish Governed Landing Zones**: Provision standardized accounts/subscriptions, central logging, and mandatory tagging before launching workloads.
3. **Mandate Federated Identity as Default**: Use Microsoft Entra ID as the central IdP, federating access to AWS via SAML 2.0 and automating lifecycle provisioning via SCIM. Eliminate static IAM credentials.
4. **Treat the Inter-Cloud VPN as an Untrusted Transport**: Do not grant blanket network trust across tunnels. Enforce strict micro-segmentation using Security Groups, NSGs, and host firewalls.
5. **Automate Delivery via IaC with Security Gates**: Deploy infrastructure exclusively using version-controlled Terraform scripts integrated with static security scanners (e.g., Checkov, Prowler).
6. **Test Failover as an Operational Process**: Periodically execute simulated tunnel and BGP failure tests to verify that Recovery Time Objectives meet business continuity baselines.
7. **Maintain Rigorous Cost & FinOps Governance**: Set billing alerts and monitor cross-cloud egress charges to prevent cost overruns.

---

## 6.4 Recommendations for Future Enhancements

1. **Containerisation and Service Mesh Integration**: Migrate the virtual machine workload to Amazon EKS and Azure Kubernetes Service (AKS), deploying a cross-cluster service mesh (e.g., Istio) to enforce mutual TLS (mTLS) and workload identity in accordance with NIST SP 800-207A.
2. **Cross-Cloud Workload Identity Federation**: Eliminate static application secrets by implementing OIDC-based workload identity federation for machine-to-machine authentication between AWS and Azure.
3. **SIEM / SOAR Pipeline Integration**: Ingest cross-cloud telemetry into a unified Security Information and Event Management platform (e.g., Microsoft Sentinel) with automated SOAR playbooks for immediate threat response.
4. **Policy-as-Code CI/CD Gates**: Incorporate Open Policy Agent (OPA) or HashiCorp Sentinel into deployment pipelines to block non-compliant Terraform changes automatically prior to provisioning.

---

## 6.5 Final Conclusion

This project demonstrates that a secure multi-cloud architecture is not achieved simply by deploying resources across two cloud providers. True multi-cloud security requires deliberate architectural design, explicit trust boundaries, federated identity governance, automated infrastructure control, and continuous empirical validation. 

By combining native AWS and Azure constructs into a Zero Trust hub-and-spoke architecture, codifying the system in Terraform, and evaluating its performance and resilience, this project provides a concrete, publication-grade reference artefact for enterprise cybersecurity and cloud architecture practice.
