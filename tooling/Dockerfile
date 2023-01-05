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

COPY --from=golang:1.19-alpine /usr/local/go/ /usr/local/go/

ENV PATH="/usr/local/go/bin:${PATH}"

RUN pre-commit --version && \
    terraform --version && \
    terraform-docs --version
