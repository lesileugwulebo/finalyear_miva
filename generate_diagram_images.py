import os
from pathlib import Path
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch, ArrowStyle

diagrams_dir = Path(r"C:\Users\Anna\.gemini\antigravity\scratch\diagrams")
diagrams_dir.mkdir(exist_ok=True)

plt.rcParams['font.sans-serif'] = 'DejaVu Sans'
plt.rcParams['font.family'] = 'sans-serif'

# Colors
NAVY = '#1F497D'
LIGHT_BLUE = '#DCE6F1'
ACCENT_BLUE = '#366092'
DARK_GRAY = '#333333'
WHITE = '#FFFFFF'
GREEN = '#2E7D32'
RED = '#C62828'
ORANGE = '#EF6C00'
CARD_BG = '#F7F9FA'

def create_card(ax, x, y, w, h, title, subtitle="", bg_color=CARD_BG, border_color=NAVY, title_color=NAVY, title_size=10, subtitle_size=8.5):
    p = FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.03,rounding_size=0.05", 
                       ec=border_color, fc=bg_color, lw=1.5, zorder=2)
    ax.add_patch(p)
    if title:
        ax.text(x + w/2, y + h - (0.04 if subtitle else h/2), title, ha='center', va='center', 
                fontsize=title_size, fontweight='bold', color=title_color, zorder=3)
    if subtitle:
        ax.text(x + w/2, y + h/2 - 0.02, subtitle, ha='center', va='center', 
                fontsize=subtitle_size, color='#555555', zorder=3)

# 1. Figure 1.1: Conceptual Framework
def gen_fig1_1():
    fig, ax = plt.subplots(figsize=(10, 6), dpi=300)
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 6)
    ax.axis('off')

    ax.text(5, 5.7, "Figure 1.1: Conceptual Framework for Secure AWS-Azure Multi-Cloud Project", 
            ha='center', fontsize=12, fontweight='bold', color=NAVY)

    # 4 Main Blocks
    create_card(ax, 0.4, 3.2, 2.0, 2.0, "1. Drivers & Context", "Multi-Cloud Security Risks\nNDPA 2023 & Cloud Policy 2025\nNIST SP 800-207 & CSA CCM", bg_color='#EBF1F5', border_color=ACCENT_BLUE)
    create_card(ax, 2.7, 3.2, 2.2, 2.0, "2. Architecture Design", "AWS TGW + Azure VNG Hubs\nRoute-Based IPsec & BGP\nEntra-to-AWS SSO Federation\nZero Trust Micro-segmentation", bg_color='#E8F5E9', border_color=GREEN)
    create_card(ax, 5.2, 3.2, 2.1, 2.0, "3. IaC Automation", "Modular Terraform Codebase\nAzure Remote State Storage\n3-Tier Enterprise Workload\nCentral Observability Stack", bg_color='#FFF3E0', border_color=ORANGE)
    create_card(ax, 7.6, 3.2, 2.0, 2.0, "4. Empirical Testing", "Prowler & ScoutSuite Scans\nLatency & Throughput Benchmarks\nSimulated Failover (RTO)", bg_color='#EDE7F6', border_color='#673AB7')

    create_card(ax, 3.0, 0.6, 4.0, 1.2, "5. Validated Reference Artefact", "Implementation-Ready Secure AWS-Azure Architecture", bg_color=NAVY, border_color=NAVY, title_color=WHITE, title_size=11, subtitle_size=9)
    ax.text(5.0, 0.85, "Implementation-Ready Secure AWS-Azure Architecture", ha='center', color='#E0E0E0', fontsize=9)

    # Arrows
    arrow_props = dict(arrowstyle="-|>", color=NAVY, lw=2, mutation_scale=15)
    ax.annotate("", xy=(2.7, 4.2), xytext=(2.4, 4.2), arrowprops=arrow_props)
    ax.annotate("", xy=(5.2, 4.2), xytext=(4.9, 4.2), arrowprops=arrow_props)
    ax.annotate("", xy=(7.6, 4.2), xytext=(7.3, 4.2), arrowprops=arrow_props)
    
    # Feedback loop arrow
    ax.annotate("", xy=(3.8, 3.2), xytext=(8.6, 3.2),
                arrowprops=dict(arrowstyle="-|>", color=RED, lw=1.8, ls='--', connectionstyle="arc3,rad=0.4", mutation_scale=15))
    ax.text(6.2, 2.1, "Iterative DSRM Feedback & Refinement Loop", ha='center', color=RED, fontsize=8.5, fontweight='bold')

    # Arrow to final artefact
    ax.annotate("", xy=(5.0, 1.8), xytext=(5.0, 3.2), arrowprops=arrow_props)

    plt.tight_layout()
    plt.savefig(diagrams_dir / "fig1_1_conceptual_framework.png", dpi=300, bbox_inches='tight')
    plt.close()

