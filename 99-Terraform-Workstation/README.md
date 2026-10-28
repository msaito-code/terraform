# 💻 On-Demand Azure Terraform Workstation

**Language / Idioma:** [🇺🇸 English](#-english) | [🇧🇷 Português](#-português)

## 🇺🇸 English

## Overview

This project deploys an on-demand Linux workstation in Microsoft Azure for studying and developing with Terraform from devices where I do not have local administrator rights or cannot install the required tools.

The environment can be created remotely with Azure CLI and accessed through SSH from any compatible device. During its first boot, cloud-init installs Terraform, Azure CLI, Git, and the supporting packages; configures Azure authentication through a user-assigned managed identity; retrieves a GitHub SSH private key from Azure Key Vault; and clones the Terraform study repository.

The goal is to reduce workstation setup time. After deployment, I can connect to the VM, enter the cloned repository, start coding, and push changes to GitHub without repeating the development-environment configuration.

> This is a personal learning environment. Review the network access rules, identity permissions, credential handling, and cost implications before adapting it for production or shared use.

## 🎯 Problem addressed

Some managed, borrowed, or restricted computers do not allow local software installation because the user does not have administrator rights. This project moves the Terraform development environment to Azure so that the local device only needs:

- Azure CLI access to deploy the infrastructure.
- An SSH client to connect to the VM.
- Network connectivity to Azure and GitHub.

The development tools and repository credentials remain in the temporary Azure workstation rather than depending on the configuration of the device used to access it.

## 🏗️ Architecture

The Terraform configuration creates the following resources:

- An Azure resource group for the workstation resources.
- A virtual network and subnet.
- A static Standard public IP address.
- A network interface connected to the subnet and public IP.
- A network security group with an inbound SSH rule on TCP port 22.
- A subnet-to-NSG association.
- An Ubuntu 24.04 LTS Linux virtual machine.
- A Standard locally redundant OS disk.

The configuration also references resources that already exist outside this deployment:

- A user-assigned managed identity named `id-terraform-workstation`.
- An Azure SSH public key named `default-ssh-key`.
- An Azure Key Vault named `github-kv-default`.
- A Key Vault secret named `github-terraform-private-key`.

Keeping the managed identity and SSH-related secrets outside the workstation deployment allows the VM and its resource group to be destroyed without deleting the reusable identity or the GitHub credential stored in Key Vault.

```text
Restricted or unmanaged device
          |
          | Azure CLI deployment and SSH
          v
    Static Public IP
          |
     NSG: TCP/22
          |
         NIC
          |
       Subnet
          |
        VNet
          |
 Ubuntu Terraform Workstation
      |             |
      | Managed     | SSH deploy key
      | Identity    |
      v             v
 Azure Key Vault   GitHub repository
```

## 🔐 Authentication flow

### Azure authentication

The VM receives the existing user-assigned managed identity through the `identity` block. The cloud-init configuration writes the following Terraform AzureRM environment variables to `/etc/profile.d/terraform-azure.sh`:

- `ARM_USE_MSI=true`
- `ARM_CLIENT_ID`
- `ARM_SUBSCRIPTION_ID`
- `ARM_TENANT_ID`

This enables Terraform processes started in a login shell to use managed identity authentication instead of storing a service principal secret on the VM.

The cloud-init process also authenticates Azure CLI with:

```bash
az login --identity --client-id "${managed_identity_client_id}"
```

The identity must already have the Azure RBAC roles required by the Terraform exercises and permission to read the GitHub private-key secret from Key Vault.

### GitHub authentication

During provisioning, the VM uses its managed identity to read `github-terraform-private-key` from Azure Key Vault. The retrieved value is saved as:

```text
/home/azureuser/.ssh/github_terraform
```

The file is restricted to the `azureuser` account with mode `600`. An SSH configuration entry then instructs Git to use this key for `github.com`, after which cloud-init clones:

```text
git@github.com:msaito-code/terraform.git
```

The corresponding public key must be configured in GitHub with the required repository access. If push access is required, the GitHub key configuration must permit write access.

## ⚙️ Automated bootstrap with cloud-init

The `cloud-init.yaml` template performs the initial workstation configuration:

1. Updates the package index.
2. Installs Git, cURL, Wget, GnuPG, certificate packages, and repository-management dependencies.
3. Adds the HashiCorp APT repository and installs Terraform.
4. Installs Azure CLI.
5. Configures the global Git user name and email for `azureuser`.
6. Creates and secures the user's `.ssh` directory.
7. Authenticates Azure CLI using the user-assigned managed identity.
8. Retrieves the GitHub private key from Azure Key Vault.
9. Configures SSH to use the retrieved key for GitHub.
10. Adds GitHub to `known_hosts`.
11. Clones the Terraform repository into `/home/azureuser/terraform`.
12. Writes version information for Terraform, Git, and Azure CLI to `/var/log`.

The Terraform `templatefile` function supplies the managed identity, subscription, tenant, Key Vault, Git, and repository values to cloud-init. The rendered configuration is Base64-encoded and assigned to the VM's `custom_data` property.

## 📁 Suggested directory structure

```text
01-terraform-workstation/
├── main.tf
├── variables.tf
├── outputs.tf
├── cloud-init.yaml
├── terraform.tfvars.example
└── README.md
```

An `outputs.tf` file can expose the public IP address and an SSH command after deployment.

## ✅ Prerequisites

Before deployment, the following items must exist:

- An Azure subscription.
- Terraform and Azure CLI on the device used for the initial deployment.
- An authenticated Azure CLI session with permission to deploy the workstation resources.
- The `ssh-vault-rg` resource group.
- The `id-terraform-workstation` user-assigned managed identity.
- The `default-ssh-key` Azure SSH public-key resource.
- The `github-kv-default` Key Vault.
- The `github-terraform-private-key` Key Vault secret.
- Azure RBAC and Key Vault permissions assigned to the managed identity.
- The matching public key configured in GitHub for the target repository.

## 🚀 Deployment

Authenticate to Azure:

```bash
az login
az account set --subscription "<subscription-id-or-name>"
```

Initialize and validate the Terraform configuration:

```bash
terraform init
terraform fmt -recursive
terraform validate
```

Review and apply the plan:

```bash
terraform plan -out=tfplan
terraform apply tfplan
```

After deployment, connect to the VM:

```bash
ssh azureuser@<public-ip-address>
```

The repository should be available at:

```bash
cd /home/azureuser/terraform
```

Verify the environment:

```bash
terraform version
az account show

git config --global --list
git -C /home/azureuser/terraform remote -v
ssh -T git@github.com
```

## 🧹 Cost control and cleanup

This workstation is intended to be created when needed and destroyed after the study session. To remove the resources managed by this configuration:

```bash
terraform destroy
```

The externally managed identity, SSH public-key resource, Key Vault, and GitHub private-key secret are data sources or external dependencies and are not destroyed by this configuration.

Before destroying the workstation, commit and push any work that must be preserved. Files stored only on the VM OS disk will be deleted with the VM and its resource group.

## 🔎 Important implementation notes

### Subnet variable

The supplied configuration declares both `tf_vm_vnet` and `tf_vm_subnet`, but the subnet currently uses:

```hcl
address_prefixes = [var.tf_vm_vnet]
```

It should use the subnet-specific variable:

```hcl
address_prefixes = [var.tf_vm_subnet]
```

Using the VNet address space as the subnet prefix prevents the declared `10.0.1.0/24` subnet value from being applied and leaves no address space for additional subnets.

### SSH exposure

The current NSG rule allows TCP port 22 from the entire Internet:

```hcl
source_address_prefix = "Internet"
```

This supports access from changing locations but increases exposure. When possible, replace it with a trusted public IP or CIDR range. Other alternatives include Azure Bastion or a private connectivity solution.

### Host-key verification

The current bootstrap uses `ssh-keyscan github.com` to populate `known_hosts`. For a hardened implementation, validate GitHub's published SSH host-key fingerprints before trusting the generated entry.

### Key Vault authorization

The managed identity needs secret-read permission on the Key Vault. Depending on the Key Vault authorization model, this is provided through Azure RBAC or a Key Vault access policy. Avoid granting broader permissions than required.

### GitHub credential scope

The private key retrieved from Key Vault should be scoped only to the repositories and operations required by this workstation. Prefer a repository-specific deploy key when only one repository is needed.

### cloud-init troubleshooting

If the VM deploys but the software or repository is missing, inspect:

```bash
sudo cloud-init status --long
sudo tail -n 200 /var/log/cloud-init-output.log
sudo cat /var/log/terraform-version.log
sudo cat /var/log/git-version.log
sudo cat /var/log/azure-cli-version.log
```

## 📌 Variables

| Variable | Description | Default |
|---|---|---|
| `tf_vm_rg_location` | Azure region for the workstation resource group and resources | `westus3` |
| `tf_vm_prefix` | Naming prefix for the VM and associated resources | `dev-tf` |
| `tf_vm_vnet` | Address space for the virtual network | `10.0.0.0/16` |
| `tf_vm_subnet` | Address prefix for the workstation subnet | `10.0.1.0/24` |

## 🚧 Project status

This is an active learning project created as part of my Azure-based adaptation of *Terraform: Up & Running, 3rd Edition*. The implementation may evolve as I improve its security, automation, portability, and cost controls.

---

## 🇧🇷 Português

## Visão geral

Este projeto implanta uma estação de trabalho Linux sob demanda no Microsoft Azure para estudar e desenvolver com Terraform a partir de dispositivos nos quais não possuo direitos de administrador local ou não posso instalar as ferramentas necessárias.

O ambiente pode ser criado remotamente com a Azure CLI e acessado via SSH por qualquer dispositivo compatível. Durante a primeira inicialização, o cloud-init instala Terraform, Azure CLI, Git e os pacotes de apoio; configura a autenticação no Azure por meio de uma identidade gerenciada atribuída pelo usuário; recupera uma chave SSH privada do GitHub armazenada no Azure Key Vault; e clona o repositório de estudos de Terraform.

O objetivo é reduzir o tempo de preparação da estação de trabalho. Após a implantação, posso me conectar à VM, acessar o repositório clonado, começar a programar e enviar as alterações ao GitHub sem repetir a configuração do ambiente de desenvolvimento.

> Este é um ambiente pessoal de estudos. Revise as regras de acesso à rede, as permissões da identidade, o tratamento das credenciais e os custos antes de adaptá-lo para produção ou uso compartilhado.

## 🎯 Problema solucionado

Alguns computadores gerenciados, emprestados ou restritos não permitem a instalação local de programas porque o usuário não possui direitos administrativos. Este projeto move o ambiente de desenvolvimento Terraform para o Azure, de modo que o dispositivo local precise apenas de:

- Acesso à Azure CLI para implantar a infraestrutura.
- Um cliente SSH para se conectar à VM.
- Conectividade de rede com o Azure e o GitHub.

As ferramentas de desenvolvimento e as credenciais do repositório permanecem na estação de trabalho temporária do Azure, sem depender da configuração do dispositivo utilizado para acessá-la.

## 🏗️ Arquitetura

A configuração do Terraform cria os seguintes recursos:

- Um grupo de recursos do Azure para a estação de trabalho.
- Uma rede virtual e uma sub-rede.
- Um endereço IP público Standard e estático.
- Uma interface de rede conectada à sub-rede e ao IP público.
- Um grupo de segurança de rede com uma regra de entrada SSH na porta TCP 22.
- Uma associação entre a sub-rede e o NSG.
- Uma máquina virtual Linux com Ubuntu 24.04 LTS.
- Um disco de sistema operacional Standard com redundância local.

A configuração também referencia recursos que já existem fora desta implantação:

- Uma identidade gerenciada atribuída pelo usuário chamada `id-terraform-workstation`.
- Uma chave pública SSH do Azure chamada `default-ssh-key`.
- Um Azure Key Vault chamado `github-kv-default`.
- Um segredo do Key Vault chamado `github-terraform-private-key`.

Manter a identidade gerenciada e os segredos relacionados ao SSH fora da implantação da estação permite destruir a VM e seu grupo de recursos sem excluir a identidade reutilizável ou a credencial do GitHub armazenada no Key Vault.

```text
Dispositivo restrito ou não gerenciado
          |
          | Implantação com Azure CLI e acesso SSH
          v
     IP público estático
          |
      NSG: TCP/22
          |
         NIC
          |
      Sub-rede
          |
        VNet
          |
 Estação Terraform Ubuntu
      |             |
      | Identidade  | Chave SSH
      | gerenciada  | do GitHub
      v             v
 Azure Key Vault   Repositório GitHub
```

## 🔐 Fluxo de autenticação

### Autenticação no Azure

A VM recebe a identidade gerenciada atribuída pelo usuário por meio do bloco `identity`. O cloud-init grava as seguintes variáveis de ambiente do provedor AzureRM em `/etc/profile.d/terraform-azure.sh`:

- `ARM_USE_MSI=true`
- `ARM_CLIENT_ID`
- `ARM_SUBSCRIPTION_ID`
- `ARM_TENANT_ID`

Com isso, os processos do Terraform iniciados em um shell de login podem utilizar a identidade gerenciada sem armazenar o segredo de uma entidade de serviço na VM.

O cloud-init também autentica a Azure CLI com:

```bash
az login --identity --client-id "${managed_identity_client_id}"
```

A identidade deve possuir previamente as funções do Azure RBAC necessárias para os exercícios do Terraform e permissão para ler o segredo da chave privada do GitHub no Key Vault.

### Autenticação no GitHub

Durante o provisionamento, a VM utiliza sua identidade gerenciada para ler o segredo `github-terraform-private-key` no Azure Key Vault. O valor recuperado é salvo em:

```text
/home/azureuser/.ssh/github_terraform
```

O arquivo fica restrito à conta `azureuser` com o modo `600`. Uma entrada na configuração SSH instrui o Git a utilizar essa chave para `github.com`. Em seguida, o cloud-init clona:

```text
git@github.com:msaito-code/terraform.git
```

A chave pública correspondente deve estar configurada no GitHub com o acesso necessário ao repositório. Caso seja necessário enviar alterações, a configuração da chave no GitHub deve permitir acesso de gravação.

## ⚙️ Configuração automatizada com cloud-init

O modelo `cloud-init.yaml` executa a configuração inicial da estação:

1. Atualiza o índice de pacotes.
2. Instala Git, cURL, Wget, GnuPG, certificados e dependências para gerenciamento de repositórios.
3. Adiciona o repositório APT da HashiCorp e instala o Terraform.
4. Instala a Azure CLI.
5. Configura globalmente o nome e o e-mail do Git para `azureuser`.
6. Cria e protege o diretório `.ssh` do usuário.
7. Autentica a Azure CLI utilizando a identidade gerenciada atribuída pelo usuário.
8. Recupera a chave privada do GitHub do Azure Key Vault.
9. Configura o SSH para utilizar a chave recuperada no GitHub.
10. Adiciona o GitHub ao arquivo `known_hosts`.
11. Clona o repositório Terraform em `/home/azureuser/terraform`.
12. Grava as versões do Terraform, Git e Azure CLI em arquivos dentro de `/var/log`.

A função `templatefile` do Terraform fornece ao cloud-init os valores da identidade gerenciada, assinatura, locatário, Key Vault, Git e repositório. A configuração renderizada é codificada em Base64 e atribuída à propriedade `custom_data` da VM.

## 📁 Estrutura de diretórios sugerida

```text
01-terraform-workstation/
├── main.tf
├── variables.tf
├── outputs.tf
├── cloud-init.yaml
├── terraform.tfvars.example
└── README.md
```

Um arquivo `outputs.tf` pode apresentar o endereço IP público e um comando SSH após a implantação.

## ✅ Pré-requisitos

Antes da implantação, os seguintes itens devem existir:

- Uma assinatura do Azure.
- Terraform e Azure CLI no dispositivo usado para a implantação inicial.
- Uma sessão autenticada na Azure CLI com permissão para implantar os recursos da estação.
- O grupo de recursos `ssh-vault-rg`.
- A identidade gerenciada atribuída pelo usuário `id-terraform-workstation`.
- O recurso de chave pública SSH do Azure `default-ssh-key`.
- O Key Vault `github-kv-default`.
- O segredo `github-terraform-private-key` no Key Vault.
- Permissões do Azure RBAC e do Key Vault atribuídas à identidade gerenciada.
- A chave pública correspondente configurada no GitHub para o repositório de destino.

## 🚀 Implantação

Autentique-se no Azure:

```bash
az login
az account set --subscription "<id-ou-nome-da-assinatura>"
```

Inicialize e valide a configuração do Terraform:

```bash
terraform init
terraform fmt -recursive
terraform validate
```

Revise e aplique o plano:

```bash
terraform plan -out=tfplan
terraform apply tfplan
```

Após a implantação, conecte-se à VM:

```bash
ssh azureuser@<endereco-ip-publico>
```

O repositório deverá estar disponível em:

```bash
cd /home/azureuser/terraform
```

Valide o ambiente:

```bash
terraform version
az account show

git config --global --list
git -C /home/azureuser/terraform remote -v
ssh -T git@github.com
```

## 🧹 Controle de custos e limpeza

Esta estação foi projetada para ser criada quando necessária e destruída ao final da sessão de estudos. Para remover os recursos gerenciados pela configuração:

```bash
terraform destroy
```

A identidade gerenciada externa, o recurso de chave pública SSH, o Key Vault e o segredo da chave privada do GitHub são fontes de dados ou dependências externas e não são destruídos por esta configuração.

Antes de destruir a estação, faça commit e push de todo trabalho que precise ser preservado. Arquivos mantidos apenas no disco de sistema operacional da VM serão excluídos com a VM e seu grupo de recursos.

## 🔎 Observações importantes sobre a implementação

### Variável da sub-rede

A configuração fornecida declara `tf_vm_vnet` e `tf_vm_subnet`, mas a sub-rede utiliza atualmente:

```hcl
address_prefixes = [var.tf_vm_vnet]
```

Ela deve utilizar a variável específica da sub-rede:

```hcl
address_prefixes = [var.tf_vm_subnet]
```

Usar o espaço de endereçamento da VNet como prefixo da sub-rede impede a aplicação do valor `10.0.1.0/24` declarado e não deixa espaço de endereçamento para sub-redes adicionais.

### Exposição do SSH

A regra atual do NSG permite acesso à porta TCP 22 a partir de toda a Internet:

```hcl
source_address_prefix = "Internet"
```

Isso facilita o acesso a partir de locais variáveis, mas aumenta a exposição. Quando possível, substitua esse valor por um endereço IP público ou intervalo CIDR confiável. Outras alternativas incluem Azure Bastion ou uma solução de conectividade privada.

### Verificação da chave do host

O bootstrap atual utiliza `ssh-keyscan github.com` para preencher o arquivo `known_hosts`. Em uma implementação reforçada, valide as impressões digitais das chaves de host SSH publicadas pelo GitHub antes de confiar na entrada gerada.

### Autorização no Key Vault

A identidade gerenciada precisa de permissão de leitura de segredos no Key Vault. Conforme o modelo de autorização utilizado pelo cofre, essa permissão pode ser fornecida pelo Azure RBAC ou por uma política de acesso do Key Vault. Evite conceder permissões mais amplas do que o necessário.

### Escopo da credencial do GitHub

A chave privada recuperada do Key Vault deve ser limitada aos repositórios e às operações necessárias pela estação. Dê preferência a uma deploy key específica do repositório quando apenas um repositório for necessário.

### Diagnóstico do cloud-init

Caso a VM seja implantada, mas os programas ou o repositório não estejam disponíveis, verifique:

```bash
sudo cloud-init status --long
sudo tail -n 200 /var/log/cloud-init-output.log
sudo cat /var/log/terraform-version.log
sudo cat /var/log/git-version.log
sudo cat /var/log/azure-cli-version.log
```

## 📌 Variáveis

| Variável | Descrição | Padrão |
|---|---|---|
| `tf_vm_rg_location` | Região do Azure para o grupo de recursos e os recursos da estação | `westus3` |
| `tf_vm_prefix` | Prefixo de nomenclatura da VM e dos recursos associados | `dev-tf` |
| `tf_vm_vnet` | Espaço de endereçamento da rede virtual | `10.0.0.0/16` |
| `tf_vm_subnet` | Prefixo de endereçamento da sub-rede da estação | `10.0.1.0/24` |

## 🚧 Status do projeto

Este é um projeto de aprendizado ativo, criado como parte da minha adaptação para Azure do livro *Terraform: Up & Running, 3rd Edition*. A implementação poderá evoluir à medida que eu aprimorar sua segurança, automação, portabilidade e controle de custos.
