FROM mcr.microsoft.com/azure-cli:2.43.0 AS azure
FROM public.ecr.aws/aws-cli/aws-cli AS aws
FROM python:3.11-alpine

ENV TFENV_VERSION v2.2.3
ENV TFSWITCH_VERSION 0.13.1300
ENV TGENV_VERSION v0.0.3
ENV TFLINT_VERSION v0.35.0

RUN apk add --no-cache curl bash unzip git openssh-client jq && \
    curl --fail --silent -L -o /tmp/tfenv.zip https://github.com/tfutils/tfenv/archive/refs/tags/${TFENV_VERSION}.zip && \
    curl --fail --silent -L -o /tmp/tgenv.zip https://github.com/cunymatthieu/tgenv/archive/refs/tags/${TGENV_VERSION}.zip && \
    curl --fail --silent -L -o /tmp/tflint.zip https://github.com/terraform-linters/tflint/releases/download/${TFLINT_VERSION}/tflint_linux_amd64.zip && \
    curl --fail --silent -L -o /tmp/tfswitch.tar.gz https://github.com/warrensbox/terraform-switcher/releases/download/${TFSWITCH_VERSION}/terraform-switcher_${TFSWITCH_VERSION}_linux_amd64.tar.gz && \
    unzip -u /tmp/tfenv -d /tmp && mv /tmp/tfenv-* ~/.tfenv/ && \
    unzip -u /tmp/tgenv -d /tmp && mv /tmp/tgenv-* ~/.tgenv/ && \
    unzip -u /tmp/tflint -d /usr/local/bin && \
    tar -xvz -C /tmp -f /tmp/tfswitch.tar.gz && chmod +x /tmp/tfswitch && mv /tmp/tfswitch /usr/local/bin && \
    ln -s ~/.tfenv/bin/* /usr/local/bin && \
    ln -s ~/.tgenv/bin/* /usr/local/bin && \
    rm -f /tmp/*.zip && tfenv --version && tgenv --version && tflint --version && tfswitch --version

COPY --from=azure /usr/local/bin/az /usr/local/bin/az

COPY --from=aws /usr/local/bin/az /usr/local/bin/az
