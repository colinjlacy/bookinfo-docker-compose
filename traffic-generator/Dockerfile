FROM curlimages/curl:8.5.0

USER root

# Install bash and other utilities
RUN apk add --no-cache bash coreutils

# Copy the traffic generation script
COPY generate_traffic.sh /usr/local/bin/generate_traffic.sh

# Make the script executable
RUN chmod +x /usr/local/bin/generate_traffic.sh

# Switch back to non-root user
USER curl_user

# Set the entrypoint to the traffic generation script
ENTRYPOINT ["/usr/local/bin/generate_traffic.sh"]

