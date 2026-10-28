# 🗄️ Chapter 3: Remote State and Service Isolation

**Language / Idioma:** [🇺🇸 English](#-english) | [🇧🇷 Português](#-português)

## 🇺🇸 English

## Overview

In Chapter 3 of my Azure-based adaptation of *Terraform: Up & Running, 3rd Edition*, I reorganized the Linux web cluster into multiple independently managed Terraform configurations and introduced an **AzureRM remote backend**.

Instead of keeping all infrastructure in one Terraform state file, the environment is divided into a backend bootstrap configuration and four service configurations:

- `backend`: creates the Azure Storage Account and private Blob container used for Terraform state.
- `vnet`: creates the shared Resource Group, Virtual Network, subnet, and Load Balancer Public IP.
- `lb`: creates the Load Balancer, backend pool, health probe, and forwarding rule.
- `nsg`: creates the Network Security Group and associates it with the shared subnet.
- `webserver-cluster`: creates the Linux Virtual Machine Scale Set and connects it to the shared subnet and Load Balancer backend pool.

Each service stores its state in a different blob and obtains shared values from other state files through `terraform_remote_state`.

> This is a learning implementation. The purpose is to practice remote state, state isolation, outputs, cross-configuration dependencies, and staged deployment. It is not presented as a production-ready platform design.

## 🎯 Learning objectives

This chapter focuses on:

- Creating an Azure Storage backend before consuming it from other Terraform configurations.
- Moving Terraform state from the local filesystem to Azure Blob Storage.
- Separating infrastructure components into independently managed state files.
- Publishing resource attributes as Terraform outputs.
- Reading outputs from another configuration using `terraform_remote_state`.
- Authenticating remote-state reads with Microsoft Entra ID through `use_azuread_auth = true`.
- Understanding the deployment order introduced by cross-state dependencies.
- Reusing output values instead of redeclaring shared resources.
- Rendering a Bash startup script with `templatefile`.

## 📁 Directory structure

```text
stage/
├── backend/
│   ├── main.tf
│   ├── outputs.tf
│   ├── providers.tf
│   └── variables.tf
└── services/
    ├── vnet/
    │   ├── main.tf
    │   ├── outputs.tf
    │   ├── providers.tf
    │   └── variables.tf
    ├── lb/
    │   ├── main.tf
    │   ├── outputs.tf
    │   ├── providers.tf
    │   └── variables.tf
    ├── nsg/
    │   ├── main.tf
    │   ├── providers.tf
    │   └── variables.tf
    └── webserver-cluster/
        ├── main.tf
        ├── providers.tf
        ├── user-data.sh
        ├── variables.tf
        └── outputs.tf
```

The output files not shown in this document are required wherever another configuration references values such as `cluster_rg_name`, `cluster_fe_lb_pip_id`, `cluster_private_subnet_id`, or `cluster_be_pool_id`.

## 🏗️ Architecture and state relationships

```text
stage/backend
  |
  | creates
  v
Azure Storage Account + private Blob container
  |
  +-- cluster_vnet.terraform.tfstate
  |       |
  |       +--> Resource Group name
  |       +--> Subnet ID
  |       +--> Load Balancer Public IP ID
  |
  +-- cluster_lb.terraform.tfstate
  |       |
  |       +--> Load Balancer backend pool ID
  |
  +-- cluster_nsg.terraform.tfstate
  |
  +-- webserver_cluster.terraform.tfstate

Deployment dependencies:

vnet ───────────────> lb
  |                    |
  +──────> nsg         |
  |                    v
  +────────────> webserver-cluster
                     ^
                     |
                     lb
```

The `vnet` state acts as the shared foundation. Both `lb` and `nsg` read from it. The `webserver-cluster` configuration reads from both the `vnet` and `lb` states.

## 1️⃣ Bootstrap the remote backend

The `stage/backend` configuration creates:

- Resource Group: `rg-tfstate-cluster-st`
- Storage Account: `tfstateclustersteastus`
- Private container: `tfstate-cluster-container`

Its outputs return the generated Storage Account and container names:

```hcl
output "tfstate_st_name" {
    value = azurerm_storage_account.tfstate_st.name
}

output "tfstate_container_name" {
    value = azurerm_storage_container.tfstate_container.name
}
```

This configuration starts with local state because the Azure backend does not yet exist. It must be deployed before running `terraform init` in the service folders.

```bash
cd stage/backend
terraform init
terraform fmt
terraform validate
terraform apply
```

> Destroying the backend while service state files still depend on it can make those states unavailable. The service resources should be destroyed first if the entire lab is being removed.

## 2️⃣ Separate state files

All four service configurations use the same Storage Account and container, but each has a unique backend key:

| Service | State blob key |
|---|---|
| `vnet` | `cluster_vnet.terraform.tfstate` |
| `lb` | `cluster_lb.terraform.tfstate` |
| `nsg` | `cluster_nsg.terraform.tfstate` |
| `webserver-cluster` | `webserver_cluster.terraform.tfstate` |

For example:

```hcl
backend "azurerm" {
    resource_group_name  = "rg-tfstate-cluster-st"
    storage_account_name = "tfstateclustersteastus"
    container_name       = "tfstate-cluster-container"
    key                  = "cluster_vnet.terraform.tfstate"
}
```

The separate keys isolate the state of each service while retaining all blobs in the same private container.

## 3️⃣ Shared network foundation

The `vnet` configuration creates the resources shared by the other services:

- Cluster Resource Group.
- Virtual Network.
- Private backend subnet.
- Static Standard Public IP for the Load Balancer frontend.

The configuration still selects the first address from a list:

```hcl
address_space = [var.vnet_address_space[0]]
```

As in earlier exercises, this is useful for practicing Terraform list references. The subnet CIDR is currently declared directly as `10.0.0.0/24`.

The `vnet` outputs form the contract consumed by the downstream configurations. The names referenced in the provided code are:

```text
cluster_rg_name
cluster_fe_lb_pip_id
cluster_private_subnet_id
```

## 4️⃣ Load Balancer service

The `lb` configuration fetches the `vnet` state:

```hcl
data "terraform_remote_state" "vnet_state" {
    backend = "azurerm"

    config = {
        storage_account_name = "tfstateclustersteastus"
        container_name       = "tfstate-cluster-container"
        key                  = "cluster_vnet.terraform.tfstate"
        use_azuread_auth     = true
    }
}
```

It then consumes the shared outputs to select the existing Resource Group and Public IP:

```hcl
resource_group_name   = data.terraform_remote_state.vnet_state.outputs.cluster_rg_name
public_ip_address_id  = data.terraform_remote_state.vnet_state.outputs.cluster_fe_lb_pip_id
```

The service creates:

- Standard Load Balancer.
- Backend address pool.
- HTTP health probe on `/index.html` and port 80.
- TCP rule forwarding frontend port 80 to backend port 80.

The backend pool ID must be exported by the `lb` configuration as `cluster_be_pool_id` because the web cluster reads that value later.

## 5️⃣ Network Security Group service

The `nsg` configuration also reads the `vnet` state. It uses the Resource Group name and subnet ID to create and associate the NSG.

The rules allow:

- HTTP traffic from the `Internet` service tag to TCP port 80.
- Probe traffic from the `AzureLoadBalancer` service tag to port 80.

The NSG is associated with the subnet exported by the `vnet` state:

```hcl
subnet_id = data.terraform_remote_state.vnet_state.outputs.cluster_private_subnet_id
```

## 6️⃣ Web-server cluster service

The `webserver-cluster` configuration consumes two state files:

- `cluster_vnet.terraform.tfstate` for the Resource Group and subnet.
- `cluster_lb.terraform.tfstate` for the Load Balancer backend pool.

The VMSS therefore connects resources owned by separate Terraform configurations without recreating them:

```hcl
subnet_id = data.terraform_remote_state.vnet_state.outputs.cluster_private_subnet_id

load_balancer_backend_address_pool_ids = [
    data.terraform_remote_state.lb_state.outputs.cluster_be_pool_id
]
```

The Scale Set starts with two Ubuntu instances and renders `user-data.sh` with a server port:

```hcl
custom_data = base64encode(
    templatefile("${path.module}/user-data.sh", {
        server_port = 80
    })
)
```

The script creates a small HTML page and starts BusyBox:

```bash
#!/bin/bash

cat > index.html <<EOF
<h1>Hello, World!</h1>
EOF

nohup busybox httpd -f -p ${server_port} &
```

## 🔐 Authentication and access

The remote-state data sources set `use_azuread_auth = true`, so those reads use Microsoft Entra ID authentication. The identity running Terraform must have appropriate data-plane access to the private state container.

The supplied `backend "azurerm"` blocks do not contain that option. Backend initialization must therefore use an authentication method available to the Terraform process. The authentication strategy should be applied consistently and documented for each environment.

## 🚀 Deployment order

The configurations must be applied in dependency order:

1. `stage/backend`
2. `stage/services/vnet`
3. `stage/services/lb` and `stage/services/nsg`
4. `stage/services/webserver-cluster`

Example:

```bash
cd stage/backend && terraform init && terraform apply
cd ../services/vnet && terraform init && terraform apply
cd ../lb && terraform init && terraform apply
cd ../nsg && terraform init && terraform apply
cd ../webserver-cluster && terraform init && terraform apply
```

Test the service through the Load Balancer Public IP:

```bash
curl http://<LOAD_BALANCER_PUBLIC_IP>
```

## 🧹 Destruction order

Use the reverse dependency order:

1. `webserver-cluster`
2. `nsg`
3. `lb`
4. `vnet`
5. `backend`

This avoids deleting shared resources or the remote-state location before their consumers are removed.

## 🧪 Concepts intentionally practiced

- Bootstrapping a backend separately because it does not exist during the first deployment.
- Storing several isolated state blobs in one private container.
- Using outputs as an interface between independently managed configurations.
- Consuming cross-configuration values with `terraform_remote_state`.
- Practicing list indexing in the VNet configuration.
- Rendering an external script with `templatefile` and passing `server_port` into it.
- Observing the explicit deployment sequence introduced by state separation.

## 🧭 Current orchestration approach

The deployment is still performed manually, one Terraform root module at a time, following the dependency order documented above. I am **not using Terragrunt yet** to orchestrate the initialization, planning, application, or destruction of these configurations because Terragrunt has not been introduced or explained at this point in the book.

Keeping the workflow manual is intentional for this chapter. It helps make the following concepts visible before adding another orchestration layer:

- How each root module has its own backend and state key.
- Which outputs must be published by one configuration and consumed by another.
- Why `vnet` must exist before `lb`, `nsg`, and `webserver-cluster` can read its state.
- Why the Load Balancer state must exist before the VMSS can join its backend pool.
- How deployment and destruction order emerge from cross-state dependencies.
- What Terraform itself manages and what would later be delegated to an orchestration tool.

For now, changing directories and running Terraform separately in each component is therefore part of the exercise rather than an omission:

```bash
cd stage/backend
terraform init
terraform apply

cd ../services/vnet
terraform init
terraform apply

cd ../lb
terraform init
terraform apply

cd ../nsg
terraform init
terraform apply

cd ../webserver-cluster
terraform init
terraform apply
```

A later iteration may evaluate Terragrunt or another orchestration approach after the related concepts are covered in the study material. Until then, this repository keeps the implementation aligned with the progression of the book and avoids introducing abstractions before the underlying Terraform behavior is understood.

## ⚠️ Learning-environment notes

- Terragrunt is not used yet because it has not been introduced at this stage of the book; orchestration remains manual and explicit.
- Backend resource names are repeated in several folders, so changes require coordinated updates.
- A remote-state consumer can read the outputs exposed by the referenced state. Sensitive information should not be exposed as an output unnecessarily.
- State separation reduces the scope of each state file but introduces cross-configuration coordination.
- The VMSS uses password authentication in the supplied implementation. Credentials should not be committed to source control.
- The Blob container is private, but effective protection still depends on correctly scoped Azure permissions.
- The configurations use AzureRM `~> 3.0.0`; provider upgrades should be tested before changing the version constraint.

## 🚧 Project status

This Chapter 3 exercise evolves the earlier single-state Linux cluster into multiple Terraform configurations connected through outputs and remote state stored in Azure Blob Storage.

---

## 🇧🇷 Português

## Visão geral

No Capítulo 3 da minha adaptação para Azure do livro *Terraform: Up & Running, 3rd Edition*, reorganizei o cluster web Linux em várias configurações Terraform independentes e introduzi um **backend remoto AzureRM**.

Em vez de manter toda a infraestrutura em um único arquivo de estado, o ambiente foi dividido em uma configuração de criação do backend e quatro configurações de serviços:

- `backend`: cria a Storage Account e o contêiner Blob privado usados pelos estados.
- `vnet`: cria o Grupo de Recursos compartilhado, a VNet, a sub-rede e o IP Público do Load Balancer.
- `lb`: cria o Load Balancer, o backend pool, o health probe e a regra de encaminhamento.
- `nsg`: cria o NSG e o associa à sub-rede compartilhada.
- `webserver-cluster`: cria o VM Scale Set e o conecta à sub-rede e ao backend pool.

Cada serviço mantém seu estado em um blob diferente e obtém valores compartilhados utilizando `terraform_remote_state`.

> Esta é uma implementação de aprendizado para praticar estado remoto, isolamento de estados, outputs, dependências entre configurações e implantação em etapas. Não representa uma plataforma pronta para produção.

## 🎯 Objetivos de aprendizado

- Criar o backend no Azure Storage antes de utilizá-lo nas demais configurações.
- Mover o estado do sistema de arquivos local para o Azure Blob Storage.
- Separar componentes em estados gerenciados independentemente.
- Publicar atributos de recursos através de outputs.
- Ler outputs de outra configuração com `terraform_remote_state`.
- Utilizar autenticação do Microsoft Entra ID nas leituras de estado remoto.
- Entender a ordem de implantação criada pelas dependências entre estados.
- Renderizar um script Bash externo utilizando `templatefile`.

## 📁 Estrutura

```text
stage/
├── backend/
│   ├── main.tf
│   ├── outputs.tf
│   ├── providers.tf
│   └── variables.tf
└── services/
    ├── vnet/
    ├── lb/
    ├── nsg/
    └── webserver-cluster/
        └── user-data.sh
```

Os arquivos de output precisam expor os valores consumidos por outras configurações, incluindo `cluster_rg_name`, `cluster_fe_lb_pip_id`, `cluster_private_subnet_id` e `cluster_be_pool_id`.

## 🏗️ Relações entre os estados

```text
backend
  |
  +-- cluster_vnet.terraform.tfstate
  |       +--> Grupo de Recursos
  |       +--> Sub-rede
  |       +--> IP Público do Load Balancer
  |
  +-- cluster_lb.terraform.tfstate
  |       +--> Backend pool do Load Balancer
  |
  +-- cluster_nsg.terraform.tfstate
  |
  +-- webserver_cluster.terraform.tfstate

vnet ─────> lb ───────────────┐
  |                           v
  +───────> nsg       webserver-cluster
  |                           ^
  +───────────────────────────┘
```

O estado de `vnet` funciona como base compartilhada. `lb` e `nsg` leem esse estado, enquanto `webserver-cluster` lê os estados de `vnet` e `lb`.

## 1️⃣ Criação do backend

A pasta `stage/backend` cria:

- Grupo de Recursos `rg-tfstate-cluster-st`.
- Storage Account `tfstateclustersteastus`.
- Contêiner privado `tfstate-cluster-container`.

Seus outputs retornam os nomes da Storage Account e do contêiner. Essa configuração começa com estado local porque o backend ainda não existe.

```bash
cd stage/backend
terraform init
terraform fmt
terraform validate
terraform apply
```

## 2️⃣ Estados separados

Cada serviço utiliza uma chave diferente no mesmo contêiner:

| Serviço | Chave do estado |
|---|---|
| `vnet` | `cluster_vnet.terraform.tfstate` |
| `lb` | `cluster_lb.terraform.tfstate` |
| `nsg` | `cluster_nsg.terraform.tfstate` |
| `webserver-cluster` | `webserver_cluster.terraform.tfstate` |

Isso isola os recursos administrados por cada configuração, embora todos os estados permaneçam no mesmo contêiner privado.

## 3️⃣ Base de rede

A configuração `vnet` cria o Grupo de Recursos do cluster, a VNet, a sub-rede privada e o IP Público Standard do Load Balancer.

Ela continua praticando indexação de listas:

```hcl
address_space = [var.vnet_address_space[0]]
```

Os outputs da pasta `vnet` funcionam como contrato para as configurações seguintes.

## 4️⃣ Load Balancer

A pasta `lb` consulta `cluster_vnet.terraform.tfstate` e reutiliza o Grupo de Recursos e o IP Público criados pela configuração de rede.

Ela cria:

- Load Balancer Standard.
- Backend address pool.
- Health probe HTTP em `/index.html` na porta 80.
- Regra TCP da porta 80 do frontend para a porta 80 do backend.

O backend pool deve ser exposto pelo output `cluster_be_pool_id` para ser consumido pelo VMSS.

## 5️⃣ Network Security Group

A pasta `nsg` consulta o estado de `vnet`, cria as regras de HTTP e health probe e associa o NSG à sub-rede publicada pelo output `cluster_private_subnet_id`.

As regras permitem:

- Tráfego da service tag `Internet` para TCP/80.
- Tráfego da service tag `AzureLoadBalancer` para a porta 80.

## 6️⃣ Cluster web

A pasta `webserver-cluster` lê:

- O estado de `vnet` para obter o Grupo de Recursos e a sub-rede.
- O estado de `lb` para obter o backend pool.

O VMSS inicia com duas instâncias Ubuntu e utiliza `templatefile` para enviar `server_port = 80` ao `user-data.sh`:

```hcl
custom_data = base64encode(templatefile("${path.module}/user-data.sh", {
    server_port = 80
}))
```

O script gera uma página simples e inicia o BusyBox na porta fornecida.

## 🔐 Autenticação

As fontes `terraform_remote_state` possuem:

```hcl
use_azuread_auth = true
```

Assim, essas leituras utilizam autenticação do Microsoft Entra ID. A identidade que executa o Terraform ainda precisa possuir acesso adequado ao contêiner.

Os blocos `backend "azurerm"` fornecidos não contêm essa opção. A inicialização do backend precisa utilizar um método de autenticação disponível para o processo do Terraform, e essa estratégia deve ser aplicada de forma consistente.

## 🚀 Ordem de implantação

1. `stage/backend`
2. `stage/services/vnet`
3. `stage/services/lb` e `stage/services/nsg`
4. `stage/services/webserver-cluster`

Exemplo:

```bash
cd stage/backend && terraform init && terraform apply
cd ../services/vnet && terraform init && terraform apply
cd ../lb && terraform init && terraform apply
cd ../nsg && terraform init && terraform apply
cd ../webserver-cluster && terraform init && terraform apply
```

## 🧹 Ordem de destruição

Utilize a ordem inversa:

1. `webserver-cluster`
2. `nsg`
3. `lb`
4. `vnet`
5. `backend`

Isso evita a remoção do local do estado ou de recursos compartilhados antes de seus consumidores.

## 🧪 Conceitos praticados intencionalmente

- Bootstrap separado do backend.
- Vários blobs de estado em um único contêiner privado.
- Outputs como interface entre configurações independentes.
- Consumo de valores com `terraform_remote_state`.
- Indexação de listas na VNet.
- Template externo com parâmetro `server_port`.
- Sequência explícita de implantação criada pela separação de estados.

## 🧭 Abordagem atual de orquestração

A implantação ainda é executada manualmente, um módulo raiz do Terraform por vez, seguindo a ordem de dependências documentada anteriormente. **Ainda não utilizo Terragrunt** para orquestrar a inicialização, o planejamento, a aplicação ou a destruição dessas configurações porque o Terragrunt ainda não foi apresentado nem explicado neste ponto do livro.

Manter o fluxo manual é uma decisão intencional neste capítulo. Isso permite visualizar os seguintes conceitos antes de adicionar outra camada de orquestração:

- Como cada módulo raiz possui seu próprio backend e sua própria chave de estado.
- Quais outputs precisam ser publicados por uma configuração e consumidos por outra.
- Por que `vnet` precisa existir antes que `lb`, `nsg` e `webserver-cluster` possam ler seu estado.
- Por que o estado do Load Balancer precisa existir antes que o VMSS possa ingressar no backend pool.
- Como a ordem de implantação e destruição surge das dependências entre estados.
- O que é gerenciado diretamente pelo Terraform e o que poderia ser delegado futuramente a uma ferramenta de orquestração.

Por enquanto, acessar cada diretório e executar o Terraform separadamente em cada componente faz parte do exercício, em vez de representar uma omissão:

```bash
cd stage/backend
terraform init
terraform apply

cd ../services/vnet
terraform init
terraform apply

cd ../lb
terraform init
terraform apply

cd ../nsg
terraform init
terraform apply

cd ../webserver-cluster
terraform init
terraform apply
```

Uma evolução futura poderá avaliar o Terragrunt ou outra estratégia de orquestração depois que os conceitos relacionados forem abordados no material de estudo. Até lá, o repositório mantém a implementação alinhada à progressão do livro e evita introduzir abstrações antes da compreensão do comportamento fundamental do Terraform.

## ⚠️ Observações sobre o ambiente de aprendizado

- O Terragrunt ainda não é utilizado porque não foi apresentado neste ponto do livro; a orquestração permanece manual e explícita.
- Os nomes do backend estão repetidos em várias pastas e exigem alterações coordenadas.
- Consumidores de estado remoto podem acessar os outputs expostos pelo estado referenciado.
- A separação reduz o escopo de cada estado, mas aumenta a necessidade de coordenação.
- O VMSS utiliza autenticação por senha na implementação apresentada. Credenciais não devem ser commitadas.
- O contêiner é privado, mas sua segurança ainda depende de permissões do Azure corretamente definidas.
- As configurações utilizam AzureRM `~> 3.0.0`; upgrades devem ser testados.

## 🚧 Status do projeto

Este exercício do Capítulo 3 transforma o cluster Linux anterior, que utilizava um único estado, em várias configurações Terraform conectadas por outputs e estados remotos armazenados no Azure Blob Storage.
