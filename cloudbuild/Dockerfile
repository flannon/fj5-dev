FROM alpine:3.9

ARG TERRAFORM_VERSION=0.13.6
ARG TERRAFORM_VERSION_SHA256SUM=55f2db00b05675026be9c898bdd3e8230ff0c5c78dd12d743ca38032092abfc9

COPY terraform_${TERRAFORM_VERSION}_linux_amd64.zip .
RUN echo "${TERRAFORM_VERSION_SHA256SUM}  terraform_${TERRAFORM_VERSION}_linux_amd64.zip" > checksum && sha256sum -c checksum

RUN /usr/bin/unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip

FROM centos:7
RUN printf '[google-cloud-sdk]\n\
name=Google Cloud SDK\n\
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el7-x86_64\n\
enabled=1\n\
gpgcheck=1\n\
repo_gpgcheck=1\n\
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg\n\
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg\n'\
    >> /etc/yum.repos.d/google-cloud-sdk.repo 
    #>> /etc/yum.repos.d/google-cloud-sdk.repo && \
    #chmod 644 /etc/yum.repos.d/google-cloud-sdk.repo

RUN yum -y update && yum -y install ca-certificates && \ 
    yum install -y epel-release git wget && \
    yum install -y make && \ 
    yum install -y google-cloud-sdk && \
    yum install -y ansible && \
    yum clean all && \
    rm -rf /var/cache/yum && \
    mkdir /root/.ssh && \
    chmod 700 /root/.ssh 

COPY --from=0 terraform /usr/bin/terraform 

ENTRYPOINT ["/usr/bin/terraform"] 
