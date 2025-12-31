
# Stage 1: Download localization files using a lightweight Alpine image
FROM alpine:latest as builder
RUN apk add --no-cache git
WORKDIR /tmp
RUN git clone https://mirror.ghproxy.com/https://github.com/Other-BlowSnow/n8n-i18n-chinese.git n8n-zh

# Stage 2: Final N8N image
FROM n8nio/n8n:latest

# Switch to root to copy files
USER root

# Copy the localization file from the builder stage
# The repo structure is languages/zh-CN.json
COPY --from=builder /tmp/n8n-zh/languages/zh-CN.json /usr/local/lib/node_modules/n8n/dist/editor-ui/src/plugins/i18n/locales/zh-CN.json

# Switch back to node user
USER node
