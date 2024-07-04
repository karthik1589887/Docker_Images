# Use Sloopstash as the base image
FROM sloopstash/base:v1.1.1

# Install system packages
RUN set -x \
    && yum update -y \
    && yum upgrade -y

# Set the Prometheus version
ENV PROMETHEUS_VERSION=2.45.6

# Create Prometheus user and directories
RUN cd /tmp \
    && wget https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz \
    && tar -xvf prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz \
    && cd prometheus-${PROMETHEUS_VERSION}.linux-amd64 \
    && cp prometheus /usr/local/bin/ \
    && cp promtool /usr/local/bin/ \
    && cp -r consoles /etc/prometheus/ \
    && cp -r console_libraries /etc/prometheus/ \
    && cp prometheus.yml /etc/prometheus

# Expose Prometheus port
EXPOSE 9090

# Set user and entrypoint
ENTRYPOINT ["/usr/local/bin/prometheus", "--config.file=/etc/prometheus/prometheus.yml", "--storage.tsdb.path=/var/lib/prometheus"]
