# syntax=docker/dockerfile:1
# FILE: playwright-mcp/Dockerfile
# Use DaoCloud mirror for faster access on CN-optimized HK VPS
FROM mcr.m.daocloud.io/playwright/mcp:latest

USER root

# Install VNC and minimal GUI
RUN apt-get update && apt-get install -y \
    curl wget ca-certificates \
    xvfb x11vnc fluxbox xterm \
    websockify x11-utils \
    && rm -rf /var/lib/apt/lists/*

# Install noVNC for web browser access
RUN cd /opt && \
    wget -qO- https://gh-proxy.com/https://github.com/novnc/noVNC/archive/v1.4.0.tar.gz | tar xz && \
    mv noVNC-1.4.0 noVNC && \
    ln -s /opt/noVNC/vnc.html /opt/noVNC/index.html

# Create directories and shared user data
RUN mkdir -p /screenshots /app/browser-data/sessions /shared-browser-data && \
    chown -R 1000:1000 /screenshots /app/browser-data /shared-browser-data

# Patch to allow external access (remove "Access is only allowed at localhost" check)
# This finds the JS file containing the error message and removes the conditional check block
RUN find /app -name "*.js" -type f -exec sed -i 's/if (.* !== .*localhost.*) {/if (false) {/g' {} + || true
RUN find /app -name "*.js" -type f -exec sed -i 's/Access is only allowed at/Access Allowed (Patched) /g' {} + || true

# Create startup script
COPY --chmod=755 <<'EOF' /app/start-with-vnc.sh
#!/bin/bash
echo "🖥️ Starting VNC-enabled Playwright MCP..."

# Clean up any existing X server processes and lock files
pkill -f "Xvfb :99" || true
pkill -f "x11vnc.*:99" || true
pkill -f "fluxbox" || true
rm -f /tmp/.X99-lock /tmp/.X11-unix/X99 || true

# Start virtual display
echo "🖥️ Starting Xvfb display server..."
Xvfb :99 -screen 0 1280x720x24 -ac -nolisten tcp &
export DISPLAY=:99

# Wait for display to be ready and verify it's working
echo "⏳ Waiting for X server to be ready..."
for i in {1..30}; do
    if xdpyinfo -display :99 >/dev/null 2>&1; then
        echo "✅ X server is ready"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "❌ X server failed to start after 30 seconds"
        exit 1
    fi
    sleep 1
done

# Start window manager
echo "🖥️ Starting window manager..."
fluxbox &

# Wait for window manager
sleep 2

# Start VNC server (no password for simplicity)
echo "🖥️ Starting VNC server..."
x11vnc -display :99 -nopw -listen 0.0.0.0 -xkb -rfbport 5900 -forever -shared -bg

# Wait for VNC server to start
sleep 2

# Start noVNC web interface
echo "🌐 Starting noVNC web interface..."
websockify --web /opt/noVNC 6080 localhost:5900 &

echo "✅ VNC server ready on port 5900"
echo "🌐 Connect via VNC client to: localhost:5900"
echo "🌐 Web VNC available at: http://localhost:6080"

# Start Playwright MCP with shared browser and user data
# Start Playwright MCP with shared browser and user data (Force 0.0.0.0 binding)
echo "🎭 Starting Playwright MCP..."
export HOST=0.0.0.0
export PORT=${PLAYWRIGHT_MCP_PORT:-8831}
exec node cli.js --browser chromium --host 0.0.0.0 --port ${PORT} \
    --viewport-size "${PLAYWRIGHT_VIEWPORT_SIZE:-1280,720}" \
    --image-responses allow --ignore-https-errors \
    --executable-path /ms-playwright/chromium-*/chrome-linux64/chrome \
    --user-data-dir /shared-browser-data \
    --output-dir /screenshots \
    --no-sandbox
EOF

# Create chromium shortcut script that uses shared user data
COPY --chmod=755 <<'EOF' /usr/local/bin/chromium
#!/bin/bash
export DISPLAY=:99
exec /ms-playwright/chromium-*/chrome-linux64/chrome --no-sandbox --disable-dev-shm-usage --user-data-dir=/shared-browser-data "$@"
EOF

USER 1000
WORKDIR /app

EXPOSE 8831 5900 6080

ENV DEBUG=pw:browser,pw:network,pw:page

ENTRYPOINT ["/app/start-with-vnc.sh"]
