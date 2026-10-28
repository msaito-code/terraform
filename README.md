# 🛡️ Azure Cloud Security & Infrastructure as Code Portfolio

**Language / Idioma:** [🇺🇸 English](#-english) | [🇧🇷 Português](#-português)

## 🇺🇸 English

[![Azure](https://img.shields.io/badge/Microsoft_Azure-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)](https://azure.microsoft.com/en-us/)
[![Terraform](https://img.shields.io/badge/Terraform-844FBA?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Infrastructure as Code](https://img.shields.io/badge/Infrastructure_as_Code-1F6FEB?style=for-the-badge)](https://developer.hashicorp.com/terraform)

Welcome! My name is **Matheus Saito**, and I work with **Microsoft Azure, cloud security, infrastructure, and Infrastructure as Code (IaC)**.

This repository documents my hands-on study of **Terraform** based on the book *Terraform: Up & Running, 3rd Edition*. Because the book primarily demonstrates Terraform concepts with **Amazon Web Services (AWS)**, I am adapting its examples to **Microsoft Azure** by translating AWS resources, arguments, and architectural patterns into their corresponding implementations with the **AzureRM provider**.

## 📖 About This Project

The purpose of this repository is not to produce a line-by-line conversion of the book's source code. Instead, it is to reproduce the concepts, exercises, and infrastructure patterns presented in the book using Azure-native services and Terraform resources.

During this process, I:

- Study the Terraform concepts and practices introduced in each chapter.
- Analyze the purpose and behavior of the AWS resources used in the original examples.
- Identify the closest Azure service or architectural equivalent.
- Rewrite the configurations using the `azurerm` provider and Azure-specific properties.
- Validate the infrastructure by deploying it in an Azure environment.
- Document differences where AWS and Azure do not provide a direct one-to-one mapping.
- Refactor the examples when Azure requires a different design rather than a direct syntax translation.

## 🔄 Translating AWS Examples to Azure

Cloud providers use different resource models, naming conventions, dependencies, and security boundaries. Therefore, translating an example often requires more than replacing one Terraform resource type with another.

Some conceptual mappings explored in this repository may include:

| AWS concept or service | Azure counterpart |
|---|---|
| AWS provider | AzureRM provider |
| Amazon EC2 | Azure Virtual Machines |
| Auto Scaling Groups | Virtual Machine Scale Sets |
| Elastic Load Balancing | Azure Load Balancer or Application Gateway |
| Amazon VPC | Azure Virtual Network |
| Security Groups | Network Security Groups |
| IAM roles and policies | Microsoft Entra identities and Azure RBAC |
| Amazon S3 | Azure Blob Storage |
| DynamoDB-based state locking | Azure Blob Storage state locking |
| Amazon EKS | Azure Kubernetes Service |
| AWS Secrets Manager | Azure Key Vault |
| Amazon RDS | Azure SQL or Azure Database services |

These mappings are conceptual and may vary according to the requirements of each exercise. When the platforms differ significantly, the Azure implementation prioritizes the original architectural objective rather than syntactic similarity.

## 🧭 Learning Approach

My primary references are:

1. *Terraform: Up & Running, 3rd Edition*, for the learning path, concepts, and original AWS-centered examples.
2. [Official Terraform documentation](https://developer.hashicorp.com/terraform/docs), for Terraform language and workflow guidance.
3. [AzureRM provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs), for Azure resource schemas, arguments, attributes, and examples.
4. [Microsoft Azure documentation](https://learn.microsoft.com/azure/), for Azure architecture, security, identity, networking, and service behavior.
5. AI-assisted tools, used occasionally to clarify concepts, compare provider implementations, troubleshoot errors, and fill knowledge gaps.

AI-generated suggestions are treated as supporting material rather than an authoritative source. Configurations are reviewed against official documentation and, whenever practical, validated through deployment and testing.

## 🎯 Objectives

This repository is intended to help me:

- Strengthen my Terraform fundamentals through practical implementation.
- Understand how Terraform patterns translate across cloud providers.
- Improve my knowledge of the AzureRM provider.
- Practice reusable, modular, and maintainable Infrastructure as Code.
- Explore Azure identity, networking, security, compute, storage, and Kubernetes services.
- Build a public portfolio that demonstrates hands-on Azure and Terraform experience.
- Record design decisions, limitations, errors, and lessons learned throughout the study process.

## 📂 Repository Organization

The repository is organized around the chapters, exercises, or infrastructure patterns covered during the study. Each directory may contain:

- Terraform configuration files.
- Input variables and local values.
- Output definitions.
- Reusable modules.
- Backend and state configuration examples.
- Azure-specific implementation notes.
- Commands used to initialize, validate, plan, apply, and destroy the environment.
- Documentation about relevant differences between the AWS example and the Azure implementation.

> The repository structure may evolve as new chapters and exercises are completed.

## ⚠️ Important Notes

- This is an independent study project and is not an official companion repository for the book.
- The original examples are being reimplemented for educational purposes rather than copied as a direct provider conversion.
- AWS and Azure services are not always equivalent, so some implementations require architectural adaptation.
- Resources deployed from this repository may generate Azure costs.
- Example environments should be reviewed before deployment and destroyed when they are no longer needed.
- Secrets, credentials, private keys, and sensitive state files must not be committed to source control.
- The configurations in this repository are learning examples and should be reviewed and hardened before use in production.

## 🚧 Project Status

This repository is a work in progress. Configurations and documentation will be expanded as I continue through the book and translate additional examples to Azure.

## 🏆 Certifications & Competencies

I hold Microsoft certifications that validate my knowledge of cloud architecture, networking, cybersecurity, and security operations:

- **SC-100:** [Microsoft Cybersecurity Architect Expert](https://learn.microsoft.com/api/credentials/share/en-us/MatheusLuizSaitoSoaresProdutivit-1442/844CFB8BF43D56AC?sharingId=AA351E191EB9C826)
- **AZ-305:** [Azure Solutions Architect Expert](https://learn.microsoft.com/api/credentials/share/en-us/MatheusLuizSaitoSoaresProdutivit-1442/746029FACFAAC01F?sharingId=AA351E191EB9C826)
- **AZ-700:** [Azure Network Engineer Associate](https://learn.microsoft.com/api/credentials/share/en-us/MatheusLuizSaitoSoaresProdutivit-1442/8B524359138DD108?sharingId=AA351E191EB9C826)
- **SC-200:** [Microsoft Security Operations Analyst](https://learn.microsoft.com/api/credentials/share/en-us/MatheusLuizSaitoSoaresProdutivit-1442/30BDE4437B437812?sharingId=AA351E191EB9C826)

## 📫 Let's Connect

I am open to remote opportunities involving **Cloud Security, DevSecOps, Azure Architecture, and Infrastructure as Code**.

- **LinkedIn:** [Matheus Luiz Saito Soares](https://www.linkedin.com/in/matheus-luiz-saito-soares-b7ab80236)
- **Email:** [matheus.saito0201@gmail.com](mailto:matheus.saito0201@gmail.com)

---

If this repository is useful to you, feel free to explore the examples and follow its progress.

## 🇧🇷 Português

[![Azure](https://img.shields.io/badge/Microsoft_Azure-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)](https://azure.microsoft.com/pt-br/)
[![Terraform](https://img.shields.io/badge/Terraform-844FBA?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Infraestrutura como Código](https://img.shields.io/badge/Infraestrutura_como_Código-1F6FEB?style=for-the-badge)](https://developer.hashicorp.com/terraform)

Bem-vindo! Meu nome é **Matheus Saito** e trabalho com **Arquiteto e Engenheiro de Segurança em Nuvem Azure**.

Este repositório documenta meu estudo prático de **Terraform** com base no livro *Terraform: Up & Running, 3rd Edition*. Como o livro demonstra os conceitos do Terraform principalmente com a **Amazon Web Services (AWS)**, estou adaptando seus exemplos para o **Microsoft Azure**, traduzindo recursos, argumentos e padrões de arquitetura da AWS para suas implementações correspondentes com o provedor **AzureRM**.

### 📖 Sobre este projeto

O objetivo deste repositório não é produzir uma conversão linha por linha do código-fonte do livro. Em vez disso, busco reproduzir no Azure os conceitos, exercícios e padrões de infraestrutura apresentados na obra, utilizando serviços nativos da plataforma e recursos do Terraform.

Durante esse processo, eu:

- Estudo os conceitos e as práticas do Terraform introduzidos em cada capítulo.
- Analiso o propósito e o comportamento dos recursos da AWS utilizados nos exemplos originais.
- Identifico o serviço ou padrão arquitetural equivalente mais próximo no Azure.
- Reescrevo as configurações utilizando o provedor `azurerm` e propriedades específicas do Azure.
- Valido a infraestrutura por meio de implantações em um ambiente Azure.
- Documento as diferenças quando AWS e Azure não oferecem um mapeamento direto de um para um.
- Refatoro os exemplos quando o Azure exige uma abordagem diferente em vez de uma tradução direta de sintaxe.

### 🔄 Traduzindo exemplos da AWS para Azure

Os provedores de nuvem utilizam modelos de recursos, convenções de nomenclatura, dependências e limites de segurança diferentes. Portanto, traduzir um exemplo geralmente exige mais do que substituir um tipo de recurso Terraform por outro.

Alguns dos mapeamentos conceituais explorados neste repositório podem incluir:

| Conceito ou serviço da AWS | Correspondente no Azure |
|---|---|
| Provedor AWS | Provedor AzureRM |
| Amazon EC2 | Máquinas Virtuais do Azure |
| Auto Scaling Groups | Conjuntos de Dimensionamento de Máquinas Virtuais |
| Elastic Load Balancing | Azure Load Balancer ou Application Gateway |
| Amazon VPC | Rede Virtual do Azure |
| Security Groups | Grupos de Segurança de Rede |
| Funções e políticas do IAM | Identidades do Microsoft Entra e Azure RBAC |
| Amazon S3 | Armazenamento de Blobs do Azure |
| Bloqueio de estado com DynamoDB | Bloqueio de estado no Armazenamento de Blobs do Azure |
| Amazon EKS | Serviço de Kubernetes do Azure |
| AWS Secrets Manager | Azure Key Vault |
| Amazon RDS | Azure SQL ou serviços de banco de dados do Azure |

Esses mapeamentos são conceituais e podem variar conforme os requisitos de cada exercício. Quando as plataformas apresentam diferenças significativas, a implementação no Azure prioriza o objetivo arquitetural original, e não a semelhança sintática.

### 🧭 Abordagem de aprendizado

Minhas principais referências são:

1. *Terraform: Up & Running, 3rd Edition*, utilizado como roteiro de estudos e como fonte dos conceitos e exemplos originais voltados à AWS.
2. [Documentação oficial do Terraform](https://developer.hashicorp.com/terraform/docs), utilizada para consultar a linguagem e o fluxo de trabalho do Terraform.
3. [Documentação do provedor AzureRM](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs), utilizada para consultar esquemas, argumentos, atributos e exemplos dos recursos do Azure.
4. [Documentação do Microsoft Azure](https://learn.microsoft.com/pt-br/azure/), utilizada para consultar arquitetura, segurança, identidade, redes e comportamento dos serviços do Azure.
5. Ferramentas assistidas por IA, utilizadas ocasionalmente para esclarecer conceitos, comparar implementações entre provedores, solucionar erros e preencher lacunas de conhecimento.

As sugestões geradas por IA são tratadas como material de apoio, e não como fonte oficial. As configurações são revisadas com base na documentação oficial e, sempre que possível, validadas por meio de implantação e testes.

### 🎯 Objetivos

Este repositório tem como objetivos:

- Fortalecer meus fundamentos de Terraform por meio da implementação prática.
- Compreender como padrões do Terraform podem ser adaptados entre provedores de nuvem.
- Aprimorar meu conhecimento do provedor AzureRM.
- Praticar Infraestrutura como Código reutilizável, modular e de fácil manutenção.
- Explorar serviços do Azure relacionados a identidade, redes, segurança, computação, armazenamento e Kubernetes.
- Construir um portfólio público que demonstre experiência prática com Azure e Terraform.
- Registrar decisões de projeto, limitações, erros e aprendizados ao longo do estudo.

### 📂 Organização do repositório

O repositório é organizado com base nos capítulos, exercícios ou padrões de infraestrutura abordados durante o estudo. Cada diretório pode conter:

- Arquivos de configuração do Terraform.
- Variáveis de entrada e valores locais.
- Definições de saída.
- Módulos reutilizáveis.
- Exemplos de configuração de backend e estado.
- Observações específicas sobre a implementação no Azure.
- Comandos utilizados para inicializar, validar, planejar, aplicar e destruir o ambiente.
- Documentação sobre diferenças relevantes entre o exemplo da AWS e a implementação no Azure.

> A estrutura do repositório pode evoluir à medida que novos capítulos e exercícios forem concluídos.

### ⚠️ Observações importantes

- Este é um projeto de estudo independente e não é um repositório complementar oficial do livro.
- Os exemplos originais estão sendo reimplementados para fins educacionais, e não copiados como uma conversão direta entre provedores.
- Os serviços da AWS e do Azure nem sempre são equivalentes, portanto algumas implementações exigem adaptações arquiteturais.
- Os recursos implantados a partir deste repositório podem gerar custos no Azure.
- Os ambientes de exemplo devem ser revisados antes da implantação e destruídos quando não forem mais necessários.
- Segredos, credenciais, chaves privadas e arquivos de estado sensíveis não devem ser enviados ao controle de versão.
- As configurações deste repositório são exemplos de aprendizado e devem ser revisadas e reforçadas antes de qualquer uso em produção.

### 🚧 Status do projeto

Este repositório está em desenvolvimento. As configurações e a documentação serão ampliadas à medida que eu avançar no livro e adaptar novos exemplos para o Azure.

### 🏆 Certificações e competências

Possuo certificações Microsoft que validam meus conhecimentos em arquitetura de nuvem, redes, cibersegurança e operações de segurança:

- **SC-100:** [Microsoft Cybersecurity Architect Expert](https://learn.microsoft.com/api/credentials/share/en-us/MatheusLuizSaitoSoaresProdutivit-1442/844CFB8BF43D56AC?sharingId=AA351E191EB9C826)
- **AZ-305:** [Azure Solutions Architect Expert](https://learn.microsoft.com/api/credentials/share/en-us/MatheusLuizSaitoSoaresProdutivit-1442/746029FACFAAC01F?sharingId=AA351E191EB9C826)
- **AZ-700:** [Azure Network Engineer Associate](https://learn.microsoft.com/api/credentials/share/en-us/MatheusLuizSaitoSoaresProdutivit-1442/8B524359138DD108?sharingId=AA351E191EB9C826)
- **SC-200:** [Microsoft Security Operations Analyst](https://learn.microsoft.com/api/credentials/share/en-us/MatheusLuizSaitoSoaresProdutivit-1442/30BDE4437B437812?sharingId=AA351E191EB9C826)

### 📫 Entre em contato

Estou aberto a oportunidades remotas relacionadas a **Segurança em Nuvem, DevSecOps, Arquitetura Azure e Infraestrutura como Código**.

- **LinkedIn:** [Matheus Luiz Saito Soares](https://www.linkedin.com/in/matheus-luiz-saito-soares-b7ab80236)
- **E-mail:** [matheus.saito0201@gmail.com](mailto:matheus.saito0201@gmail.com)

---

Se este repositório for útil para você, fique à vontade para explorar os exemplos e acompanhar sua evolução.