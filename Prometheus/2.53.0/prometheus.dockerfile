# Use Sloopstash as the base image
FROM sloopstash/base:v1.1.1

# Install system packages
RUN set -x \
    && yum update -y \
    && yum upgrade -y

# Set the Prometheus version
ENV PROMETHEUS_VERSION=2.53.0

# Add a user with no home directory for Prometheus
RUN useradd --no-create-home --shell /sbin/nologin prometheus

# Create directories for Prometheus and change ownership
RUN mkdir /etc/prometheus /var/lib/prometheus \
    && chown prometheus:prometheus /etc/prometheus /var/lib/prometheus

# Download and install Prometheus & change ownership
RUN cd /tmp \
    && wget https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz \
    && tar -xvf prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz \
    && cp prometheus-${PROMETHEUS_VERSION}.linux-amd64/prometheus /usr/local/bin/ \
    && cp prometheus-${PROMETHEUS_VERSION}.linux-amd64/promtool /usr/local/bin/ \
    && chown prometheus:prometheus /usr/local/bin/prometheus \
    && chown prometheus:prometheus /usr/local/bin/promtool \
    && cp -r prometheus-${PROMETHEUS_VERSION}.linux-amd64/consoles /etc/prometheus/ \
    && cp -r prometheus-${PROMETHEUS_VERSION}.linux-amd64/console_libraries /etc/prometheus/ \
    && chown -R prometheus:prometheus /etc/prometheus/consoles \
    && chown -R prometheus:prometheus /etc/prometheus/console_libraries \
    && cp prometheus-${PROMETHEUS_VERSION}.linux-amd64/prometheus.yml /etc/prometheus/ \
    && chown prometheus:prometheus /etc/prometheus/prometheus.yml \
    && rm -rf /tmp/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz /tmp/prometheus-${PROMETHEUS_VERSION}.linux-amd64

# Set user and entrypoint
USER prometheus
ENTRYPOINT ["/usr/local/bin/prometheus"]
CMD ["--config.file=/etc/prometheus/prometheus.yml", \
     "--storage.tsdb.path=/var/lib/prometheus", \
     "--web.console.templates=/etc/prometheus/consoles", \
     "--web.console.libraries=/etc/prometheus/console_libraries"]

# Adding heathcheck
HEALTHCHECK CMD wget --spider http://localhost:9090/ || exit 1
