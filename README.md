# 🛡️ Azure Cloud Security & IaC Portfolio

[![Azure](https://img.shields.io/badge/azure-%230072C6.svg?style=for-the-badge&logo=microsoftazure&logoColor=white)](https://azure.microsoft.com/en-us/)
[![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Security](https://img.shields.io/badge/Security-Architect-red?style=for-the-badge)]()

Welcome! My name is **Matheus Saito**, an **Azure Cloud Security Engineer & Architect**. 

This repository serves as a centralized portfolio showcasing my ability to design, deploy, and secure enterprise-grade Azure environments using **Terraform (Infrastructure as Code)**. 

To make it easy for recruiters and hiring managers to review my work without jumping between multiple links, I have consolidated my key project demos into this single repository. Each subfolder represents an isolated, production-ready scenario with its own detailed documentation.

---

## 🏆 Certifications & Competencies

I hold several advanced Microsoft certifications that validate my expertise in cloud architecture, network engineering, and cybersecurity:

*   **SC-100:** [Microsoft Cybersecurity Architect Expert](https://learn.microsoft.com/api/credentials/share/en-us/MatheusLuizSaitoSoaresProdutivit-1442/844CFB8BF43D56AC?sharingId=AA351E191EB9C826)
*   **AZ-305:** [Azure Solutions Architect Expert](https://learn.microsoft.com/api/credentials/share/en-us/MatheusLuizSaitoSoaresProdutivit-1442/746029FACFAAC01F?sharingId=AA351E191EB9C826)
*   **AZ-700:** [Azure Network Engineer Associate](https://learn.microsoft.com/api/credentials/share/en-us/MatheusLuizSaitoSoaresProdutivit-1442/8B524359138DD108?sharingId=AA351E191EB9C826)
*   **SC-200:** [Microsoft Security Operations Analyst](https://learn.microsoft.com/api/credentials/share/en-us/MatheusLuizSaitoSoaresProdutivit-1442/30BDE4437B437812?sharingId=AA351E191EB9C826)

**Core Technical Competencies:**
*   **Infrastructure as Code (IaC):** Terraform (HCL), Azure Bicep, ARM Templates, State Management, CI/CD Pipelines (GitHub Actions/Azure DevOps).
*   **Cloud Architecture:** Hub & Spoke topologies, High Availability (HA), Disaster Recovery (DR), Well-Architected Framework.
*   **Network Security:** Azure Firewall, Application Gateway (WAF), Network Security Groups (NSGs), Private Link/Endpoints, ExpressRoute.
*   **Identity & Threat Protection:** Microsoft Entra ID (formerly Azure AD), RBAC, Microsoft Defender for Cloud, Microsoft Sentinel.

---

## 📂 Project Directory (Portfolio Demos)

Below is an index of the technical demonstrations available in this repository. Click on any project to view its specific `README.md`, architectural diagrams, and Terraform source code.

| Project Name | Description | Technologies Highlighted |
| :--- | :--- | :--- |
| [**1. Secure Hub & Spoke Architecture**](./01-secure-hub-spoke) | Deployment of a scalable Hub & Spoke network topology with centralized firewall routing and inspection. | `Terraform`, `Azure Firewall`, `VNet Peering`, `UDRs` |
| [**2. Private AKS Cluster Deployment**](./02-private-aks) | Securing Azure Kubernetes Service with a Hub-and-Spoke network topology, private cluster configuration, centralized Azure Firewall egress inspection, and Managed Identity RBAC for Private DNS zone management. | `Terraform`, `AKS`, `RBAC` |
| [**3. Defender for Cloud & Sentinel Setup**](./03-defender-sentinel) | *[Future Deployment]* Automated deployment of Log Analytics Workspaces, Sentinel enablement, and Defender coverage. | `Terraform`, `Sentinel`, `Defender for Cloud` |
| [**4. Secure Web App with WAF**](./04-secure-webapp) | *[Future Deployment]* Deploying an App Service behind an Application Gateway with Web Application Firewall enabled. | `Terraform`, `App Gateway`, `App Service` |
| [**5. Policy Management with Policy Initiatives**](./05-policy-management) | Defining policies for audit and restrict purposes. | `Terraform`, `Azure Policy`, `Policy Initiatives` |

*(Note to Reviewer: Each subfolder contains instructions on how to initialize, plan, and apply the Terraform configurations, along with the required prerequisites).*

---

## 💡 Why This Approach?

In real-world enterprise environments, security must be "shift-left" and embedded directly into the deployment pipelines. By utilizing Terraform, I ensure that every environment is:
1.  **Immutable & Reproducible:** Eliminating configuration drift.
2.  **Secure by Default:** Adhering to Zero Trust principles from the first line of code.
3.  **Auditable:** All infrastructure changes are version-controlled and peer-reviewed.

---

## 📫 Let's Connect

I am currently open to remote opportunities as a Cloud Security Engineer, DevSecOps Engineer, or Azure Architect. 

*   **LinkedIn:** https://www.linkedin.com/in/matheus-luiz-saito-soares-b7ab80236
*   **Email:** matheus.saito0201@gmail.com
