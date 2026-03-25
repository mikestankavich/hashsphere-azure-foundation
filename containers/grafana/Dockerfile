FROM grafana/grafana:11.6.0

# Provisioning: datasource and dashboard provider
COPY provisioning/datasources/prometheus.yml /etc/grafana/provisioning/datasources/prometheus.yml
COPY dashboards/dashboard.yml /etc/grafana/provisioning/dashboards/dashboard.yml

# Dashboard JSON
COPY dashboards/hashsphere-network.json /var/lib/grafana/dashboards/hashsphere-network.json

# Anonymous access for demo
ENV GF_AUTH_ANONYMOUS_ENABLED=true
ENV GF_AUTH_ANONYMOUS_ORG_ROLE=Viewer
ENV GF_SECURITY_ADMIN_PASSWORD=hashsphere-demo
