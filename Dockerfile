FROM python:3.11-alpine

ENV TFENV_VERSION v3.0.0
ENV TGENV_VERSION v0.0.3
ENV TFLINT_VERSION v0.44.1
ENV AZURE_CLI_VERSION 2.43.0

RUN apk add --no-cache curl bash unzip git openssh-client jq \
    gcc musl-dev python3-dev libffi-dev openssl-dev cargo make && \
    pip install --upgrade pip && pip install azure-cli==${AZURE_CLI_VERSION} && \
    curl --fail --silent -L -o /tmp/tfenv.zip https://github.com/tfutils/tfenv/archive/refs/tags/${TFENV_VERSION}.zip && \
    curl --fail --silent -L -o /tmp/tgenv.zip https://github.com/cunymatthieu/tgenv/archive/refs/tags/${TGENV_VERSION}.zip && \
    curl --fail --silent -L -o /tmp/tflint.zip https://github.com/terraform-linters/tflint/releases/download/${TFLINT_VERSION}/tflint_linux_amd64.zip && \
    unzip -u /tmp/tfenv -d /tmp && mv /tmp/tfenv-* ~/.tfenv/ && \
    unzip -u /tmp/tgenv -d /tmp && mv /tmp/tgenv-* ~/.tgenv/ && \
    unzip -u /tmp/tflint -d /usr/local/bin && \
    ln -s ~/.tfenv/bin/* /usr/local/bin && \
    ln -s ~/.tgenv/bin/* /usr/local/bin && \
    rm -f /tmp/*.zip && tfenv --version && tgenv --version && tflint --version && az --version && \
    adduser -g "iac-executor" -D iac-executor

USER iac-executor

ENTRYPOINT /bin/bash