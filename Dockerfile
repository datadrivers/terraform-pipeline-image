FROM python:3.8-alpine

ARG AZURE_CLI_VERSION=2.66.1
ARG AZURE_IDENTITY_VERSION=1.21.0
ARG KUBECTL_VERSION=v1.27.3
ARG MSAL_EXTENSIONS_VERSION=1.2.0
ARG PRE_COMMIT_VERSION=3.5.0
ARG SOPS_VERSION=v3.10.2
ARG TGENV_VERSION=v0.0.3
ARG TFENV_VERSION=v3.0.0
ARG TFLINT_VERSION=v0.58.0

ENV AZURE_CLI_VERSION=${AZURE_CLI_VERSION} \
    AZURE_IDENTITY_VERSION=${AZURE_IDENTITY_VERSION}\
    KUBECTL_VERSION=${KUBECTL_VERSION} \
    MSAL_EXTENSIONS_VERSION=${MSAL_EXTENSIONS_VERSION} \
    PRE_COMMIT_VERSION=${PRE_COMMIT_VERSION} \
    SOPS_VERSION=${SOPS_VERSION} \
    TGENV_VERSION=${TGENV_VERSION} \
    TFENV_VERSION=${TFENV_VERSION} \
    TFLINT_VERSION=${TFLINT_VERSION}

RUN apk add --no-cache curl bash git openssh-client jq unzip libffi-dev openssl-dev && \
    apk add --no-cache --virtual builddeps gcc musl-dev python3-dev cargo make && \
    pip install --upgrade pip && \
    pip install azure-cli==${AZURE_CLI_VERSION} && \
    pip install azure-identity==${AZURE_IDENTITY_VERSION} && \
    pip install msal-extensions==${MSAL_EXTENSIONS_VERSION} && \
    pip install pre-commit==${PRE_COMMIT_VERSION} && \
    curl --fail --silent -L -o /tmp/tflint.zip https://github.com/terraform-linters/tflint/releases/download/${TFLINT_VERSION}/tflint_linux_amd64.zip && \
    curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin && \
    unzip -u /tmp/tflint.zip -d /usr/local/bin && \
    rm -rf /tmp/* && apk del builddeps && \
    tflint --version && az --version && \
    adduser -g "iac-executor" -D iac-executor && \
    curl -Lo ./sops https://github.com/getsops/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux && \
    chmod +x ./sops && \
    mv ./sops /usr/local/bin

USER iac-executor
WORKDIR /home/iac-executor

ENV PATH="~/bin:$PATH"
RUN mkdir bin && \
    curl --fail --silent -L -o ./tfenv.zip https://github.com/tfutils/tfenv/archive/refs/tags/${TFENV_VERSION}.zip && \
    curl --fail --silent -L -o ./tgenv.zip https://github.com/cunymatthieu/tgenv/archive/refs/tags/${TGENV_VERSION}.zip && \
    unzip tfenv  && mv tfenv-* .tfenv/ && \
    unzip tgenv  && mv tgenv-* .tgenv/ && \
    ln -s /home/iac-executor/.tfenv/bin/* /home/iac-executor/bin && \
    ln -s /home/iac-executor/.tgenv/bin/* /home/iac-executor/bin && \
    ./bin/tfenv --version && ./bin/tgenv --version

ENTRYPOINT ["/bin/bash"]
