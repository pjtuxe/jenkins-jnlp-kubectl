FROM jenkins/slave:latest
MAINTAINER Zsolt Fekete <pjtuxe@gmail.com>

USER root
COPY jenkins-agent /usr/local/bin/jenkins-agent
COPY passwd.template /usr/local/share/passwd.template

RUN cat /etc/*-release
RUN apt-get update && apt-get install -y libnss-wrapper gettext ca-certificates zip unzip apt-utils gnupg2; \
    apt-get clean; \
    chmod +x /usr/local/bin/jenkins-agent &&\
    ln -s /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-slave; \
    # Install Kubectl
    curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl; \
    mv kubectl /usr/bin/kubectl; \
    chmod +x /usr/bin/kubectl; \
    # Install AWS CLI
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"; \
    unzip awscliv2.zip; \
    ./aws/install; \
    # Install AWS IAM Authenticator
    curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/linux/amd64/aws-iam-authenticator; \
    chmod +x ./aws-iam-authenticator; \
    mkdir -p $HOME/bin && cp ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator && export PATH=$PATH:$HOME/bin; \
    echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc; \
    # Install Helm
    curl https://baltocdn.com/helm/signing.asc | apt-key add -; \
    apt-get install apt-transport-https -y; \
    echo "deb https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list; \
    apt-get update; \
    apt-get install helm; \
    # Install MongoDB Tools
    curl -o mongodb-tools.deb https://fastdl.mongodb.org/tools/db/mongodb-database-tools-debian10-x86_64-100.5.2.deb; \
    dpkg -i mongodb-tools.deb; \
    # Install MySQL Client
    apt-get install default-mysql-client -y

USER jenkins

ENTRYPOINT ["jenkins-slave"]