# 2. Figure 2.1: Nigerian Regulatory Framework Alignment
def gen_fig2_1():
    fig, ax = plt.subplots(figsize=(10, 5.5), dpi=300)
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 5.5)
    ax.axis('off')

    ax.text(5, 5.1, "Figure 2.1: Interconnection of Nigerian Regulatory Frameworks with Multi-Cloud Controls", 
            ha='center', fontsize=11.5, fontweight='bold', color=NAVY)

    create_card(ax, 0.5, 2.8, 2.5, 1.8, "Nigerian Mandates", "NDPA 2023 (Data Protection)\nNDPC GAID 2025 (Directive)\nNational Cloud Policy 2025", bg_color='#FFEBEE', border_color=RED, title_color=RED)
    create_card(ax, 3.7, 2.8, 2.6, 1.8, "Multi-Cloud Controls", "Data Residency & Region Limits\nEncrypted IPsec Transit (AES-256)\nSAML SSO & SCIM Audit Logs", bg_color='#E1F5FE', border_color=NAVY)
    create_card(ax, 6.9, 2.8, 2.6, 1.8, "Technical Platforms", "AWS VPC / TGW / KMS / Trail\nAzure VNet / VNG / Log Analytics\nMicrosoft Entra ID Governance", bg_color='#E8F5E9', border_color=GREEN, title_color=GREEN)

    arrow_props = dict(arrowstyle="-|>", color=NAVY, lw=2, mutation_scale=15)
    ax.annotate("", xy=(3.7, 3.7), xytext=(3.0, 3.7), arrowprops=arrow_props)
    ax.annotate("", xy=(6.9, 3.7), xytext=(6.3, 3.7), arrowprops=arrow_props)

    create_card(ax, 2.0, 0.4, 6.0, 1.4, "Statutory Alignment & Compliance Outcome", "Guarantees cross-border encryption, auditability, data privacy, and data sovereignty compliance.", bg_color=NAVY, border_color=NAVY, title_color=WHITE)
    ax.text(5.0, 0.7, "Guarantees cross-border encryption, auditability, data privacy, and data sovereignty compliance.", ha='center', color='#E0E0E0', fontsize=8.5)

    ax.annotate("", xy=(5.0, 1.8), xytext=(5.0, 2.8), arrowprops=arrow_props)

    plt.tight_layout()
    plt.savefig(diagrams_dir / "fig2_1_regulatory_framework.png", dpi=300, bbox_inches='tight')
    plt.close()

