# GLOBAL VARIABLES
ARG NODE_VERSION=14.19.3
ARG PULUMI_VERSION=3.43.1

# pulumi node base image
FROM node:${NODE_VERSION}-alpine
# https://stackoverflow.com/questions/53681522/share-variable-in-multi-stage-dockerfile-arg-before-from-not-substituted
ARG PULUMI_VERSION

# pulumi resource
RUN apk add --update make
RUN wget -O pulumi.tar.gz https://get.pulumi.com/releases/sdk/pulumi-v${PULUMI_VERSION}-linux-x64.tar.gz \
    && tar -zxf pulumi.tar.gz \
    && mkdir -p /usr/local/pulumi \
    && cp pulumi/pulumi pulumi/pulumi-language-nodejs pulumi/pulumi-resource-pulumi-nodejs /usr/local/pulumi/ \
    && rm pulumi.tar.gz \
    && rm -rf pulumi/

# minio
RUN sh -x \
    && for version in 0.16.0; \
       do \
          mkdir -p /usr/local/pulumi/plugins/resource-minio-v${version}; \
          cd /usr/local/pulumi/plugins/resource-minio-v${version}; \
          wget -O pulumi-resource-minio.tar.gz https://github.com/pulumi/pulumi-minio/releases/download/v${version}/pulumi-resource-minio-v${version}-linux-amd64.tar.gz; \
          tar -zxf pulumi-resource-minio.tar.gz; \
          rm pulumi-resource-minio.tar.gz; \
       done

# pulumi environment
ENV PATH=${PATH}:/usr/local/pulumi \
    PULUMI_HOME=/usr/local/pulumi \
    PULUMI_SKIP_UPDATE_CHECK=1

COPY .profile $WORKDIR

LABEL PULUMI_VERSION=v${PULUMI_VERSION} \
      NODE_VERSION=${NODE_VERSION} 
