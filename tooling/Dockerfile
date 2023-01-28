# syntax=docker/dockerfile:1.4
FROM docker:20.10.10-dind as osbase

USER root

WORKDIR /root

RUN --mount=type=cache,id=apk,target=/var/cache/apk/ \
    apk add --update \
        curl \
        tar \
        unzip

# Terraform
FROM osbase as terraform
ARG TERRAFORM_VERSION=1.3.6
ARG TERRAFORM_RELEASE=terraform_${TERRAFORM_VERSION}_linux_amd64.zip
RUN curl \
    --url https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/${TERRAFORM_RELEASE} \
    --output ${TERRAFORM_RELEASE} \
    --location
RUN unzip \
    ${TERRAFORM_RELEASE} \
    terraform

# Terraform Docs
FROM osbase as terraform-docs
ARG TERRAFORM_DOCS_VERSION=0.16.0
ARG TERRAFORM_DOCS_RELEASE=terraform-docs-v${TERRAFORM_DOCS_VERSION}-linux-amd64.tar.gz
RUN curl \
    --url https://github.com/terraform-docs/terraform-docs/releases/download/v${TERRAFORM_DOCS_VERSION}/${TERRAFORM_DOCS_RELEASE} \
    --output ${TERRAFORM_DOCS_RELEASE} \
    --location
RUN mkdir -p terraform-docs && tar \
    --file ${TERRAFORM_DOCS_RELEASE} \
    --extract \
    --gzip \
    --directory ./terraform-docs/

FROM osbase as aws-cli
ARG AWSCLI_VERSION=2.6.1

RUN curl -sL https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWSCLI_VERSION}.zip -o awscliv2.zip
RUN unzip awscliv2.zip
RUN aws/install


# Tooling image
FROM osbase as tooling
USER root
WORKDIR /root
RUN --mount=type=cache,id=apk,target=/var/cache/apk/ \
    apk add --update \
        bash \
        curl \
        git \
        py3-pip \
        python3 \
        tar \
        zip && \
    ln -s /usr/bin/python3 /usr/bin/python
RUN pip install \
    # Cannot uninstall 'distlib'
    --ignore-installed distlib \
    pre-commit

COPY --link --from=terraform --chown=root:root --chmod=755 \
    /root/terraform /usr/local/bin/

COPY --link --from=terraform-docs --chown=root:root --chmod=755 \
    /root/terraform-docs /usr/local/bin/

COPY --link --from=aws-cli --chown=root:root --chmod=755 \
    /usr/local/aws-cli/ /usr/local/aws-cli/
COPY --link --from=aws-cli --chown=root:root --chmod=755 \
    /usr/local/bin/ /usr/local/bin/

# Install Glibc for AWS CLI to work in Alpine
ARG GLIBC_VERSION=2.35-r0

# install glibc compatibility for alpine
RUN apk --no-cache add \
        binutils \
        curl \
    && curl -sL https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub \
    && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk \
    && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk \
    && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-i18n-${GLIBC_VERSION}.apk \
    && apk add --no-cache \
        glibc-${GLIBC_VERSION}.apk \
        glibc-bin-${GLIBC_VERSION}.apk \
        glibc-i18n-${GLIBC_VERSION}.apk \
    && /usr/glibc-compat/bin/localedef -i en_US -f UTF-8 en_US.UTF-8 \
    && ln -sf /usr/glibc-compat/lib/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2 

COPY --from=golang:1.19-alpine /usr/local/go/ /usr/local/go/

ENV PATH="/usr/local/go/bin:${PATH}"

RUN pre-commit --version && \
    terraform --version && \
    terraform-docs --version
