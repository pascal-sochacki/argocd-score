
# Use a lightweight base image
FROM alpine:3.20

# Set the version of score-k8s to install
ARG SCORE_K8S_VERSION=0.5.2
ARG TARGETARCH

# Install necessary dependencies
RUN apk add --no-cache curl tar

COPY init.sh /usr/local/bin
COPY generate.sh /usr/local/bin

# Download and install score-k8s
RUN curl -L "https://github.com/score-spec/score-k8s/releases/download/${SCORE_K8S_VERSION}/score-k8s_${SCORE_K8S_VERSION}_linux_${TARGETARCH}.tar.gz" | tar xz -C /usr/local/bin

# Create the directory for the plugin configuration
RUN mkdir -p /home/argocd/cmp-server/config/

# Copy the plugin configuration file
COPY plugin.yaml /home/argocd/cmp-server/config/plugin.yaml

# Set the working directory
WORKDIR /work

# The entrypoint for the sidecar will be provided by Argo CD
