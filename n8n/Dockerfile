
# Stage 1: Download localization files using a lightweight Alpine image
FROM alpine:latest as builder
RUN apk add --no-cache git
WORKDIR /tmp
RUN git clone https://mirror.ghproxy.com/https://github.com/Other-BlowSnow/n8n-i18n-chinese.git n8n-zh

# Stage 2: Final N8N image
FROM n8nio/n8n:latest

# Switch to root to copy files
USER root

# Copy the localization files from the builder stage
# This bypasses the need to install git/curl in the n8n image, resolving OS compatibility issues
COPY --from=builder /tmp/n8n-zh/editor-ui/dist/ /usr/local/lib/node_modules/n8n/dist/editor-ui/

# Switch back to node user
USER node
