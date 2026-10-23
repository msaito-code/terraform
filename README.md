# 🛡️ Azure Cloud Security & IaC Portfolio

[![Azure](https://img.shields.io/badge/azure-%230072C6.svg?style=for-the-badge&logo=microsoftazure&logoColor=white)](https://azure.microsoft.com/en-us/)
[![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Security](https://img.shields.io/badge/Security-Architect-red?style=for-the-badge)]()

Welcome! My name is **Matheus Saito**, an **Azure Cloud Security Engineer & Architect**. 

Terraform Up & Running on Azure
This repository is a hands-on Infrastructure as Code (IaC) project in which I recreate and adapt the infrastructure examples from Terraform: Up & Running, 3rd Edition for Microsoft Azure.

The book primarily demonstrates Terraform concepts using ***Amazon Web Services (AWS)***. Rather than simply reproducing the examples, I translated their underlying architectural concepts to Azure and modified the implementations where the two cloud platforms differ.

The goal of this repository is to demonstrate practical experience with Terraform, Azure infrastructure, remote state management, modular infrastructure, networking, security, and CI/CD, while documenting the architectural decisions and trade-offs involved in adapting infrastructure patterns between cloud providers.

Note: This is a learning and portfolio project. The infrastructure is designed to demonstrate production-oriented Terraform and Azure practices, but it should not be considered a production-ready reference architecture without additional requirements, security controls, monitoring, governance, and environment-specific validation.

🎯 Project Objectives
This project focuses on applying Terraform concepts to real Azure infrastructure, including:

Infrastructure provisioning using Terraform and HCL
Reusable Terraform modules
Separation of infrastructure components and state
Remote Terraform state using Azure Storage
Resource dependencies through Terraform outputs and terraform_remote_state
Azure networking and network security
Load balancing and highly available infrastructure patterns
Identity and access management
Infrastructure automation through CI/CD
Secure handling of credentials and sensitive configuration
Where the AWS and Azure implementations differ, I adapt the architecture rather than attempting a direct resource-for-resource translation.

🏗️ Architecture
The repository progressively builds Azure infrastructure while following the concepts introduced throughout Terraform: Up & Running, 3rd Edition.

Examples may include Azure resources and services such as:

Azure Resource Groups
Virtual Networks and Subnets
Network Security Groups
Azure Load Balancer
Virtual Machines / Virtual Machine Scale Sets
Azure Storage Accounts
Azure Blob Storage for Terraform remote state
Microsoft Entra ID
Azure RBAC
The implementations evolve as new Terraform concepts are introduced in the book.

🔄 Translating AWS Concepts to Azure
One of the main goals of this project is understanding the architectural concept behind each implementation rather than simply translating Terraform resource names.

For example:

Concept	AWS	Azure
Virtual network	VPC	Virtual Network (VNet)
Network segmentation	Subnet	Subnet
Traffic filtering	Security Group	Network Security Group (NSG)
Layer 4 load balancing	Network Load Balancer	Azure Load Balancer
Object storage	Amazon S3	Azure Blob Storage
Terraform remote state	S3	Azure Storage Account / Blob Container
Identity and permissions	AWS IAM	Microsoft Entra ID / Azure RBAC
This makes the repository an exercise not only in Terraform, but also in translating cloud architecture patterns between providers.

🔐 Terraform State & Security
Terraform state can contain infrastructure metadata and potentially sensitive information, so state management is treated as an important part of the architecture.

The project uses Azure Blob Storage as a remote Terraform backend, allowing state to be stored separately from the source code and shared between Terraform configurations where required.

Security considerations include:

Keeping Terraform state outside the Git repository
Avoiding hard-coded credentials
Using environment variables or workload identities where appropriate
Applying Azure RBAC to infrastructure resources
Restricting network access where applicable
Keeping provider and Terraform configuration versioned
📁 Repository Structure
.
├── 00-bootstrap/
│   └── ...
├── modules/
│   └── ...
├── environments/
│   └── ...
└── README.md

---

## 📫 Let's Connect

I am currently open to remote opportunities as a Cloud Security Engineer, DevSecOps Engineer, or Azure Architect. 

*   **LinkedIn:** https://www.linkedin.com/in/matheus-luiz-saito-soares-b7ab80236
*   **Email:** matheus.saito0201@gmail.com