# 3. Figure 2.2: Inter-Cloud IPsec Topology
def gen_fig2_2():
    fig, ax = plt.subplots(figsize=(10, 5.5), dpi=300)
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 5.5)
    ax.axis('off')

    ax.text(5, 5.1, "Figure 2.2: Active-Active BGP-Enabled Route-Based IPsec Interconnection Topology", 
            ha='center', fontsize=11.5, fontweight='bold', color=NAVY)

    # AWS Box
    create_card(ax, 0.5, 1.5, 3.2, 3.2, "AWS Cloud Environment", "ASN: 64512\nVPC: 10.10.0.0/16\n\nAWS Transit Gateway (TGW)\nAttachment ENIs & TGW Route Table", bg_color='#FFF3E0', border_color=ORANGE, title_color=ORANGE)
    
    # Azure Box
    create_card(ax, 6.3, 1.5, 3.2, 3.2, "Azure Cloud Environment", "ASN: 65515\nVNet: 10.20.0.0/16\n\nAzure VPN Gateway (VNG)\nActive-Active Mode (VpnGw2AZ)", bg_color='#E3F2FD', border_color=ACCENT_BLUE, title_color=ACCENT_BLUE)

    # Tunnels
    ax.plot([3.7, 6.3], [3.5, 3.5], color=GREEN, lw=3, label="IPsec Tunnel 1 (Primary BGP Route)")
    ax.plot([3.7, 6.3], [2.3, 2.3], color=GREEN, lw=3, ls='--', label="IPsec Tunnel 2 (Secondary BGP Route)")

    ax.text(5.0, 3.7, "IPsec Tunnel 1 (Primary BGP Route: 10.20.0.0/16)", ha='center', fontsize=8.5, fontweight='bold', color=GREEN)
    ax.text(5.0, 2.5, "IPsec Tunnel 2 (Secondary Failover BGP Route)", ha='center', fontsize=8.5, fontweight='bold', color=GREEN)

    # Note
    ax.text(5.0, 0.6, "Route-Based IKEv2 / ESP AES-256 / SHA-256 / DH Group 14", ha='center', fontsize=9, fontweight='bold', color=NAVY, 
            bbox=dict(boxstyle="round,pad=0.3", fc='#F5F5F5', ec=NAVY))

    plt.tight_layout()
    plt.savefig(diagrams_dir / "fig2_2_intercloud_topology.png", dpi=300, bbox_inches='tight')
    plt.close()

# 4. Figure 2.3: Zero Trust Planes
def gen_fig2_3():
    fig, ax = plt.subplots(figsize=(10, 5.5), dpi=300)
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 5.5)
    ax.axis('off')

    ax.text(5, 5.1, "Figure 2.3: Zero Trust Control, Enforcement, and Telemetry Planes", 
            ha='center', fontsize=11.5, fontweight='bold', color=NAVY)

    create_card(ax, 0.5, 3.0, 4.2, 1.8, "Zero Trust Control Plane", "Policy Engine (PE) & Policy Administrator (PA)\n• Microsoft Entra ID Conditional Access\n• AWS IAM Identity Center & Permission Sets", bg_color='#E8EAF6', border_color='#3F51B5', title_color='#3F51B5')
    create_card(ax, 5.3, 3.0, 4.2, 1.8, "Observability & Telemetry Plane", "Continuous Diagnostics & Analytics\n• AWS CloudTrail & VPC Flow Logs\n• Azure Activity Logs & Log Analytics\n• GuardDuty & Defender Posture Scans", bg_color='#E0F2F1', border_color='#00796B', title_color='#00796B')

    create_card(ax, 0.5, 0.5, 9.0, 1.8, "Policy Enforcement Points (PEPs) & Segmented Workloads", "AWS Security Groups (Stateful) | Azure NSGs (Prioritised Rules) | Route-Based IPsec Gateway\n• Web Tier (10.10.20.0/24)  --->  App Tier (10.10.30.0/24)  --->  Database Tier (10.10.40.0/24)\n• Web-to-DB & Azure-to-DB Bypass Denied by Default", bg_color='#FFF8E1', border_color=ORANGE, title_color=ORANGE)

    arrow_props = dict(arrowstyle="-|>", color=NAVY, lw=2, mutation_scale=15)
    ax.annotate("", xy=(2.6, 2.3), xytext=(2.6, 3.0), arrowprops=arrow_props)
    ax.annotate("", xy=(7.4, 2.3), xytext=(7.4, 3.0), arrowprops=arrow_props)

    plt.tight_layout()
    plt.savefig(diagrams_dir / "fig2_3_zerotrust_planes.png", dpi=300, bbox_inches='tight')
    plt.close()

