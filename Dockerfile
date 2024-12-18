FROM python:3.11-alpine

ENV TFENV_VERSION v3.0.0
ENV TGENV_VERSION v0.0.3
ENV TFLINT_VERSION v0.44.1
ENV AZURE_CLI_VERSION 2.49.0
ENV KUBECTL_VERSION v1.27.3
ENV SOPS_VERSION v3.7.3

RUN apk add --no-cache curl bash  git openssh-client jq unzip libffi-dev openssl-dev && \
    apk add --no-cache --virtual builddeps gcc musl-dev python3-dev cargo make && \
    pip install --upgrade pip && pip install azure-cli==${AZURE_CLI_VERSION} && \
    curl --fail --silent -L -o /tmp/tflint.zip https://github.com/terraform-linters/tflint/releases/download/${TFLINT_VERSION}/tflint_linux_amd64.zip && \
    curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin && \
    unzip -u /tmp/tflint -d /usr/local/bin && \
    rm -rf /tmp/* && apk del builddeps && \
    tflint --version && az --version && \
    adduser -g "iac-executor" -D iac-executor && \
    curl -Lo ./sops https://github.com/getsops/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux && \
    chmod +x ./sops && \
    mv ./sops /usr/local/bin

USER iac-executor
WORKDIR /home/iac-executor

ENV PATH "~/bin:$PATH"
RUN mkdir bin && \
    curl --fail --silent -L -o ./tfenv.zip https://github.com/tfutils/tfenv/archive/refs/tags/${TFENV_VERSION}.zip && \
    curl --fail --silent -L -o ./tgenv.zip https://github.com/cunymatthieu/tgenv/archive/refs/tags/${TGENV_VERSION}.zip && \
    unzip tfenv  && mv tfenv-* .tfenv/ && \
    unzip tgenv  && mv tgenv-* .tgenv/ && \
    ln -s /home/iac-executor/.tfenv/bin/* /home/iac-executor/bin && \
    ln -s /home/iac-executor/.tgenv/bin/* /home/iac-executor/bin && \
    ./bin/tfenv --version && ./bin/tgenv --version

ENTRYPOINT /bin/bash