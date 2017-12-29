FROM docker:stable-dind
LABEL vendor="Ericsson AB" version="0.5" description="SD development k8s deployment"
LABEL maintainer "jesus.javier.arauz@ericsson.com"

# Build args
ARG MINIKUBE_VERSION
ARG KUBERNETES_VERSION

# Environment
ENV LANGUAGE en_US:
ENV LANG en_US.UTF-8
ENV HOME=/root
ENV GOPATH="/usr/bin"
ENV GOROOT="/usr/lib/go"
ENV MINIKUBE_VERSION ${MINIKUBE_VERSION:-latest}
ENV KUBERNETES_VERSION ${KUBERNETES_VERSION:-1.8.0}

# Install minikube
RUN apk --update --no-cache add sudo bash supervisor util-linux socat openssl && \
apk upgrade --update && \
apk add --no-cache --virtual=.build-dependencies ca-certificates wget go make \
autoconf findutils make pkgconf libtool g++ automake linux-headers git && \
wget "https://storage.googleapis.com/kubernetes-release/release/v${KUBERNETES_VERSION}/bin/linux/amd64/kubectl" -O "/usr/local/bin/kubectl" && \
mkdir -p /usr/bin/src/k8s.io && cd /usr/bin/src/k8s.io && chmod +x /usr/local/bin/kubectl && \
wget "https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get" -O "/tmp/get_helm.sh" && \
chmod +x /tmp/get_helm.sh && /tmp/get_helm.sh && \
git clone https://github.com/kubernetes/minikube && cd minikube && \
make && mv ./out/minikube /usr/local/bin/minikube && chmod +x /usr/local/bin/minikube && \
rm -rf /usr/bin/src/k8s.io && rm -rf /tmp/* && apk del .build-dependencies

#WORKDIR $HOME
#RUN curl -Lo minikube https://storage.googleapis.com/minikube/releases/${MINIKUBE_VERSION}/minikube-linux-amd64 && chmod +x minikube
ENV MINIKUBE_WANTUPDATENOTIFICATION=false
ENV MINIKUBE_WANTREPORTERRORPROMPT=false
ENV MINIKUBE_HOME=$HOME/minikube
ENV CHANGE_MINIKUBE_NONE_USER=true
RUN mkdir $HOME/.kube || true
RUN touch $HOME/.kube/config

COPY supervisord.conf /etc/
COPY minikube-dockerd-entrypoint.sh /usr/local/bin/
COPY supervisord_eventlistener.py /usr/local/bin/
RUN chmod ugo+x /usr/local/bin/minikube-dockerd-entrypoint.sh
RUN chmod ugo+x /usr/local/bin/supervisord_eventlistener.py

# Export kube config so it can be used from kubectl container
VOLUME $HOME

# Expose minikube port
EXPOSE 8443

# Run supervisord on start
ENTRYPOINT [ "/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf" ]