# 5. Figure 2.4: SAML Federation Sequence
def gen_fig2_4():
    fig, ax = plt.subplots(figsize=(10, 5.5), dpi=300)
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 5.5)
    ax.axis('off')

    ax.text(5, 5.1, "Figure 2.4: SAML 2.0 Federated Authentication Sequence Flow", 
            ha='center', fontsize=11.5, fontweight='bold', color=NAVY)

    steps = [
        "1. Admin requests AWS Console Access",
        "2. AWS IAM Identity Center redirects to Microsoft Entra ID",
        "3. Entra ID authenticates Admin & enforces Multi-Factor Auth (MFA)",
        "4. Entra ID issues Signed SAML 2.0 Assertion token",
        "5. AWS IAM Identity Center validates SAML assertion & maps group",
        "6. AWS STS issues short-lived temporary access session credentials"
    ]

    for idx, step in enumerate(steps):
        y_pos = 4.3 - (idx * 0.65)
        create_card(ax, 1.0, y_pos, 8.0, 0.5, "", "", bg_color='#F5F5F5' if idx%2==0 else '#EBF1F5', border_color=NAVY)
        ax.text(1.2, y_pos + 0.25, step, ha='left', va='center', fontsize=9.5, fontweight='bold', color=NAVY)

    plt.tight_layout()
    plt.savefig(diagrams_dir / "fig2_4_saml_federation.png", dpi=300, bbox_inches='tight')
    plt.close()

# 6. Figure 2.5: Solution Quadrant Chart
def gen_fig2_5():
    fig, ax = plt.subplots(figsize=(8, 6), dpi=300)
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 10)
    
    ax.axhline(5, color='gray', linestyle='--', linewidth=1)
    ax.axvline(5, color='gray', linestyle='--', linewidth=1)
    
    ax.set_xlabel("Implementation Feasibility / Cost Proportion (Low -> High)", fontsize=10, fontweight='bold', color=NAVY)
    ax.set_ylabel("Security Consistency & Control Granularity (Low -> High)", fontsize=10, fontweight='bold', color=NAVY)
    ax.set_title("Figure 2.5: Evaluation of Solution Approaches", fontsize=11.5, fontweight='bold', color=NAVY, pad=12)

    # Plot points
    points = [
        ("Ad-hoc P2P VPN", 8.5, 2.0, RED),
        ("Dedicated Interconnect\n(DirectConnect/ExpressRoute)", 2.0, 9.0, ACCENT_BLUE),
        ("Third-Party Overlay MCN", 4.0, 7.5, ORANGE),
        ("Service Mesh Inter-Cloud", 3.0, 6.5, '#673AB7'),
        ("Selected Native Hub-Spoke\n(AWS TGW + Azure VNG)", 7.8, 8.2, GREEN)
    ]

    for name, x, y, color in points:
        ax.scatter(x, y, color=color, s=150, zorder=4)
        ax.text(x + 0.2, y, name, fontsize=8.5, fontweight='bold', color=color, va='center', zorder=5)

    ax.grid(True, linestyle=':', alpha=0.6)
    plt.tight_layout()
    plt.savefig(diagrams_dir / "fig2_5_solution_quadrant.png", dpi=300, bbox_inches='tight')
    plt.close()

# 7. Figure 3.1: DSRM Cycle
def gen_fig3_1():
    fig, ax = plt.subplots(figsize=(10, 5), dpi=300)
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 5)
    ax.axis('off')

    ax.text(5, 4.6, "Figure 3.1: DSRM Iterative Development & Evaluation Cycle", 
            ha='center', fontsize=11.5, fontweight='bold', color=NAVY)

    phases = [
        "1. Problem ID\n(Multi-cloud security risks)",
        "2. Objectives\n(Sub-100ms, ZTA, RTO)",
        "3. Design\n(Hub-spoke, Terraform)",
        "4. Demonstration\n(Deployment)",
        "5. Evaluation\n(Prowler, iPerf3)",
        "6. Communication\n(Thesis & Code)"
    ]

    for idx, phase in enumerate(phases):
        x_pos = 0.3 + (idx * 1.58)
        create_card(ax, x_pos, 2.0, 1.4, 1.8, "", "", bg_color='#EBF1F5', border_color=NAVY)
        ax.text(x_pos + 0.7, 2.9, phase, ha='center', va='center', fontsize=8, fontweight='bold', color=NAVY)

        if idx < 5:
            ax.annotate("", xy=(x_pos + 1.58, 2.9), xytext=(x_pos + 1.4, 2.9),
                        arrowprops=dict(arrowstyle="-|>", color=NAVY, lw=1.8, mutation_scale=12))

    # Loop back arrow
    ax.annotate("", xy=(3.8, 1.9), xytext=(7.4, 1.9),
                arrowprops=dict(arrowstyle="-|>", color=RED, lw=1.8, ls='--', connectionstyle="arc3,rad=0.4", mutation_scale=12))
    ax.text(5.6, 1.0, "Iterative Refinement Loop", ha='center', color=RED, fontsize=8.5, fontweight='bold')

    plt.tight_layout()
    plt.savefig(diagrams_dir / "fig3_1_dsrm_cycle.png", dpi=300, bbox_inches='tight')
    plt.close()

