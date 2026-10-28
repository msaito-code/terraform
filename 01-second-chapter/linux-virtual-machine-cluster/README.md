# ⚖️ Linux VM Scale Set with Azure Load Balancer

**Language / Idioma:** [🇺🇸 English](#-english) | [🇧🇷 Português](#-português)

## 🇺🇸 English

## Overview

This exercise builds a small Linux web cluster in Microsoft Azure using Terraform, an Azure Virtual Machine Scale Set (VMSS), and a Standard Azure Load Balancer. It is part of my Azure-based adaptation of *Terraform: Up & Running, 3rd Edition*, whose examples are primarily focused on AWS.

The environment starts with **two Ubuntu 24.04 LTS VM instances** behind a public Load Balancer. Each instance starts a lightweight BusyBox HTTP server on TCP port 80 and dynamically writes its hostname to the page. Requests reaching the Load Balancer can therefore be served by different instances in the backend pool.

As with the other exercises in this repository, this is a learning environment. Some variable structures and resource choices intentionally exist so I can experiment with Terraform syntax and data types rather than represent a recommended production architecture.

## 🎯 Learning objectives

This exercise focuses on:

- Creating a Linux Virtual Machine Scale Set with Terraform.
- Starting multiple VM instances from the same configuration.
- Creating a public Azure Load Balancer.
- Connecting VMSS interfaces to a Load Balancer backend pool.
- Configuring a Load Balancer health probe and rule.
- Associating an NSG with the backend subnet.
- Bootstrapping identical web servers through `user_data`.
- Using lists and maps as Terraform variables.
- Referencing list indexes and map keys from `main.tf`.
- Storing Terraform state remotely in Azure Blob Storage.
- Referencing resource attributes to build Terraform's dependency graph.

## 🏗️ Architecture

The configuration creates:

- An Azure Resource Group.
- An Azure Virtual Network.
- A backend subnet.
- A static Standard Public IP.
- A Standard Azure Load Balancer.
- A Load Balancer frontend IP configuration.
- A backend address pool.
- A Linux Virtual Machine Scale Set containing two instances.
- VMSS network interfaces connected to the backend pool.
- A subnet-level NSG allowing HTTP traffic and Azure Load Balancer probe traffic on port 80.
- An HTTP health probe for `/index.html`.
- A TCP Load Balancer rule forwarding frontend port 80 to backend port 80.

```text
                         Internet
                            |
                         TCP/80
                            |
                    Static Public IP
                            |
                  Azure Load Balancer
                     HTTP health probe
                            |
                 Backend Address Pool
                            |
              +-------------+-------------+
              |                           |
        VMSS Instance 1              VMSS Instance 2
        BusyBox :80                   BusyBox :80
              |                           |
      Hello from <host>!          Hello from <host>!
              +-------------+-------------+
                            |
                    Backend Subnet
                       NSG: HTTP/80
                            |
                           VNet
```

## ⚖️ Load-balancing flow

The public frontend is associated with the static Public IP. The `http-rule` accepts TCP connections on port 80 and forwards them to port 80 on instances registered in `BackEndAddressPool`.

The Load Balancer checks backend health with an HTTP probe:

```hcl
resource "azurerm_lb_probe" "http_probe" {
    name            = "http-probe"
    loadbalancer_id = azurerm_lb.linux_fe_lb.id
    protocol        = "Http"
    port            = 80
    request_path    = "/index.html"
}
```

The VMSS network configuration directly associates each instance with the backend pool:

```hcl
load_balancer_backend_address_pool_ids = [
    azurerm_lb_backend_address_pool.linux_be_pool.id
]
```

## 🌐 Web-server bootstrap

Every VMSS instance receives the same Bash script through `user_data`:

```bash
#!/bin/bash
mkdir -p /var/www/html
echo "Hello from $(hostname)!" > /var/www/html/index.html
nohup busybox httpd -f -p 80 -h /var/www/html &
```

The hostname is generated independently by each VM instance. This makes the simple response useful for observing which backend instance handled a request while experimenting with load balancing.

After deployment, the service can be reached through the Load Balancer Public IP returned by Terraform:

```bash
terraform output lb_pip_id
curl http://<LOAD_BALANCER_PUBLIC_IP>
```

## 🛡️ Network Security Group

The NSG is associated with the VMSS subnet and contains two explicit inbound rules used by this exercise.

### HTTP traffic

`Allow-HTTP` permits TCP port 80 from the `Internet` service tag so clients can reach the web service.

### Load Balancer health probe

`Allow-LB-Probe` permits traffic sourced from the `AzureLoadBalancer` service tag to destination port 80. This supports the health-check path used to determine backend availability.

## 🧪 Intentional Terraform experiments

Several values in `variables.tf` are deliberately more elaborate than this small environment requires. They were added to practice Terraform collection types and references.

### List indexing for VNet address spaces

The variable contains three candidate address spaces:

```hcl
variable "vnet_available_address_spaces" {
    type = list(string)
    default = [
        "10.0.0.0/16",
        "10.16.0.0/16",
        "172.16.0.0/16"
    ]
}
```

The VNet intentionally selects only the first item:

```hcl
address_space = [var.vnet_available_address_spaces[0]]
```

The additional CIDR ranges are present to experiment with Terraform **lists and index-based references**. They are not additional address spaces currently assigned to the VNet and should not be interpreted as a production network design.

### Map lookup for subnet ranges

The subnet ranges are represented as a map:

```hcl
variable "first_cidr_block_mapping" {
    type = map(string)
    default = {
        first_subnet_block  = "10.0.1.0/24"
        second_subnet_block = "10.0.2.0/24"
    }
}
```

The current subnet selects one entry using:

```hcl
address_prefixes = [var.first_cidr_block_mapping.first_subnet_block]
```

Only the first subnet is created. The second entry exists to practice **map definitions and key-based references**, not because this exercise currently needs two subnets.

These experiments intentionally demonstrate two different Terraform collection-access patterns:

```hcl
var.vnet_available_address_spaces[0]
```

and:

```hcl
var.first_cidr_block_mapping.first_subnet_block
```

## 📈 Scale Set

The VMSS begins with:

```hcl
instances = 2
```

Both instances use the same Ubuntu image, OS-disk configuration, network definition, and startup script. This demonstrates how a scale set can provide multiple equivalent backend instances without declaring each VM as a separate Terraform resource.

This version does **not** define autoscale settings. `instances = 2` represents a fixed desired instance count in the current exercise.

## 💾 Remote Terraform state

Unlike the earlier simple VM exercise, this configuration declares an AzureRM backend:

```hcl
backend "azurerm" {
    resource_group_name  = "rg-terraform-state-sec-portfolio"
    storage_account_name = "tfstatesec61bb283b"
    container_name       = "tfstate"
    key                  = "second-deployment.terraform.tfstate"
}
```

This moves the Terraform state away from the local working directory and stores it in the configured Azure Storage backend. The backend resources must already exist and the identity running Terraform must be able to access the configured state storage.

## 📌 Variables

| Variable | Purpose | Default |
|---|---|---|
| `resource_group_location` | Azure region for the resources | `eastus2` |
| `resource_group_name_prefix` | Prefix for the Resource Group name | `rg` |
| `vms_be_name_prefix` | Naming prefix for the Linux backend resources | `ubu-be` |
| `vnet_available_address_spaces` | Candidate VNet CIDRs used to practice list references | `10.0.0.0/16`, `10.16.0.0/16`, `172.16.0.0/16` |
| `first_cidr_block_mapping` | Candidate subnet CIDRs used to practice map references | `first_subnet_block = 10.0.1.0/24`, `second_subnet_block = 10.0.2.0/24` |
| `username` | Local administrator username for the VMSS instances | `azureuser` |

## 📤 Output

The configuration exposes the Load Balancer's public IP:

```hcl
output "lb_pip_id" {
    value = azurerm_public_ip.linux_lb_fe_pip.ip_address
}
```

Despite the output name ending in `_id`, the returned value is the **IP address**, not the Azure resource ID. This is preserved here because it reflects the current learning configuration.

## 🚀 Basic workflow

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

Retrieve and test the Load Balancer endpoint:

```bash
terraform output lb_pip_id
curl http://<LOAD_BALANCER_PUBLIC_IP>
```

Because each instance writes its hostname into `index.html`, repeated requests can be used while experimenting with traffic distribution:

```bash
for i in {1..10}; do
  curl http://<LOAD_BALANCER_PUBLIC_IP>
  echo
done
```

When finished:

```bash
terraform destroy
```

The remote backend itself is not declared as a resource by this configuration and therefore is not removed by this `terraform destroy`.

## ⚠️ Learning-environment notes

This configuration is intended for study and experimentation rather than production use:

- The VMSS administrator password is currently hard-coded in `main.tf`. Secrets and passwords should not be committed to source control or embedded directly in reusable infrastructure definitions.
- Password authentication is enabled. A hardened environment should use an authentication model appropriate to its operational requirements.
- HTTP is intentionally exposed to the Internet on port 80 for this exercise.
- The BusyBox HTTP server is a minimal test workload, not a production web platform.
- The instance count is fixed at two. No autoscaling policy is configured in this version.
- The extra VNet CIDRs and subnet-map entry are intentionally unused and exist to practice Terraform collection types and references.
- The backend configuration contains environment-specific Azure Storage resource names and should be adapted before reuse elsewhere.

## 🚧 Project status

This is a learning exercise created while translating infrastructure patterns from *Terraform: Up & Running, 3rd Edition* from AWS-oriented examples into AzureRM implementations. I expect the configuration to evolve as later exercises introduce additional Terraform and Azure concepts.

---

## 🇧🇷 Português

## Visão geral

Este exercício cria um pequeno cluster de servidores web Linux no Microsoft Azure utilizando Terraform, um Azure Virtual Machine Scale Set (VMSS) e um Azure Load Balancer Standard. Ele faz parte da minha adaptação para Azure do livro *Terraform: Up & Running, 3rd Edition*, cujos exemplos são majoritariamente voltados para AWS.

O ambiente inicia com **duas instâncias Ubuntu 24.04 LTS** atrás de um Load Balancer público. Cada instância inicia um servidor HTTP leve do BusyBox na porta TCP 80 e grava dinamicamente seu hostname na página. Dessa forma, as requisições que chegam ao Load Balancer podem ser atendidas por diferentes instâncias do backend pool.

Assim como nos outros exercícios deste repositório, este é um ambiente de aprendizado. Algumas estruturas de variáveis e escolhas de recursos existem propositalmente para que eu possa experimentar a sintaxe e os tipos de dados do Terraform, e não para representar uma arquitetura recomendada para produção.

## 🎯 Objetivos de aprendizado

Este exercício tem como foco:

- Criar um Linux Virtual Machine Scale Set com Terraform.
- Inicializar múltiplas instâncias de VM a partir da mesma configuração.
- Criar um Azure Load Balancer público.
- Conectar as interfaces do VMSS ao backend pool do Load Balancer.
- Configurar uma regra e um health probe do Load Balancer.
- Associar um NSG à sub-rede do backend.
- Inicializar servidores web idênticos por meio de `user_data`.
- Utilizar listas e mapas como variáveis do Terraform.
- Referenciar índices de listas e chaves de mapas a partir do `main.tf`.
- Armazenar o estado do Terraform remotamente no Azure Blob Storage.
- Referenciar atributos entre recursos para construir o grafo de dependências do Terraform.

## 🏗️ Arquitetura

A configuração cria:

- Um Grupo de Recursos do Azure.
- Uma Rede Virtual do Azure.
- Uma sub-rede de backend.
- Um IP Público Standard e estático.
- Um Azure Load Balancer Standard.
- Uma configuração de IP frontend do Load Balancer.
- Um backend address pool.
- Um Linux Virtual Machine Scale Set contendo duas instâncias.
- Interfaces de rede do VMSS conectadas ao backend pool.
- Um NSG associado à sub-rede permitindo HTTP e o tráfego de probe do Azure Load Balancer na porta 80.
- Um health probe HTTP para `/index.html`.
- Uma regra TCP do Load Balancer encaminhando a porta 80 do frontend para a porta 80 do backend.

```text
                         Internet
                            |
                         TCP/80
                            |
                    IP Público Estático
                            |
                  Azure Load Balancer
                     Health Probe HTTP
                            |
                   Backend Address Pool
                            |
              +-------------+-------------+
              |                           |
        Instância VMSS 1             Instância VMSS 2
        BusyBox :80                   BusyBox :80
              |                           |
      Hello from <host>!          Hello from <host>!
              +-------------+-------------+
                            |
                   Sub-rede Backend
                       NSG: HTTP/80
                            |
                           VNet
```

## ⚖️ Fluxo de balanceamento

O frontend público está associado ao IP Público estático. A regra `http-rule` recebe conexões TCP na porta 80 e as encaminha para a porta 80 das instâncias registradas em `BackEndAddressPool`.

O Load Balancer verifica a saúde dos backends por meio de um probe HTTP:

```hcl
resource "azurerm_lb_probe" "http_probe" {
    name            = "http-probe"
    loadbalancer_id = azurerm_lb.linux_fe_lb.id
    protocol        = "Http"
    port            = 80
    request_path    = "/index.html"
}
```

A configuração de rede do VMSS associa diretamente cada instância ao backend pool:

```hcl
load_balancer_backend_address_pool_ids = [
    azurerm_lb_backend_address_pool.linux_be_pool.id
]
```

## 🌐 Inicialização do servidor web

Cada instância do VMSS recebe o mesmo script Bash através de `user_data`:

```bash
#!/bin/bash
mkdir -p /var/www/html
echo "Hello from $(hostname)!" > /var/www/html/index.html
nohup busybox httpd -f -p 80 -h /var/www/html &
```

O hostname é gerado individualmente por cada instância. Isso torna a resposta simples útil para observar qual instância do backend atendeu uma requisição enquanto experimento o balanceamento de carga.

Após a implantação, o serviço pode ser acessado pelo IP Público do Load Balancer retornado pelo Terraform:

```bash
terraform output lb_pip_id
curl http://<IP_PUBLICO_DO_LOAD_BALANCER>
```

## 🛡️ Network Security Group

O NSG está associado à sub-rede do VMSS e possui duas regras explícitas de entrada utilizadas neste exercício.

### Tráfego HTTP

`Allow-HTTP` permite a porta TCP 80 a partir da service tag `Internet`, permitindo que clientes alcancem o serviço web.

### Health probe do Load Balancer

`Allow-LB-Probe` permite tráfego originado da service tag `AzureLoadBalancer` com destino à porta 80. Isso dá suporte à verificação utilizada para determinar a disponibilidade dos backends.

## 🧪 Experimentações intencionais com Terraform

Diversos valores do `variables.tf` são propositalmente mais elaborados do que este pequeno ambiente realmente necessita. Eles foram incluídos para praticar tipos de coleções e referências no Terraform.

### Indexação de lista para os espaços de endereçamento da VNet

A variável contém três espaços de endereçamento candidatos:

```hcl
variable "vnet_available_address_spaces" {
    type = list(string)
    default = [
        "10.0.0.0/16",
        "10.16.0.0/16",
        "172.16.0.0/16"
    ]
}
```

A VNet seleciona propositalmente apenas o primeiro item:

```hcl
address_space = [var.vnet_available_address_spaces[0]]
```

Os CIDRs adicionais existem para experimentar **listas e referências por índice no Terraform**. Eles não representam espaços de endereçamento adicionais atualmente atribuídos à VNet e não devem ser interpretados como um desenho de rede para produção.

### Consulta a mapa para as sub-redes

Os intervalos das sub-redes são representados como um mapa:

```hcl
variable "first_cidr_block_mapping" {
    type = map(string)
    default = {
        first_subnet_block  = "10.0.1.0/24"
        second_subnet_block = "10.0.2.0/24"
    }
}
```

A sub-rede atual seleciona uma entrada através de:

```hcl
address_prefixes = [var.first_cidr_block_mapping.first_subnet_block]
```

Somente a primeira sub-rede é criada. A segunda entrada existe para praticar **a definição de mapas e referências por chave**, e não porque este exercício atualmente precise de duas sub-redes.

Essas experiências demonstram propositalmente dois padrões diferentes de acesso a coleções no Terraform:

```hcl
var.vnet_available_address_spaces[0]
```

e:

```hcl
var.first_cidr_block_mapping.first_subnet_block
```

## 📈 Scale Set

O VMSS começa com:

```hcl
instances = 2
```

As duas instâncias utilizam a mesma imagem Ubuntu, configuração de disco do sistema operacional, definição de rede e script de inicialização. Isso demonstra como um Scale Set pode fornecer várias instâncias equivalentes no backend sem declarar cada VM como um recurso Terraform separado.

Esta versão **não** define configurações de autoscale. `instances = 2` representa uma quantidade fixa desejada de instâncias no exercício atual.

## 💾 Estado remoto do Terraform

Diferentemente do exercício anterior com uma VM simples, esta configuração declara um backend AzureRM:

```hcl
backend "azurerm" {
    resource_group_name  = "rg-terraform-state-sec-portfolio"
    storage_account_name = "tfstatesec61bb283b"
    container_name       = "tfstate"
    key                  = "second-deployment.terraform.tfstate"
}
```

Isso move o estado do Terraform para fora do diretório de trabalho local e o armazena no backend configurado no Azure Storage. Os recursos do backend precisam existir previamente, e a identidade que executa o Terraform precisa conseguir acessar o armazenamento de estado configurado.

## 📌 Variáveis

| Variável | Finalidade | Padrão |
|---|---|---|
| `resource_group_location` | Região do Azure para os recursos | `eastus2` |
| `resource_group_name_prefix` | Prefixo para o nome do Grupo de Recursos | `rg` |
| `vms_be_name_prefix` | Prefixo dos recursos Linux do backend | `ubu-be` |
| `vnet_available_address_spaces` | CIDRs candidatos da VNet usados para praticar referências em listas | `10.0.0.0/16`, `10.16.0.0/16`, `172.16.0.0/16` |
| `first_cidr_block_mapping` | CIDRs candidatos de sub-redes usados para praticar referências em mapas | `first_subnet_block = 10.0.1.0/24`, `second_subnet_block = 10.0.2.0/24` |
| `username` | Nome do administrador local das instâncias do VMSS | `azureuser` |

## 📤 Output

A configuração expõe o IP público do Load Balancer:

```hcl
output "lb_pip_id" {
    value = azurerm_public_ip.linux_lb_fe_pip.ip_address
}
```

Embora o nome do output termine em `_id`, o valor retornado é o **endereço IP**, e não o resource ID do Azure. Mantive essa observação porque ela reflete a configuração atual do exercício.

## 🚀 Fluxo básico

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

Recupere e teste o endpoint do Load Balancer:

```bash
terraform output lb_pip_id
curl http://<IP_PUBLICO_DO_LOAD_BALANCER>
```

Como cada instância grava seu hostname em `index.html`, requisições repetidas podem ser utilizadas durante os testes de distribuição de tráfego:

```bash
for i in {1..10}; do
  curl http://<IP_PUBLICO_DO_LOAD_BALANCER>
  echo
done
```

Ao concluir:

```bash
terraform destroy
```

O backend remoto em si não é declarado como recurso por esta configuração e, portanto, não é removido por este `terraform destroy`.

## ⚠️ Observações sobre o ambiente de aprendizado

Esta configuração foi criada para estudo e experimentação, e não para uso em produção:

- A senha administrativa do VMSS está atualmente definida diretamente no `main.tf`. Segredos e senhas não devem ser commitados no controle de versão nem incorporados diretamente em definições reutilizáveis de infraestrutura.
- A autenticação por senha está habilitada. Um ambiente reforçado deve utilizar um modelo de autenticação adequado aos seus requisitos operacionais.
- HTTP está propositalmente exposto à Internet na porta 80 para este exercício.
- O servidor HTTP BusyBox é uma carga mínima para testes, não uma plataforma web para produção.
- A quantidade de instâncias está fixa em duas. Nenhuma política de autoscaling está configurada nesta versão.
- Os CIDRs adicionais da VNet e a entrada extra do mapa de sub-redes permanecem intencionalmente sem uso para praticar tipos de coleções e referências do Terraform.
- A configuração do backend contém nomes de recursos do Azure Storage específicos deste ambiente e deve ser adaptada antes de ser reutilizada em outro ambiente.

## 🚧 Status do projeto

Este é um exercício de aprendizado criado durante a tradução de padrões de infraestrutura do livro *Terraform: Up & Running, 3rd Edition* de exemplos orientados à AWS para implementações com AzureRM. A configuração deverá evoluir à medida que os próximos exercícios introduzirem outros conceitos do Terraform e do Azure.
