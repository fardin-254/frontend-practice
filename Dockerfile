# We use Alpine Linux with NGINX — it is ultra-lightweight (~25MB) and fast
FROM nginx:1.27-alpine AS runner

# Security: Ensure NGINX has write permissions without needing full root privileges
RUN touch /var/run/nginx.pid && \
  chown -R nginx:nginx /var/run/nginx.pid /var/cache/nginx

# Copy our custom NGINX reverse-proxy configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy our website HTML & JavaScript into NGINX's default web directory
COPY src/ /usr/share/nginx/html/

# Switch to non-root user (Standard enterprise security practice)
USER nginx

# Expose HTTP port 80
EXPOSE 80

# Container Healthcheck: Checks every 30s if the web server is answering
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:80/ || exit 1

# Start NGINX in foreground mode
CMD ["nginx", "-g", "daemon off;"]