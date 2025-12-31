
FROM n8nio/n8n:latest

USER root

# Install git and curl for fetching language packs
# n8n:latest is Debian-based, so use apt-get instead of apk
RUN apt-get update && \
    apt-get install -y git curl && \
    rm -rf /var/lib/apt/lists/*

# Install n8n-i18n-chinese (Simple replacement method)
# We clone the repo and copy the dist files to the n8n installation directory
# Note: Path might vary by n8n version, but standard is /usr/local/lib/node_modules/n8n/dist
RUN git clone https://github.com/Other-BlowSnow/n8n-i18n-chinese.git /tmp/n8n-zh && \
    cp -rf /tmp/n8n-zh/editor-ui/dist/* /usr/local/lib/node_modules/n8n/dist/editor-ui/ && \
    rm -rf /tmp/n8n-zh

USER node
