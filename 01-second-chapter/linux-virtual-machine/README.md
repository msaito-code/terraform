# 🌐 Simple Web Server VM with Terraform on Azure

**Language / Idioma:** [🇺🇸 English](#-english) | [🇧🇷 Português](#-português)

## 🇺🇸 English

## Overview

This exercise creates a simple Linux web server in Microsoft Azure using Terraform and the AzureRM provider. It is part of my Azure-based adaptation of *Terraform: Up & Running, 3rd Edition*, whose examples are primarily written for AWS.

The goal of this exercise is to practice the basic Terraform resource relationships required to deploy a reachable virtual machine in Azure: a Resource Group, Virtual Network, Subnet, Public IP, Network Interface, Linux VM, Network Security Group, and the NSG association.

The VM starts a minimal BusyBox HTTP server on **TCP port 8080** and returns a simple `Hello, World!` page.

This example is intentionally a learning environment rather than a production-ready web-server deployment. Some parts of the configuration were deliberately written to experiment with Terraform expressions, references, collections, dependencies, and Azure resources.

## 🎯 Learning objectives

This exercise focuses on:

- Creating related Azure resources with Terraform.
- Referencing attributes from one Terraform resource in another.
- Using variables to parameterize resource names, locations, and network ranges.
- Accessing an element from a Terraform list.
- Generating a random value for a resource name.
- Configuring a Public IP and NIC for an Azure VM.
- Associating an NSG with a subnet.
- Allowing inbound application traffic on TCP port 8080.
- Passing a simple startup script to a Linux VM.
- Exposing useful infrastructure information through Terraform outputs.

## 🏗️ Architecture

The configuration creates:

- An Azure Resource Group with a random numeric suffix.
- An Azure Virtual Network.
- A subnet inside the VNet.
- A static Standard Public IP.
- A Network Interface attached to the subnet and Public IP.
- An Ubuntu 24.04 LTS Virtual Machine.
- A Network Security Group with an inbound rule for TCP/8080.
- An association between the NSG and the subnet.
- A minimal BusyBox HTTP server running inside the VM.

```text
                    Internet
                       |
                   TCP/8080
                       |
                  Public IP
                       |
                      NIC
                       |
              +--------+--------+
              |      Subnet     |
              |   NSG: 8080     |
              +--------+--------+
                       |
                 Linux VM
                       |
             BusyBox HTTP server
                       |
                Hello, World!
```

## 🌐 Network access

The NSG explicitly allows inbound TCP traffic to destination port `8080`:

```hcl
security_rule {
    name                       = "Allow-8080"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 8080
    source_address_prefix      = "*"
    destination_address_prefix = "*"
}
```

No custom inbound SSH rule is defined in this NSG. The exercise is centered on reaching the web application over port 8080 rather than using the VM as an interactive workstation.

The application can be tested after deployment using the public IP returned by Terraform:

```bash
curl http://<PUBLIC_IP>:8080
```

Expected response:

```text
Hello, World!
```

## ⚙️ Simple web-server bootstrap

The VM receives a small Bash script through `user_data`:

```bash
#!/bin/bash
echo "Hello, World!" > index.html
nohup busybox httpd -f -p 8080 &
```

This keeps the example intentionally small. The purpose is to verify that the deployed VM can serve content and that the networking configuration permits traffic to the application port without introducing a complete web-server stack such as NGINX or Apache.

## 🧪 Intentional experimentation

This configuration includes a few choices made specifically for learning and experimentation rather than as production design recommendations.

### Referencing values from a list

The `vnet_address_spaces` variable intentionally contains two values:

```hcl
variable "vnet_address_spaces" {
    type = list(string)
    default = [
        "10.0.0.0/16",
        "10.1.0.0/16"
    ]
}
```

However, the VNet intentionally references only the first element:

```hcl
address_space = [var.vnet_address_spaces[0]]
```

This was done to experiment with **list indexing in Terraform** and understand how a specific value from a `list(string)` can be referenced from `main.tf`.

The second CIDR block is therefore not being used by the VNet. The structure should not be interpreted as a networking recommendation for a production environment. If multiple address spaces were actually required, the variable could instead be passed directly according to the intended design.

### Random Resource Group suffix

A `random_integer` resource is used to generate a suffix between `1000` and `9999`:

```hcl
resource "random_integer" "rg_suffix" {
    min = 1000
    max = 9999
}
```

The value is then referenced in the Resource Group name:

```hcl
name = "${var.vm_resource_group}-${var.vm_location}-${random_integer.rg_suffix.result}"
```

This provides another simple example of referencing the output of one Terraform resource from another.

### Explicit dependency

The VM contains:

```hcl
depends_on = [
    azurerm_public_ip.vm_pip
]
```

This was useful for experimenting with Terraform dependency behavior. The configuration already contains resource references through the NIC and Public IP chain, so this exercise also provides a useful place to compare explicit dependencies with Terraform's implicit dependency graph.

## 📌 Variables

| Variable | Purpose | Default |
|---|---|---|
| `vm_resource_group` | Base name used for the VM Resource Group | `vm-rg` |
| `vm_location` | Azure region used for the resources | `eastus` |
| `vnet_address_spaces` | List used to experiment with VNet address-space references | `10.0.0.0/16`, `10.1.0.0/16` |

The subnet itself currently uses `10.0.1.0/24` directly in `main.tf`.

## 📤 Outputs

The configuration returns several values after deployment:

| Output | Description |
|---|---|
| `vm_rg_id` | Resource ID of the Resource Group |
| `vnet_id` | Resource ID of the Virtual Network |
| `vm_private_ip` | Private IP address assigned to the VM |
| `vm_public_ip` | Public IP address used to reach the web server |

The web server can therefore be tested using the `vm_public_ip` output and port `8080`.

## 🚀 Basic workflow

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

After deployment:

```bash
terraform output vm_public_ip
curl http://<PUBLIC_IP>:8080
```

When the exercise is finished:

```bash
terraform destroy
```

## ⚠️ Learning-environment notes

This example intentionally favors simplicity and experimentation. In particular:

- The VM administrator password is currently written directly in `main.tf`. This is acceptable only as something to identify and correct during the learning exercise. Credentials should not be committed to a Git repository or hard-coded in reusable infrastructure.
- Password authentication is enabled on the VM. A hardened deployment would normally use a more appropriate authentication design, such as SSH keys, according to the environment's requirements.
- Port `8080` is allowed from any source address so that the test page is publicly reachable. Production deployments should scope network access according to actual application requirements.
- The BusyBox server is being used only as a minimal test workload. It is not intended to represent a production web-server architecture.
- The two-element VNet variable is an exercise in Terraform list handling, not a recommendation to maintain unused address spaces.
- The configuration is designed to demonstrate Terraform relationships and Azure networking concepts rather than production hardening.

## 🚧 Project status

This is a learning exercise. The configuration may change as I continue studying Terraform and translating the AWS-oriented examples from *Terraform: Up & Running, 3rd Edition* into AzureRM implementations.

---

## 🇧🇷 Português

## Visão geral

Este exercício cria um servidor web Linux simples no Microsoft Azure utilizando Terraform e o provedor AzureRM. Ele faz parte da minha adaptação para Azure do livro *Terraform: Up & Running, 3rd Edition*, cujos exemplos são escritos principalmente para AWS.

O objetivo deste exercício é praticar os relacionamentos básicos entre recursos Terraform necessários para implantar uma máquina virtual acessível no Azure: Grupo de Recursos, Rede Virtual, Sub-rede, IP Público, Interface de Rede, VM Linux, Grupo de Segurança de Rede e a associação do NSG.

A VM inicia um servidor HTTP mínimo do BusyBox na **porta TCP 8080** e retorna uma página simples com `Hello, World!`.

Este exemplo foi desenvolvido propositalmente como um ambiente de aprendizado, e não como uma implantação de servidor web pronta para produção. Algumas partes da configuração foram escritas especificamente para experimentar expressões, referências, coleções, dependências e recursos do Azure no Terraform.

## 🎯 Objetivos de aprendizado

Este exercício tem como foco:

- Criar recursos relacionados do Azure utilizando Terraform.
- Referenciar atributos de um recurso Terraform em outro.
- Utilizar variáveis para parametrizar nomes, regiões e intervalos de rede.
- Acessar um elemento específico de uma lista no Terraform.
- Gerar um valor aleatório para compor o nome de um recurso.
- Configurar um IP Público e uma NIC para uma VM do Azure.
- Associar um NSG a uma sub-rede.
- Permitir tráfego de entrada da aplicação na porta TCP 8080.
- Enviar um script simples de inicialização para uma VM Linux.
- Expor informações úteis da infraestrutura por meio de outputs do Terraform.

## 🏗️ Arquitetura

A configuração cria:

- Um Grupo de Recursos do Azure com um sufixo numérico aleatório.
- Uma Rede Virtual do Azure.
- Uma sub-rede dentro da VNet.
- Um IP Público Standard e estático.
- Uma Interface de Rede conectada à sub-rede e ao IP Público.
- Uma Máquina Virtual Ubuntu 24.04 LTS.
- Um Grupo de Segurança de Rede com uma regra de entrada para TCP/8080.
- Uma associação entre o NSG e a sub-rede.
- Um servidor HTTP mínimo do BusyBox executado dentro da VM.

```text
                    Internet
                       |
                   TCP/8080
                       |
                  IP Público
                       |
                      NIC
                       |
              +--------+--------+
              |     Sub-rede    |
              |   NSG: 8080     |
              +--------+--------+
                       |
                   VM Linux
                       |
             Servidor HTTP BusyBox
                       |
                Hello, World!
```

## 🌐 Acesso de rede

O NSG permite explicitamente tráfego TCP de entrada destinado à porta `8080`:

```hcl
security_rule {
    name                       = "Allow-8080"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 8080
    source_address_prefix      = "*"
    destination_address_prefix = "*"
}
```

Nenhuma regra personalizada de entrada SSH é definida neste NSG. O exercício está focado em acessar a aplicação web pela porta 8080, e não em utilizar a VM como uma estação de trabalho interativa.

Após a implantação, a aplicação pode ser testada utilizando o IP público retornado pelo Terraform:

```bash
curl http://<IP_PUBLICO>:8080
```

Resposta esperada:

```text
Hello, World!
```

## ⚙️ Inicialização simples do servidor web

A VM recebe um pequeno script Bash por meio de `user_data`:

```bash
#!/bin/bash
echo "Hello, World!" > index.html
nohup busybox httpd -f -p 8080 &
```

Isso mantém o exemplo propositalmente pequeno. A intenção é validar que a VM implantada consegue servir conteúdo e que a configuração de rede permite tráfego até a porta da aplicação, sem introduzir uma pilha completa de servidor web como NGINX ou Apache.

## 🧪 Experimentações intencionais

Esta configuração contém algumas decisões feitas especificamente para aprendizado e experimentação, e não como recomendações de arquitetura para produção.

### Referenciando valores de uma lista

A variável `vnet_address_spaces` contém propositalmente dois valores:

```hcl
variable "vnet_address_spaces" {
    type = list(string)
    default = [
        "10.0.0.0/16",
        "10.1.0.0/16"
    ]
}
```

Porém, a VNet referencia propositalmente apenas o primeiro elemento:

```hcl
address_space = [var.vnet_address_spaces[0]]
```

Isso foi feito para experimentar a **indexação de listas no Terraform** e entender como um valor específico de uma `list(string)` pode ser referenciado a partir do `main.tf`.

Portanto, o segundo bloco CIDR não está sendo utilizado pela VNet. Essa estrutura não deve ser interpretada como uma recomendação de rede para ambientes de produção. Caso vários espaços de endereçamento fossem realmente necessários, a variável poderia ser utilizada diretamente conforme o desenho pretendido.

### Sufixo aleatório do Grupo de Recursos

Um recurso `random_integer` é utilizado para gerar um sufixo entre `1000` e `9999`:

```hcl
resource "random_integer" "rg_suffix" {
    min = 1000
    max = 9999
}
```

O valor é então referenciado no nome do Grupo de Recursos:

```hcl
name = "${var.vm_resource_group}-${var.vm_location}-${random_integer.rg_suffix.result}"
```

Isso fornece outro exemplo simples de como referenciar o resultado de um recurso Terraform dentro de outro recurso.

### Dependência explícita

A VM contém:

```hcl
depends_on = [
    azurerm_public_ip.vm_pip
]
```

Isso também serve para experimentar o comportamento das dependências no Terraform. A configuração já contém referências entre recursos através da cadeia NIC e IP Público, tornando este exercício útil para comparar dependências explícitas com o grafo de dependências implícitas que o Terraform constrói a partir das referências.

## 📌 Variáveis

| Variável | Finalidade | Padrão |
|---|---|---|
| `vm_resource_group` | Nome base utilizado para o Grupo de Recursos da VM | `vm-rg` |
| `vm_location` | Região do Azure utilizada pelos recursos | `eastus` |
| `vnet_address_spaces` | Lista utilizada para experimentar referências a espaços de endereçamento da VNet | `10.0.0.0/16`, `10.1.0.0/16` |

A própria sub-rede utiliza atualmente `10.0.1.0/24` diretamente no `main.tf`.

## 📤 Outputs

A configuração retorna diversos valores após a implantação:

| Output | Descrição |
|---|---|
| `vm_rg_id` | ID do recurso do Grupo de Recursos |
| `vnet_id` | ID do recurso da Rede Virtual |
| `vm_private_ip` | Endereço IP privado atribuído à VM |
| `vm_public_ip` | Endereço IP público utilizado para acessar o servidor web |

Dessa forma, o servidor web pode ser testado utilizando o output `vm_public_ip` e a porta `8080`.

## 🚀 Fluxo básico

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

Após a implantação:

```bash
terraform output vm_public_ip
curl http://<IP_PUBLICO>:8080
```

Ao concluir o exercício:

```bash
terraform destroy
```

## ⚠️ Observações sobre o ambiente de aprendizado

Este exemplo prioriza propositalmente simplicidade e experimentação. Em especial:

- A senha do administrador da VM está escrita diretamente no `main.tf`. Isso deve ser tratado apenas como algo a ser identificado e corrigido durante o exercício. Credenciais não devem ser commitadas em um repositório Git nem ficar codificadas diretamente em infraestrutura reutilizável.
- A autenticação por senha está habilitada na VM. Uma implantação reforçada normalmente utilizaria um desenho de autenticação mais adequado, como chaves SSH, conforme os requisitos do ambiente.
- A porta `8080` é permitida a partir de qualquer endereço de origem para tornar a página de teste publicamente acessível. Em produção, o acesso de rede deve ser limitado de acordo com os requisitos reais da aplicação.
- O servidor BusyBox é utilizado apenas como uma carga mínima para teste. Ele não pretende representar uma arquitetura de servidor web para produção.
- A variável de VNet com dois elementos existe como exercício de manipulação de listas no Terraform, e não como recomendação para manter espaços de endereçamento não utilizados.
- A configuração foi desenvolvida para demonstrar relacionamentos entre recursos Terraform e conceitos de rede do Azure, não para demonstrar hardening de produção.

## 🚧 Status do projeto

Este é um exercício de aprendizado. A configuração poderá mudar à medida que eu continuar estudando Terraform e traduzindo para AzureRM os exemplos orientados à AWS do livro *Terraform: Up & Running, 3rd Edition*.