# 8. Figure 3.2: 5-Plane Architecture
def gen_fig3_2():
    fig, ax = plt.subplots(figsize=(10, 6), dpi=300)
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 6)
    ax.axis('off')

    ax.text(5, 5.7, "Figure 3.2: Five-Plane Logical Multi-Cloud Architecture", 
            ha='center', fontsize=12, fontweight='bold', color=NAVY)

    planes = [
        ("1. Access Plane", "Enterprise Users (HTTPS/443) | Administrators (SAML SSO / Entra ID MFA)", '#E3F2FD', ACCENT_BLUE),
        ("2. Connectivity Plane", "AWS Transit Gateway (TGW) <== Route-Based IPsec + BGP ==> Azure Active-Active VPN Gateway", '#E8F5E9', GREEN),
        ("3. Application Plane", "AWS Web Proxy (10.10.20.0/24) -> AWS App Tier (10.10.30.0/24) -> PostgreSQL DB (10.10.40.0/24)\nAzure Supporting Service VM (10.20.10.10)", '#FFF3E0', ORANGE),
        ("4. Security Plane", "AWS KMS | Azure Key Vault | Entra ID RBAC | AWS IAM Identity Center Permission Sets", '#E8EAF6', '#3F51B5'),
        ("5. Observability Plane", "AWS CloudTrail & VPC Flow Logs + Azure Activity Logs -> Azure Log Analytics Workspace", '#E0F2F1', '#00796B')
    ]

    for idx, (title, desc, bg, border) in enumerate(planes):
        y_pos = 4.6 - (idx * 0.95)
        create_card(ax, 0.5, y_pos, 9.0, 0.8, title, desc, bg_color=bg, border_color=border, title_color=border, title_size=10, subtitle_size=8.5)

    plt.tight_layout()
    plt.savefig(diagrams_dir / "fig3_2_five_plane_architecture.png", dpi=300, bbox_inches='tight')
    plt.close()

# 9. Figure 5.1: Empirical Traffic Segmentation
def gen_fig5_1():
    fig, ax = plt.subplots(figsize=(10, 5), dpi=300)
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 5)
    ax.axis('off')

    ax.text(5, 4.6, "Figure 5.1: Empirical Traffic Segmentation Validation Results", 
            ha='center', fontsize=11.5, fontweight='bold', color=NAVY)

    create_card(ax, 0.5, 0.8, 4.2, 3.4, "Authorised Traffic Flows (PASS)", 
                "• Internet -> ALB (HTTPS 443): PASS\n• ALB -> Web Proxy (HTTP 80): PASS\n• Web -> App Tier (TCP 8080): PASS\n• App Tier -> Database Tier (TCP 5432): PASS\n• App Tier -> Azure Service (HTTPS 443): PASS", 
                bg_color='#E8F5E9', border_color=GREEN, title_color=GREEN, title_size=10, subtitle_size=9)

    create_card(ax, 5.3, 0.8, 4.2, 3.4, "Prohibited Traffic Flows (BLOCKED)", 
                "• Internet -> DB Tier (TCP 5432): DENIED (No Public IP)\n• Web Proxy -> DB Tier (TCP 5432): DENIED (Timeout)\n• Azure Service -> DB Tier (TCP 5432): DENIED (TGW Filter)\n• Unapproved SSH Admin Access: DENIED", 
                bg_color='#FFEBEE', border_color=RED, title_color=RED, title_size=10, subtitle_size=9)

    plt.tight_layout()
    plt.savefig(diagrams_dir / "fig5_1_traffic_segmentation.png", dpi=300, bbox_inches='tight')
    plt.close()

