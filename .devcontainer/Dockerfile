FROM mcr.microsoft.com/devcontainers/base:debian-12

ARG TERRAFORM_VERSION=1.8.5
ARG VAULT_VERSION=1.15.4

# 1. Installation des outils système et dépendances Python
RUN apt-get update && apt-get install -y \
    ansible \
    ansible-lint \
    python3-pip \
    curl \
    unzip \
    git \
    openssh-client \
    iputils-ping \
    libcap2-bin \
    --no-install-recommends \
    && pip3 install kubernetes --break-system-packages \
    && rm -rf /var/lib/apt/lists/*

# 2. Installation de Terraform
RUN curl -fsSL -o /tmp/terraform.zip \
    "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \
    && unzip /tmp/terraform.zip -d /usr/local/bin \
    && rm -f /tmp/terraform.zip \
    && chmod +x /usr/local/bin/terraform

# 3. Installation de Vault CLI 
# Note : On ne fait PAS de setcap ici pour éviter l'erreur "Operation not permitted" 
# sur les systèmes de fichiers Docker (Windows/macOS/Volumes).
RUN curl -fsSL -o /tmp/vault.zip \
    "https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip" \
    && unzip /tmp/vault.zip -d /usr/local/bin \
    && rm -f /tmp/vault.zip \
    && chmod +x /usr/local/bin/vault

# 4. Installation de kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl \
    && rm -f kubectl

# 5. Installation de kustomize
RUN curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash \
    && mv kustomize /usr/local/bin/ \
    && chmod +x /usr/local/bin/kustomize

# 6. Préparation du dossier SSH pour l'utilisateur vscode
RUN mkdir -p /home/vscode/.ssh && chown vscode:vscode /home/vscode/.ssh \
    && chmod 700 /home/vscode/.ssh