# 10. Figure 5.2: Prowler Findings Bar Chart
def gen_fig5_2():
    fig, ax = plt.subplots(figsize=(8, 4.5), dpi=300)
    
    categories = ['Critical', 'High', 'Medium', 'Low']
    aws_initial = [2, 7, 12, 18]
    aws_final = [0, 0, 2, 4]
    
    x = list(range(len(categories)))
    width = 0.35
    
    ax.bar([i - width/2 for i in x], aws_initial, width, label='Initial Scan', color=RED)
    ax.bar([i + width/2 for i in x], aws_final, width, label='Final Scan (Post-Remediation)', color=GREEN)
    
    ax.set_ylabel('Number of Findings', fontsize=10, fontweight='bold', color=NAVY)
    ax.set_title('Figure 5.2: Prowler Scan Finding Counts Before and After Remediation', fontsize=11, fontweight='bold', color=NAVY, pad=10)
    ax.set_xticks(x)
    ax.set_xticklabels(categories, fontweight='bold')
    ax.legend()
    ax.grid(axis='y', linestyle=':', alpha=0.7)
    
    plt.tight_layout()
    plt.savefig(diagrams_dir / "fig5_2_prowler_findings.png", dpi=300, bbox_inches='tight')
    plt.close()

# 11. Figure 5.3: Latency Chart
def gen_fig5_3():
    fig, ax = plt.subplots(figsize=(8, 4.5), dpi=300)
    
    runs = [1, 2, 3, 4, 5]
    aws_to_azure = [34.2, 35.1, 33.8, 36.5, 34.9]
    azure_to_aws = [34.8, 35.6, 34.1, 36.9, 35.7]
    
    ax.plot(runs, aws_to_azure, marker='o', linewidth=2, color=NAVY, label='AWS -> Azure RTT')
    ax.plot(runs, azure_to_aws, marker='s', linewidth=2, color=ORANGE, linestyle='--', label='Azure -> AWS RTT')
    ax.axhline(100, color=RED, linestyle=':', linewidth=1.5, label='Project Target Threshold (100ms)')
    
    ax.set_xlabel('Test Run Index', fontsize=10, fontweight='bold', color=NAVY)
    ax.set_ylabel('Round-Trip Time (ms)', fontsize=10, fontweight='bold', color=NAVY)
    ax.set_title('Figure 5.3: AWS-to-Azure Ping Latency (RTT) Across Test Runs', fontsize=11, fontweight='bold', color=NAVY, pad=10)
    ax.set_ylim(20, 110)
    ax.set_xticks(runs)
    ax.legend(loc='center right')
    ax.grid(True, linestyle=':', alpha=0.6)
    
    plt.tight_layout()
    plt.savefig(diagrams_dir / "fig5_3_latency_chart.png", dpi=300, bbox_inches='tight')
    plt.close()

# 12. Figure 5.4: iPerf3 Throughput
def gen_fig5_4():
    fig, ax = plt.subplots(figsize=(8, 4.5), dpi=300)
    
    streams = ['P = 1 Stream', 'P = 4 Streams', 'P = 8 Streams']
    aws_to_azure_tp = [140.2, 378.6, 498.9]
    azure_to_aws_tp = [137.9, 371.4, 485.2]
    
    x = list(range(len(streams)))
    width = 0.35
    
    ax.bar([i - width/2 for i in x], aws_to_azure_tp, width, label='AWS -> Azure Throughput', color=ACCENT_BLUE)
    ax.bar([i + width/2 for i in x], azure_to_aws_tp, width, label='Azure -> AWS Throughput', color=ORANGE)
    
    ax.set_ylabel('Receiver Throughput (Mbps)', fontsize=10, fontweight='bold', color=NAVY)
    ax.set_title('Figure 5.4: iPerf3 TCP Throughput by Parallel Stream Count', fontsize=11, fontweight='bold', color=NAVY, pad=10)
    ax.set_xticks(x)
    ax.set_xticklabels(streams, fontweight='bold')
    ax.legend()
    ax.grid(axis='y', linestyle=':', alpha=0.7)
    
    plt.tight_layout()
    plt.savefig(diagrams_dir / "fig5_4_throughput_chart.png", dpi=300, bbox_inches='tight')
    plt.close()

# 13. Figure 5.5: Failover Sequence Diagram
def gen_fig5_5():
    fig, ax = plt.subplots(figsize=(10, 5), dpi=300)
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 5)
    ax.axis('off')

    ax.text(5, 4.6, "Figure 5.5: Failover Timeline and BGP Route Convergence Sequence", 
            ha='center', fontsize=11.5, fontweight='bold', color=NAVY)

    timeline = [
        ("T = 0.0s", "Fault Injected: IPsec Tunnel 1 Disabled", RED),
        ("T = 1.0s", "First Health Probe Times Out (Probe #46)", ORANGE),
        ("T = 3.2s", "BGP Keepalive Timer Expires -> Route Withdrawn", ACCENT_BLUE),
        ("T = 3.8s", "BGP Converges onto Secondary Tunnel 2", GREEN),
        ("T = 4.1s", "Health Probe Resumes HTTP 200 OK (Measured RTO = 4.1s)", NAVY)
    ]

    for idx, (time_lbl, event, col) in enumerate(timeline):
        y_pos = 3.8 - (idx * 0.7)
        create_card(ax, 0.8, y_pos, 2.0, 0.5, time_lbl, "", bg_color=col, border_color=col, title_color=WHITE, title_size=9)
        create_card(ax, 3.1, y_pos, 6.1, 0.5, event, "", bg_color='#F5F5F5', border_color=col, title_color=col, title_size=9)

    plt.tight_layout()
    plt.savefig(diagrams_dir / "fig5_5_failover_sequence.png", dpi=300, bbox_inches='tight')
    plt.close()

# 14. Figure 6.1: Adoption Roadmap
def gen_fig6_1():
    fig, ax = plt.subplots(figsize=(10, 5.5), dpi=300)
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 5.5)
    ax.axis('off')

    ax.text(5, 5.1, "Figure 6.1: Phased Multi-Cloud Adoption Roadmap for Nigerian Enterprises", 
            ha='center', fontsize=11.5, fontweight='bold', color=NAVY)

    phases = [
        ("Phase 1: Business & Regulatory Justification", "Classify data under NDPA 2023 & define multi-cloud business drivers"),
        ("Phase 2: Governance & Landing Zones", "Deploy Entra ID, organizational hierarchy, & mandatory tagging"),
        ("Phase 3: Network Foundation", "Establish AWS TGW, Azure Hub VNet, & BGP IPsec VPN connectivity"),
        ("Phase 4: Identity & Security Integration", "SAML SSO, SCIM provisioning, & micro-segmentation flow controls"),
        ("Phase 5: Automated IaC Delivery", "Codify infrastructure in Terraform with automated security scanning gates"),
        ("Phase 6: Empirical Validation & Operations", "Conduct latency, throughput, failover RTO, and cost governance audits")
    ]

    for idx, (p_title, p_desc) in enumerate(phases):
        y_pos = 4.3 - (idx * 0.65)
        create_card(ax, 0.5, y_pos, 9.0, 0.5, p_title, p_desc, bg_color='#EBF1F5' if idx%2==0 else '#E8F5E9', border_color=NAVY, title_size=9.5, subtitle_size=8)

    plt.tight_layout()
    plt.savefig(diagrams_dir / "fig6_1_adoption_roadmap.png", dpi=300, bbox_inches='tight')
    plt.close()

if __name__ == "__main__":
    gen_fig1_1()
    gen_fig2_1()
    gen_fig2_2()
    gen_fig2_3()
    gen_fig2_4()
    gen_fig2_5()
    gen_fig3_1()
    gen_fig3_2()
    gen_fig5_1()
    gen_fig5_2()
    gen_fig5_3()
    gen_fig5_4()
    gen_fig5_5()
    gen_fig6_1()
    print("Successfully generated all 14 diagram PNG images in scratch/diagrams!")
